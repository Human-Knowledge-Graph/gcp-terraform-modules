variable "secret_id" {
  type = string
}

variable "service_account_with_access_permissions" {
  type        = list(string)
  description = "Determines list of service accounts with permission to access the secret"
  default     = []
}