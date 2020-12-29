# github_inventory

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
  * [Setup Requirements](#setup-requirements)
  * [Beginning with github_inventory](#beginning-with-github_inventory)
* [Usage](#usage)
  * [Using the plugin in a Bolt inventory file](#using-the-plugin-in-a-bolt-inventory-file)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)

<!-- vim-markdown-toc -->

## Description

**github_inventory** is an [inventory reference plugin] for [Puppet
Bolt]. It uses the GitHub API to dynamically provide a list of [`local`
transport] Targets that represent each repository under a GitHub org.

This module also contains an example Bolt project with a working
`inventory.yaml` and several Bolt plans.

## Setup

### Setup Requirements

* [Puppet Bolt 2.15+][bolt], installed from an [OS package][bolt-install] (don't use the RubyGem)
  * **Note:** The example `inventory.yaml` assumes Bolt 2.37+ (see comments)
* A GitHub API personal auth token with sufficient scope
* The [`octokit` RubyGem][octokit-rb]

### Beginning with github_inventory

1. If you are using [rvm], you **must disable it** before running bolt:

   ```sh
   rvm use system
   ```

2. Install the RubyGem dependencies using Bolt's `gem` command

   On most platforms:

   ```sh
   /opt/puppetlabs/bolt/bin/gem install --user-install -g gem.deps.rb
   ```

   On Windows:

   ```pwsh
   "C:/Program Files/Puppet Labs/Bolt/bin/gem.bat" install --user-install -g gem.deps.rb
   ```

3. (If using the example Bolt plans in this module)

## Usage

To use this plugin in your own Bolt project, configure it to provide `targets`
in the [inventory file].

### Using the plugin in a Bolt inventory file

An example `inventory.yaml` file:

```yaml
version: 2

groups:
  - name: repo_targets
    targets:
      - _plugin: github_inventory  # <- Plugin provides `local` Targets
        org: simp                  # <- GitHub org with Target repos
        github_api_token:          # <- API token with scope that can get repos
          _plugin: env_var         # <- (provided by another Bolt plugin)
          var: GITHUB_API_TOKEN

config:
  transport: local
  local:
    interpreters:
      .rb: /opt/puppetlabs/bolt/bin/ruby
    tmpdir:
     _plugin: env_var
     var: PWD

```

## Reference

See [REFERENCE.md](./REFERENCE.md)


## Limitations

FIXME In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

FIXME In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

[bolt]: https://puppet.com/docs/bolt/latest/bolt.html
[bolt-install]: https://puppet.com/docs/bolt/latest/bolt_installing.html
[inventory file]: https://puppet.com/docs/bolt/latest/inventory_file_v2.html
[inventory reference plugin]: https://puppet.com/docs/bolt/latest/using_plugins.html#reference-plugins
[`local` transport]: https://puppet.com/docs/bolt/latest/bolt_transports_reference.html#local
[octokit-rb]: https://github.com/octokit/octokit.rb
[Puppet Bolt]: https://puppet.com/docs/bolt/latest/bolt.html
[rvm]: https://rvm.io
