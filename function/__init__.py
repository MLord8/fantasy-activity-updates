from datetime import datetime, timedelta
import logging
import os
from collections import defaultdict
from espn_api.football import League
from azure.communication.email import EmailClient, EmailContent, EmailAddress, EmailRecipients, EmailMessage
import azure.functions as func

logger = logging.Logger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
logger.addHandler(handler)

LEAGUE_ID = int(os.environ.get("LEAGUE_ID", "0"))
SWID = os.environ.get("SWID")
ESPN_S2 = os.environ.get("ESPN_S2")
INTERVAL = int(os.environ.get("INTERVAL", "0"))
EMAIL = os.environ.get("EMAIL")
CONNECTION_STRING = os.environ.get("CONNECTION_STRING")
EMAIL_DOMAIN = os.environ.get("EMAIL_DOMAIN")

ACTION_EMOJI_MAP = defaultdict(
    lambda x: "\U0001f3c8", {
        "DROPPED": "\U0000274C",
        "WAIVER ADDED": "\U0001f4b8",
        "FA ADDED": "\U0001F4DD"
    })


def main(timer: func.TimerRequest) -> None:
    league = League(LEAGUE_ID, year=2022, espn_s2=ESPN_S2, swid=SWID)
    recent_activity = league.recent_activity()

    logger.info(f"Looking for activity in the last {INTERVAL} minutes")
    all_actions = []
    now = datetime.now()
    activity_start = datetime.timestamp(now - timedelta(minutes=INTERVAL)) * 1000

    for activity in recent_activity:
        full_action = []
        if activity.date >= activity_start:
            for team, action, player, bid in activity.actions:
                full_action.append(
                    f"{ACTION_EMOJI_MAP[action]}{team.team_name} {action} {player.name}({player.position}, {player.proTeam}) for ${bid}\n"
                )
            all_actions.append("".join(full_action))

    if all_actions:
        logger.info(f"Found {len(all_actions)} actions, sending email")
        email_client = EmailClient.from_connection_string(CONNECTION_STRING)

        formatted_actions = '\n'.join(all_actions)
        text = f"League updates for the last {INTERVAL} minutes:\n{formatted_actions}"
        content = EmailContent(
            subject="[AUTOMATED] Fantasy League Update",
            plain_text=text
        )

        address = EmailAddress(email=EMAIL)
        recipient = EmailRecipients(to=[address])

        message = EmailMessage(
            sender=
            EMAIL_DOMAIN,
            content=content,
            recipients=recipient)

        response = email_client.send(message)
        logger.info(f"Email response: {response}")
    else:
        logger.info("No actions found")
