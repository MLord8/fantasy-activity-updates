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
  type          = string
  description = "SMS number to text"
}