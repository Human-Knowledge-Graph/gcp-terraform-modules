# Changelog - GKE Autopilot Module

All notable changes to this module will be documented in this file.

## [Unreleased]

## [Initial Release] - 2026-02-21

### Added
- Initial release of `gke_autopilot` module
- GKE Autopilot cluster with `enable_autopilot = true`
- Configurable release channel (`RAPID`, `REGULAR`, `STABLE`)
- VPC-native networking with auto-assigned IP ranges
- Deletion protection support
- Outputs: cluster name, ID, location, endpoint, and CA certificate
