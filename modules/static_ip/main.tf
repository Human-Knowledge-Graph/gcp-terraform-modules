resource "random_string" "rnd" {
  length      = 4
  min_numeric = 4
  special     = false
  lower       = true
}


resource "google_compute_address" "ip_address" {
  project      = var.project_id
  name         = "${var.name}-${random_string.rnd.result}"
  region       = var.region
  address_type = var.address_type
  network_tier = var.network_tier
  description  = var.description
  labels       = var.labels
}