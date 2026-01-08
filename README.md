# GCP Terraform Modules

A collection of reusable Terraform modules for Google Cloud Platform infrastructure.

## Overview

This repository contains production-ready Terraform modules designed to simplify and standardize GCP infrastructure deployment. Each module follows Terraform best practices and includes comprehensive documentation and examples.

**📚 New to commit-based versioning?** Read the [WORKFLOW.md](./WORKFLOW.md) guide for detailed examples and best practices.

## Available Modules

### Compute

- **[static_ip](./modules/static_ip)** - Create static IP addresses (regional or global, internal or external)

## Usage

### Using Modules in Your Infrastructure Code

Reference modules directly from this repository using Git commit hashes:

```hcl
module "static_ip" {
  # Pin to specific commit for stability
  source = "git::https://github.com/knaph/gcp-terraform-modules.git//modules/static_ip?ref=abc123d"

  project_id = "my-gcp-project"
  name       = "my-app-ip"
  region     = "us-central1"
}
```

### Versioning Strategy

This repository uses **commit-based versioning** where each module is versioned independently by Git commit hash.

**Why commit hashes?**
- Each module evolves at its own pace
- Pin different modules to different commits
- Fine-grained control over what you use

**How to find the right commit:**

1. Check the module's `CHANGELOG.md` for documented stable commits
2. View recent changes: `git log --oneline modules/<module_name>`
3. Find commit for specific change: `git log modules/<module_name>`

### Module Source Examples

```hcl
# Pinned to specific commit (recommended for production)
# Each module can be at a different commit
module "static_ip" {
  source = "git::https://github.com/knaph/gcp-terraform-modules.git//modules/static_ip?ref=abc123d"
}

module "vpc" {
  source = "git::https://github.com/knaph/gcp-terraform-modules.git//modules/vpc?ref=xyz789a"
}

# Using latest from main branch (development/testing only)
source = "git::https://github.com/knaph/gcp-terraform-modules.git//modules/static_ip?ref=main"

# Local development
source = "../gcp-terraform-modules/modules/static_ip"

# SSH authentication (for private repos)
source = "git::ssh://git@github.com/knaph/gcp-terraform-modules.git//modules/static_ip?ref=abc123d"
```

**Best practices:**
- Always pin to a specific commit in production
- Test new commits in non-production environments first
- Document which commits you're using in your infrastructure code
- Use `?ref=main` only for development/testing
- Update commits module-by-module as needed

## Module Structure

Each module follows a standard structure:

```
modules/<module_name>/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output value definitions
├── versions.tf       # Terraform and provider version constraints
├── README.md         # Module documentation and examples
└── CHANGELOG.md      # Version history with commit hashes
```

## Requirements

- Terraform >= 1.0
- GCP provider >= 4.0
- Authenticated GCP credentials

## Authentication

Modules do not handle GCP authentication. Authenticate using one of these methods:

```bash
# Application Default Credentials (recommended for local development)
gcloud auth application-default login

# Service Account Key (for CI/CD)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"

# Workload Identity (for GKE/Cloud Run)
# Configured automatically in GCP environments
```

## Contributing

### Adding a New Module

1. Create module directory: `modules/<module_name>/`
2. Add required files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `CHANGELOG.md`
3. Follow naming conventions (snake_case for variables, descriptive resource names)
4. Include usage examples in README
5. Document IAM permissions required
6. Test module locally
7. Commit and push
8. Document the initial commit hash in CHANGELOG.md

### Module Guidelines

- Always accept `project_id` as a variable
- Accept `region`/`zone` where applicable
- Never hard-code credentials, project IDs, or regions
- Use descriptive variable names with clear descriptions
- Validate inputs where appropriate
- Provide comprehensive outputs
- Include examples in module README
- Document required IAM permissions

## Testing Modules

### Local Testing

```bash
# Navigate to module directory
cd modules/static_ip

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Create test configuration
cat > test.tf <<EOF
module "test" {
  source = "./"

  project_id = "your-project-id"
  name       = "test-ip"
  region     = "us-central1"
}
EOF

# Plan
terraform plan

# Apply (creates real resources)
terraform apply

# Destroy
terraform destroy
```

### Validation Script

```bash
# Format all modules
terraform fmt -recursive

# Validate all modules
find modules -type f -name "versions.tf" -exec dirname {} \; | while read dir; do
  echo "Validating $dir"
  (cd "$dir" && terraform init -backend=false && terraform validate)
done
```

## Module Development Workflow

### Making Changes to a Module

```bash
# 1. Make your changes to the module
vim modules/static_ip/main.tf

# 2. Test locally
cd modules/static_ip
terraform init
terraform validate
terraform fmt

# 3. Commit your changes
git add modules/static_ip/
git commit -m "feat(static_ip): Add IPv6 support"

# 4. Update the module's CHANGELOG.md
vim modules/static_ip/CHANGELOG.md
# Add entry with commit hash after pushing

# 5. Push to main
git push origin main

# 6. Get the commit hash
git log -1 --format="%H"  # Full hash
git log -1 --format="%h"  # Short hash (7 chars)

# 7. Update module CHANGELOG.md with commit hash
# Document: "## [Commit: abc123d] - 2026-01-08"
```

### Finding Commit Hashes

```bash
# View recent commits for a specific module
git log --oneline modules/static_ip

# View detailed history with dates
git log --pretty=format:"%h - %an, %ar : %s" modules/static_ip

# Find commit that changed a specific file
git log modules/static_ip/main.tf

# Get full hash of latest commit
git rev-parse HEAD

# Get short hash of latest commit (7 chars)
git rev-parse --short HEAD
```

### Updating Module CHANGELOG

After pushing changes, update the module's CHANGELOG.md:

```markdown
## [Commit: abc123d] - 2026-01-08

### Added
- IPv6 support for regional addresses
- New variable `ip_version` to choose IPv4/IPv6

### Changed
- Updated `google` provider requirement to >= 5.0

### Fixed
- Fixed bug in global IP creation
```

## Best Practices

### For Module Developers

- Keep modules focused and single-purpose
- Use variables with sensible defaults
- Validate inputs to fail fast
- Provide clear, descriptive error messages
- Document all variables and outputs
- Include real-world usage examples
- Test modules before releasing

### For Module Users

- Always pin to specific commit hashes in production
- Review module documentation before use
- Check the module's CHANGELOG.md for stable commits
- Check required IAM permissions
- Test new commits in non-production environment first
- Document which commits you're using in your code comments
- Update modules independently as needed

## Support

For issues, questions, or contributions:
- Create an issue in this repository
- Follow the contribution guidelines
- Check existing issues before creating new ones

## License

[Add your license here]
