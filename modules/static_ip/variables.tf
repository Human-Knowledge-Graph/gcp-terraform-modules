variable "project_id" {
  description = "The GCP project ID where the static IP will be created"
  type        = string
}

variable "name" {
  description = "Base name for the static IP address. A random suffix will be appended"
  type        = string
  default     = "static-ip"
}

variable "region" {
  description = "The region where the static IP will be created. If not specified, creates a global IP"
  type        = string
  default     = null
}

variable "address_type" {
  description = "The type of address to reserve. Options: INTERNAL or EXTERNAL"
  type        = string
  default     = "EXTERNAL"

  validation {
    condition     = contains(["INTERNAL", "EXTERNAL"], var.address_type)
    error_message = "Address type must be either INTERNAL or EXTERNAL."
  }
}

variable "network_tier" {
  description = "The networking tier used for configuring this address. Options: PREMIUM or STANDARD"
  type        = string
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.network_tier)
    error_message = "Network tier must be either PREMIUM or STANDARD."
  }
}

variable "description" {
  description = "An optional description of this resource"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to the static IP address"
  type        = map(string)
  default     = {}
}
