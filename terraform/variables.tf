variable "region" {
  type        = string
  description = "Azure region to deploy to"
  default     = "East US"
}

variable "league_id" {
  type        = string
  description = "ESPN League ID"
}

variable "email" {
  type        = string
  description = "Email address to send to"
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

variable "azure_email_domain" {
  type        = string
  description = "Azure email sender domain"
}