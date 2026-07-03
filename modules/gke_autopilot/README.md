# GKE Autopilot Module

This module creates a Google Kubernetes Engine (GKE) Autopilot cluster. Autopilot is a fully managed Kubernetes mode where Google manages the underlying node infrastructure.

## Free Tier

GKE provides a **$74.40/month credit per billing account**, which covers the control plane management fee (~$0.10/hr) for one cluster. This effectively makes **one Autopilot or one Zonal Standard cluster free** per billing account.

**What the free tier covers:**
- Cluster management/control plane fee (~$0.10/hr)

**What you still pay for:**
- vCPU, memory, and ephemeral storage consumed by your pods
- Networking (egress, load balancers)
- Persistent storage (PVCs)

> The free tier credit is applied automatically by Google — no special configuration is needed in Terraform.

## Features

- Fully managed Autopilot mode (Google manages nodes)
- Always regional (high availability across zones)
- VPC-native networking (required by Autopilot)
- Configurable release channel for GKE version updates
- Deletion protection support

## Usage

Reference this module using a Git commit hash for version control:

```hcl
module "gke_autopilot" {
  # Pin to specific commit - check CHANGELOG.md for latest stable commits
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/gke_autopilot?ref=<commit-hash>"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  cluster_name = "my-cluster"
}
```

> **Finding the right commit:** Check this module's [CHANGELOG.md](./CHANGELOG.md) for stable commit hashes, or use `git log modules/gke_autopilot` to see recent changes.

### Minimal Example (Free Tier)

```hcl
module "gke_autopilot" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/gke_autopilot?ref=<commit-hash>"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  cluster_name = "my-cluster"
}
```

### Custom Network

```hcl
module "gke_autopilot" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/gke_autopilot?ref=<commit-hash>"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  cluster_name = "my-cluster"

  network    = "my-vpc"
  subnetwork = "my-subnet"
}
```

### Production Setup with Deletion Protection

```hcl
module "gke_autopilot" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/gke_autopilot?ref=<commit-hash>"

  project_id   = "my-gcp-project"
  region       = "europe-west1"
  cluster_name = "production-cluster"

  network    = "production-vpc"
  subnetwork = "gke-subnet"

  release_channel     = "STABLE"
  deletion_protection = true
}
```

### Connecting kubectl After Apply

```hcl
# Get cluster credentials after apply
# gcloud container clusters get-credentials <cluster_name> --region <region> --project <project_id>
```

Or configure the Kubernetes provider using module outputs:

```hcl
provider "kubernetes" {
  host  = "https://${module.gke_autopilot.cluster_endpoint}"
  token = data.google_client_config.default.access_token

  cluster_ca_certificate = base64decode(module.gke_autopilot.cluster_ca_certificate)
}

data "google_client_config" "default" {}
```

### Outputs Usage

```hcl
module "gke" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/gke_autopilot?ref=<commit-hash>"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "my-cluster"
}

output "cluster_name" {
  value = module.gke.cluster_name
}

output "cluster_location" {
  value = module.gke.cluster_location
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 5.0 |

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | The name of the GKE Autopilot cluster. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project_id](#input_project_id) | The unique ID of the GCP project. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion_protection](#input_deletion_protection) | Whether to enable deletion protection on the cluster. Set to false to allow Terraform to destroy the cluster. | `bool` | `false` | no |
| <a name="input_network"></a> [network](#input_network) | The name or self-link of the VPC network to use for the cluster. | `string` | `"default"` | no |
| <a name="input_region"></a> [region](#input_region) | The region where the GKE Autopilot cluster will be created. Autopilot clusters are always regional (not zonal). | `string` | `"us-central1"` | no |
| <a name="input_release_channel"></a> [release_channel](#input_release_channel) | The release channel for GKE version updates: 'RAPID', 'REGULAR', or 'STABLE'. | `string` | `"REGULAR"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input_subnetwork) | The name or self-link of the subnetwork to use for the cluster. | `string` | `"default"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster_ca_certificate](#output_cluster_ca_certificate) | The base64-encoded public certificate authority for the cluster. Used to authenticate with the Kubernetes API. |
| <a name="output_cluster_endpoint"></a> [cluster_endpoint](#output_cluster_endpoint) | The IP address of the cluster's Kubernetes API server endpoint. |
| <a name="output_cluster_id"></a> [cluster_id](#output_cluster_id) | The unique identifier of the GKE Autopilot cluster. |
| <a name="output_cluster_location"></a> [cluster_location](#output_cluster_location) | The region where the cluster is deployed. |
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name) | The name of the GKE Autopilot cluster. |
<!-- END_TF_DOCS -->

## IAM Permissions Required

The service account or user running Terraform must have the following permissions:

- `container.clusters.create`
- `container.clusters.get`
- `container.clusters.update`
- `container.clusters.delete`

These are included in the following predefined roles:
- `roles/container.admin`
- `roles/editor`
- `roles/owner`

## Notes

- **Autopilot API:** Ensure the Kubernetes Engine API (`container.googleapis.com`) is enabled in your project
- **Always Regional:** Autopilot clusters are regional — the `region` variable must be a region (e.g. `us-central1`), not a zone
- **Node Management:** You cannot manually configure node pools in Autopilot — GKE manages nodes automatically
- **VPC-Native:** Autopilot requires VPC-native (alias IP) networking. This module uses auto-assigned IP ranges by default
- **Workload Identity:** Workload Identity is automatically enabled in Autopilot clusters
- **Deletion Protection:** Defaults to `false` for easy iteration. Set to `true` for production clusters
- **Free Tier Limit:** Only one cluster per billing account receives the management fee credit. Running multiple clusters will incur the $0.10/hr fee for each additional cluster

## Release Channels

| Channel | Description |
|---------|-------------|
| `RAPID` | Latest GKE features and patches as soon as available. Best for testing new features |
| `REGULAR` | Generally available features; GKE's recommended default |
| `STABLE` | Most conservative updates. Best for production workloads requiring maximum stability |

## Related Resources

- [GKE Autopilot Overview](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [GKE Pricing](https://cloud.google.com/kubernetes-engine/pricing)
- [GKE Autopilot vs Standard](https://cloud.google.com/kubernetes-engine/docs/resources/autopilot-standard-feature-comparison)
- [Terraform google_container_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
