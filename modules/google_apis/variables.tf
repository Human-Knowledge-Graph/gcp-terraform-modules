variable "project_id" {
  description = "The unique ID of the project."
  type        = string
}

variable "enabled_google_api_services" {
  description = "List of APIs to enable for the project"
  type        = list(string)
}