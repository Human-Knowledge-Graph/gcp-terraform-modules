# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains Terraform modules for Google Cloud Platform (GCP) infrastructure.

## Terraform Module Structure

Each module should follow standard Terraform conventions:
- `main.tf` - Primary resource definitions
- `variables.tf` - Input variable declarations
- `outputs.tf` - Output value definitions
- `versions.tf` - Terraform and provider version constraints
- `README.md` - Module documentation with usage examples

## Common Commands

### Terraform Operations
```bash
# Initialize Terraform (run after cloning or adding new modules)
terraform init

# Validate configuration syntax
terraform validate

# Format all .tf files to canonical format
terraform fmt -recursive

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

### Testing and Validation
```bash
# Format check (for CI/CD)
terraform fmt -check -recursive

# Validate all modules
find . -type f -name "*.tf" -exec dirname {} \; | sort -u | xargs -I {} sh -c 'cd {} && terraform init -backend=false && terraform validate'

# Run terraform test for every module that has tests, anywhere in the repo
# (matches the discovery logic in .github/workflows/ci.yml, including nested
# module paths like modules/observability/*/* that `make validate`/`make docs`
# do not reach)
./scripts/test-all-modules.sh
```

## Module Development Guidelines

### Variable Naming
- Use snake_case for variable names
- Prefix boolean variables with `enable_` or `create_`
- Use descriptive names that indicate purpose

### Resource Naming
- Use consistent naming patterns across modules
- Include environment/purpose context in resource names
- Follow GCP naming constraints (lowercase, hyphens)

### Documentation
- Every variable must have a description
- Include examples in module README
- Document any GCP API requirements or permissions needed
- Specify required provider versions

## GCP-Specific Considerations

### Authentication
Modules should not hard-code credentials. Users should authenticate via:
- `gcloud auth application-default login`
- Service account key files
- Workload Identity (in GKE/Cloud Run)

### Project and Region
- Always accept `project_id` as a variable
- Accept `region` and/or `zone` as variables where applicable
- Do not hard-code project IDs or regions

### IAM and Permissions
- Document required IAM permissions for module execution
- Use principle of least privilege
- Prefer predefined roles over custom roles where possible
