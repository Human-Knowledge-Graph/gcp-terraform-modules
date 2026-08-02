# Changelog - GitHub Actions Workload Identity Federation Module

All notable changes to this module will be documented in this file.

## [Unreleased] - 2026-08-02

### Added
- Initial release of github_actions_wic module
- Workload Identity Pool + OIDC Provider trusting token.actions.githubusercontent.com
- Service account with repository-scoped impersonation (attribute_condition
  restricts federation to a single named repository)
- Does not grant project IAM roles itself - the calling project's own
  Terraform is expected to grant the resulting service account whatever
  roles its workflow needs

<!--
Template for future updates:

## [Commit: HASH] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing features

### Fixed
- Bug fixes

### Breaking Changes
- Breaking changes (if any)

-->
