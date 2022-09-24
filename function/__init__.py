from datetime import datetime, timedelta
import logging
import os
from collections import defaultdict
from espn_api.football import League
from azure.communication.sms import SmsClient

logger = logging.Logger(__name__)
logger.setLevel(logging.INFO)

LEAGUE_ID = int(os.get("LEAGUE_ID", 0))  #1341130  make sure to convert to int after read from env
SWID = os.get("SWID")  # {2D5BB0F5-5F69-4AFF-9BB0-F55F695AFF2C}"
ESPN_S2 = os.get("ESPN_S2")  # AECy1i2HsrsHJ4hqAq%2Bv%2B8CabUDhuB9ndujqI%2F5sy5Y8FeY9XvVPRzwKLOuDmElS99FTCTem2zftPSF57B1XsrjYpqzLsJjY38GjxWNYzyJ1j7SKV7SCsObjex2r2C%2BpuBFtH1eqZ98c%2BA7B6cZvM4wSvtKv56TUOqMVnUF5oVn0bAYcJO%2FSwkeJSW9bq7RXzOzwus9qWyiZFXiSBUW0vSHVgX2qf6HklPtDWYZpVYzKmRwbVmWhLDqfKfb2gqT%2FY67eZj0MvR4WyfGXHhPNw0cA"
INTERVAL = int(os.get("INTERVAL"))
SMS_NUMBER = os.get("SMS_NUMBER")
CONNECTION_STRING = os.get("CONNECTION_STRING")

ACTION_EMOJI_MAP = defaultdict(
    lambda x: "\U0001f3c8", {
        "DROPPED": "\U0000274C",
        "WAIVER ADDED": "\U0001f4b8",
        "FA ADDED": "\U0001F4DD"
    })


def main():
    league = League(LEAGUE_ID, year=2022, espn_s2=ESPN_S2, swid=SWID)
    recent_activity = league.recent_activity()

    all_actions = []
    now = datetime.now()
    activity_start = datetime.timestamp(now -
                                        timedelta(minutes=INTERVAL)) * 1000

    for activity in recent_activity:
        full_action = []
        if activity.date >= activity_start:
            for team, action, player, bid in activity.actions:
                full_action.append(
                    f"{ACTION_EMOJI_MAP[action]}{team.team_name} {action} {player.name}({player.position}, {player.proTeam}) for ${bid}\n"
                )
            all_actions.append("".join(full_action))

    if all_actions:
        logger.info(f"Found {len(all_actions)} actions, sending SMS")
        print("\n".join(all_actions))
        sms_client = SmsClient.from_connection_string(CONNECTION_STRING)
        response = sms_client.send(
            from_="",
            to=SMS_NUMBER,
            message=f"{'\n'.join(all_actions)}"
        )
        logger.info(f"SMS Response: {response}")

if __name__ == "__main__":
    main()
