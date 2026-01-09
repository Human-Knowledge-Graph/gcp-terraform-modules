# Static IP Module

This module creates a static IP address in Google Cloud Platform.

## Features

- Creates regional or global static IP addresses
- Supports both internal and external IP addresses
- Configurable network tier (Premium or Standard)
- Automatic random suffix generation for unique naming
- Support for labels and custom descriptions

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "static_ip" {
  # Pin to specific commit - check CHANGELOG.md for latest stable commits
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=COMMIT_HASH"

  project_id = "my-gcp-project"
  name       = "my-app-ip"
  region     = "us-central1"
}
```

> **Finding the right commit:** Check this module's [CHANGELOG.md](./CHANGELOG.md) for stable commit hashes, or use `git log modules/static_ip` to see recent changes.

### Basic External IP

```hcl
module "static_ip" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=efa9048"

  project_id = "my-gcp-project"
  name       = "my-app-ip"
  region     = "us-central1"
}
```

### Global External IP

```hcl
module "global_ip" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=efa9048"

  project_id = "my-gcp-project"
  name       = "my-global-ip"
  region     = null  # Global IP
}
```

### Internal IP with Labels

```hcl
module "internal_ip" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=efa9048"

  project_id   = "my-gcp-project"
  name         = "internal-app-ip"
  region       = "us-central1"
  address_type = "INTERNAL"
  description  = "Internal IP for application load balancer"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

### Standard Network Tier

```hcl
module "standard_ip" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=efa9048"

  project_id   = "my-gcp-project"
  name         = "standard-tier-ip"
  region       = "us-west1"
  network_tier = "STANDARD"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 4.0 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 4.0 |
| random | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID where the static IP will be created | `string` | n/a | yes |
| name | Base name for the static IP address. A random suffix will be appended | `string` | `"static-ip"` | no |
| region | The region where the static IP will be created. If not specified, creates a global IP | `string` | `null` | no |
| address_type | The type of address to reserve. Options: INTERNAL or EXTERNAL | `string` | `"EXTERNAL"` | no |
| network_tier | The networking tier used for configuring this address. Options: PREMIUM or STANDARD | `string` | `"PREMIUM"` | no |
| description | An optional description of this resource | `string` | `""` | no |
| labels | Labels to apply to the static IP address | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ip_address | The static IP address that was allocated |
| self_link | The URI of the created resource |
| name | The name of the static IP address resource |
| id | An identifier for the resource with format projects/{{project}}/regions/{{region}}/addresses/{{name}} |

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `compute.addresses.create`
- `compute.addresses.get`
- `compute.addresses.delete`

These are included in the following predefined roles:
- `roles/compute.networkAdmin`
- `roles/editor`
- `roles/owner`

## Notes

- Regional IPs can only be used by resources in the same region
- Global IPs are typically used for global load balancers
- Internal IPs require a VPC network (not included in this module)
- A random 4-digit suffix is automatically appended to ensure unique names

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input_project_id) | The GCP project ID where the static IP will be created | `string` | n/a | yes |
| <a name="input_address_type"></a> [address_type](#input_address_type) | The type of address to reserve. Options: INTERNAL or EXTERNAL | `string` | `"EXTERNAL"` | no |
| <a name="input_description"></a> [description](#input_description) | An optional description of this resource | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input_labels) | Labels to apply to the static IP address | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input_name) | Base name for the static IP address. A random suffix will be appended | `string` | `"static-ip"` | no |
| <a name="input_network_tier"></a> [network_tier](#input_network_tier) | The networking tier used for configuring this address. Options: PREMIUM or STANDARD | `string` | `"PREMIUM"` | no |
| <a name="input_region"></a> [region](#input_region) | The region where the static IP will be created. If not specified, creates a global IP | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output_id) | An identifier for the resource with format projects/{{project}}/regions/{{region}}/addresses/{{name}} |
| <a name="output_ip_address"></a> [ip_address](#output_ip_address) | The static IP address that was allocated |
| <a name="output_name"></a> [name](#output_name) | The name of the static IP address resource |
| <a name="output_self_link"></a> [self_link](#output_self_link) | The URI of the created resource |
<!-- END_TF_DOCS -->