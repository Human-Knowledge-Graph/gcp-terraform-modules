# Commit-Based Versioning Workflow

This document explains how to work with commit-based versioning in this repository.

## Overview

Each module is independently versioned using Git commit hashes. This allows:
- Different modules to evolve at different rates
- Fine-grained control over which version of each module you use
- No need for coordinated releases across all modules

## For Module Developers

### Initial Module Creation

```bash
# 1. Create your module
mkdir -p modules/my_module
cd modules/my_module

# 2. Create module files
touch main.tf variables.tf outputs.tf versions.tf README.md CHANGELOG.md

# 3. Implement your module
vim main.tf
# ... add your resources ...

# 4. Commit
git add modules/my_module/
git commit -m "feat: Add my_module for XYZ functionality"

# 5. Push to main
git push origin main

# 6. Get the commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "Initial commit: $COMMIT_HASH"

# 7. Update CHANGELOG.md with the commit hash
vim modules/my_module/CHANGELOG.md
```

Example CHANGELOG.md entry:
```markdown
## [Commit: abc123d] - 2026-01-08

### Added
- Initial release of my_module
- Support for feature X, Y, Z
```

### Making Updates to a Module

```bash
# 1. Make your changes
vim modules/static_ip/main.tf

# 2. Test locally
cd modules/static_ip
terraform init
terraform validate
cd ../..

# 3. Commit with descriptive message
git add modules/static_ip/
git commit -m "feat(static_ip): Add support for IPv6 addresses"

# 4. Push
git push origin main

# 5. Get commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "Update commit: $COMMIT_HASH"

# 6. Update CHANGELOG.md
vim modules/static_ip/CHANGELOG.md
```

Add entry:
```markdown
## [Commit: def456a] - 2026-01-10

### Added
- IPv6 address support
- New variable `ip_version` (default: "IPV4")

### Changed
- Updated provider requirement to >= 5.0
```

### Commit Message Conventions

Use conventional commit format:

```bash
# New features
git commit -m "feat(module_name): Add new feature"

# Bug fixes
git commit -m "fix(module_name): Fix specific issue"

# Documentation
git commit -m "docs(module_name): Update README"

# Breaking changes
git commit -m "feat(module_name)!: Breaking change description

BREAKING CHANGE: Detailed explanation of what broke"
```

## For Module Users

### Using Modules in Your Infrastructure

```hcl
# In your Terraform infrastructure code
module "static_ip" {
  # Pin to specific commit for stability
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=abc123d"

  project_id = var.project_id
  name       = "my-app-ip"
  region     = "us-central1"
}

# Each module can be at a different commit
module "vpc" {
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/vpc?ref=xyz789a"

  # ...
}
```

### Finding the Right Commit

**Method 1: Check module's CHANGELOG.md**

Browse to `modules/<module_name>/CHANGELOG.md` on GitHub or locally to see documented stable commits.

**Method 2: View Git history**

```bash
# Clone the repo
git clone https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git
cd gcp-terraform-modules

# View recent commits for a specific module
git log --oneline modules/static_ip

# Example output:
# abc123d feat(static_ip): Add IPv6 support
# def456a fix(static_ip): Fix regional IP bug
# 789xyz0 feat(static_ip): Initial release
```

**Method 3: Use GitHub web interface**

1. Go to the module directory on GitHub
2. Click "History" button
3. Copy commit hash from the commit you want

### Updating a Module in Your Infrastructure

```bash
# 1. Check current version in your code
grep "static_ip?ref=" main.tf
# module "static_ip" {
#   source = "...?ref=abc123d"

# 2. Check what's new in the module
cd path/to/gcp-terraform-modules
git log --oneline abc123d..HEAD modules/static_ip

# 3. Review changes
git diff abc123d HEAD modules/static_ip

# 4. Update your infrastructure code to new commit
vim main.tf
# Change: ?ref=abc123d to ?ref=def456a

# 5. Test in non-production first!
terraform init -upgrade
terraform plan

# 6. Apply if looks good
terraform apply
```

