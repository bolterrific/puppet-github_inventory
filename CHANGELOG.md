# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


<!--
## [Unreleased]

### Added

### Changed

### Fixed

### Removed
-->

## [0.4.2] - 2021-07-19

### Fixed

* Slimmed down overwhelming amount of inconsequential user data returned by
  example plan `github_inventory::latest_semver_tags`


## [0.4.1] - 2021-07-19

### Fixed

* Fixed version comparison bug in example plan
  `github_inventory::latest_semver_tags`


## [0.4.0]

**Added**

* New example plan `github_inventory::update_forked_mirrors`, which keeps a
  forked repos' default branch & tags synced to its parent repo
* Add associated release data (if present) for tags returned by
  `github_inventory::latest_semver_tags`
* Use forge-based `puppet-debug` module

## [0.3.0]

**Added**

* New parameter `accept_header` in inventory plugin
* New parameters `collision_strategy`, `clone_protocol`, `return_result` in
  example plan `github_inventory::clone_git_repos`
* New parameters `display_result` and `return_result` in the example plan
  `github_inventory::latest_semver_tags`

**Fixed**

* Fixed misnamed variable in example plan `github_inventory::clone_git_repos`

## [0.2.1]

**Fixed**

* Fixed bug that caused String `$targets` to fail in the example plan
  `github_inventory::workflows` (by adding `get_targets()`)

**Changed**

* Renamed example `inventory.yaml` group to `github_repos` to play more nicely
  with other projects' `inventory.yaml`

## [0.2.0]

**Added**

* New example plan, `github_inventory::git_clone`, which clones repo Targets
  into a local directory.

**Changed**

* Renamed Target fact `name` to `_name` to prevent Bolt `apply()` Puppet
  compiles from failing with `Cannot reassign variable '$name'` errors

**Fixed**

* Fixed syntax and logic bugs in example plan `github_inventory::count`

## [0.1.0]

**Added**

* Initial project
* Inventory plugin that returns GitHub org repos as `local` transport Targets
* Example Bolt project with working Plans and `inventory.yaml`

[0.1.0]: https://github.com/bolterrific/puppet-github_inventory/releases/tag/0.1.0
[0.2.0]: https://github.com/bolterrific/puppet-github_inventory/compare/0.1.0...0.2.0
[0.2.1]: https://github.com/bolterrific/puppet-github_inventory/compare/0.2.0...0.2.1
[0.3.0]: https://github.com/bolterrific/puppet-github_inventory/compare/0.2.1...0.3.0
[0.4.0]: https://github.com/bolterrific/puppet-github_inventory/compare/0.3.0...0.4.0
[0.4.1]: https://github.com/bolterrific/puppet-github_inventory/compare/0.4.0...0.4.1
[0.4.2]: https://github.com/bolterrific/puppet-github_inventory/compare/0.4.1...0.4.2
[Unreleased]: https://github.com/bolterrific/puppet-github_inventory/compare/0.4.2...HEAD
