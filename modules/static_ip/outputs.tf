output "ip_address" {
  description = "The static IP address that was allocated"
  value       = google_compute_address.ip_address.address
}

output "self_link" {
  description = "The URI of the created resource"
  value       = google_compute_address.ip_address.self_link
}

output "name" {
  description = "The name of the static IP address resource"
  value       = google_compute_address.ip_address.name
}

output "id" {
  description = "An identifier for the resource with format projects/{{project}}/regions/{{region}}/addresses/{{name}}"
  value       = google_compute_address.ip_address.id
}