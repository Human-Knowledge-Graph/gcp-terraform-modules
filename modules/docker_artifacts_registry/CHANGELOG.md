# Changelog - Docker Artifacts Registry Module

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added
- `cleanup_policy_dry_run` variable to test cleanup policies without deleting
- `delete_older_than_days` variable to configure deletion threshold (default: 30 days)

### Changed
- Renamed internal resource from `my-repo` to `this` for consistency

## [Commit: fea94fb] - 2026-01-08

### Added
- Initial release of docker_artifacts_registry module
- Create Google Artifact Registry repository for Docker images
- Configurable cleanup policies for image lifecycle management
- Automatic deletion of tagged images after 30 days (configurable tags)
- Keep tagged release images forever (configurable tags)
- Keep minimum number of versions (configurable count)

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