### Testing New Module Versions

Always test in a non-production environment:

```hcl
# production.tf (don't touch yet)
module "static_ip" {
  source = "...?ref=abc123d"  # Stable, tested version
}

# staging.tf (test here first)
module "static_ip" {
  source = "...?ref=def456a"  # New version being tested
}
```

### Documenting Module Versions

Add comments to track what you're using:

```hcl
module "static_ip" {
  # Version: Commit def456a from 2026-01-10
  # Includes: IPv6 support, bug fixes
  # Last updated: 2026-01-15
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=def456a"

  project_id = var.project_id
  name       = "my-app-ip"
}
```

## Practical Scenarios

### Scenario 1: Using Multiple Modules at Different Versions

```hcl
# Infrastructure code using 3 modules at different commits

module "static_ip" {
  # Latest version with IPv6
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/static_ip?ref=abc123d"
}

module "vpc" {
  # Older stable version, no need to update yet
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/vpc?ref=xyz789a"
}

module "gke_cluster" {
  # Beta version being tested
  source = "git::https://github.com/Human-Knowledge-Graph/gcp-terraform-modules.git//modules/gke_cluster?ref=testing123"
}
```

### Scenario 2: Emergency Rollback

```bash
# Your infrastructure broke after updating

# 1. Find the previous working commit from your version control
git log main.tf
# See previous ref: abc123d

# 2. Revert the module source
vim main.tf
# Change: ?ref=def456a back to ?ref=abc123d

# 3. Apply immediately
terraform init -upgrade
terraform apply
```

### Scenario 3: Gradual Module Updates

```bash
# You have 10 environments using the same module
# Update one at a time to minimize risk

# Week 1: Update dev
# dev/main.tf: ?ref=new_commit

# Week 2: Update staging
# staging/main.tf: ?ref=new_commit

# Week 3: Update production
# production/main.tf: ?ref=new_commit
```

## Tips and Tricks

### Quick Commit Hash Lookup

```bash
# Add this alias to your shell
alias tf-module-commits='git log --oneline --first-parent'

# Use it
tf-module-commits modules/static_ip
```

### Terraform Cache Management

```bash
# Clear module cache when switching commits
rm -rf .terraform/modules
terraform init -upgrade
```

### Find All Module References in Your Code

```bash
# Find all modules and their commits
grep -r "gcp-terraform-modules.git" . | grep "ref="
```

### Terraform Lockfile Benefits

Terraform automatically tracks module versions in `.terraform.lock.hcl`:

```hcl
# .terraform.lock.hcl
provider "registry.terraform.io/hashicorp/google" {
  version = "5.0.0"
  # ...
}
```

This ensures team members use the same versions.

## Common Issues

### Issue: "Module not found"

```
Error: Module not found
The module address "git::...?ref=abc123d" could not be resolved.
```

**Solution:** The commit hash doesn't exist. Double-check:
```bash
git log --all --grep="abc123d"
```

### Issue: "Changes detected after switching commits"

```
Terraform detected changes outside of Terraform
```

**Solution:** This is normal when switching commits. Review the changes carefully before applying.

### Issue: "Module cached at wrong version"

**Solution:** Clear module cache:
```bash
rm -rf .terraform/modules
terraform init -upgrade
```

## Best Practices Summary

### Do:
- ✅ Always pin to specific commits in production
- ✅ Document commit hashes in your infrastructure code
- ✅ Test new commits in non-production first
- ✅ Keep module CHANGELOG.md up to date
- ✅ Use meaningful commit messages
- ✅ Review module changes before updating

### Don't:
- ❌ Use `?ref=main` in production
- ❌ Update all modules at once
- ❌ Skip testing in staging
- ❌ Forget to run `terraform init -upgrade`
- ❌ Leave commit hashes undocumented
