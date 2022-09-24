variable "region" {
  type        = string
  description = "Azure region to deploy to"
  default     = "East US"
}

variable "league_id" {
  type        = string
  description = "ESPN League ID"
}

variable "sms_number" {
  type        = string
  description = "SMS number to text"
}

variable "interval" {
  type        = string
  description = "Minutes to look for recent activity (e.g. interval=60 gets activity from the last 60 minutes)"  
}

variable "swid" {
  type        = string
  description = "swid UUID needed for ESPN auth"
}

variable "espn_s2" {
  type        = string
  description = "Token needed for ESPN auth"
}