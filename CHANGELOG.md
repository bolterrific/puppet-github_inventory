# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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

[Unreleased]: https://github.com/bolterrific/puppet-github_inventory/compare/0.2.0...HEAD
[0.1.0]: https://github.com/bolterrific/puppet-github_inventory/releases/tag/0.1.0
[0.2.0]: https://github.com/bolterrific/puppet-github_inventory/compare/0.1.0...0.2.0
