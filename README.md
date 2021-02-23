# github_inventory

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
  * [Why is this useful?](#why-is-this-useful)
  * [How is this useful with Bolt?](#how-is-this-useful-with-bolt)
* [Setup](#setup)
  * [Setup Requirements](#setup-requirements)
  * [Beginning with github_inventory](#beginning-with-github_inventory)
* [Usage](#usage)
  * [Using the plugin in a Bolt inventory file](#using-the-plugin-in-a-bolt-inventory-file)
* [Reference](#reference)
* [Limitations](#limitations)
  * [Targets' `.facts` keys use `_name` instead of `name`](#targets-facts-keys-use-_name-instead-of-name)
  * [Limitations when running the example project](#limitations-when-running-the-example-project)
* [Development](#development)

<!-- vim-markdown-toc -->

## Description

**github_inventory** is an [inventory reference plugin] for [Puppet Bolt]. It
uses the GitHub API to dynamically provide a collection of [`local` transport]
Targets that represent each repository under a GitHub organization or user.

This module also contains an example Bolt project with a working
`inventory.yaml` and several [Bolt plans].

### Why is this useful?

Modeling GitHub repositories as Inventory Targets lets admins orchestrate
org-wide repo operations at scale, using simple & reusable [Bolt Plans].

### How is this useful with Bolt?

Simplicity, speed, and reusability:  It's trivial to define an inventory, and
Bolt plans are generally concise and legible.  And when using multiple Targets
(repos) with Bolt plan functions like `run_*()`/`parallelize()`, you get
concurrent execution  built-in for free. Plans are easy to wrap up in a module
and share, so the next time someone has to reset all the required PR checks in
a 200-repo org, they can just pull out the plan and run it on targets from
_their_ org.

Each `github_inventory` Target describes its repository in its `.facts`, using
the same keys as the data structure returned by GitHub's [`/orgs/{org}/repos`]
or [`/repos/{username}/repos`] endpoints (with [*one* important
exception](_name-vs-name)).

Targets use the [`local` transport] by default.  This keeps execution as
frictionless as possible and ensures that a known version of Ruby (the Bolt
interpreter's) is available to execute tasks.  It also also opens the door
to advanced uses, like git-cloning repos en masse into local working
directories and enforcing file conventions with Tasks and `apply()` blocks.

**Note:** Targets don't use the [`remote` Transport].  It can
only run [remote Tasks] (which rules out the built-in [`http_request`]) and
can't compile Puppet `apply()` blocks.

## Setup

### Setup Requirements

* [Puppet Bolt 3.0+ or 2.37][bolt], installed from an [OS package][bolt-install] (don't use the RubyGem)
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

   Set the environment variables `GITHUB_ORG` and `GITHUB_API_TOKEN` to
   appropriate values for your GitHub organization.  The API token needs a
   scope that can query the organization's repos.

## Usage

To use this plugin in your own Bolt project, configure it to provide `targets`
in the [inventory file].

### Using the plugin in a Bolt inventory file

An example `inventory.yaml` file:

```yaml
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

### Targets' `.facts` keys use `_name` instead of `name`
<a class="anchor" id="_name-vs-name"></a>

  * `github_inventory` Target facts use the key **`_name`** instead of the
    repo-level `name` key.
  * This avoids compilation errors in Puppet `apply()` blocks.

### Limitations when running the example project

In order to provide the example bolt project in the same module as the
inventory plugin, `modules/github_inventory/` is symlinked to the repo's
top-level directory.  This allows the bolt project to find the inventory
plugin, but there are some side-effects:

  * Bolt will emit a (benign) warning near the beginning of each run:

    ```
    The project 'github_inventory' shadows an existing module of the same name [ID: project_shadows_module]
    ```

  * Git may not establish the symlink properly for Windows users

This quirk only affects the example bolt project; it will not affect the
inventory plugin, or running the `github_inventory::` plans from your own Bolt
project.

## Development

Submit PRs on the project's GitHub page.

[Puppet Bolt]: https://puppet.com/docs/bolt/latest/bolt.html
[Bolt Plans]: https://puppet.com/docs/bolt/latest/plans.html
[Bolt Tasks]: https://puppet.com/docs/bolt/latest/tasks.html
[bolt]: https://puppet.com/docs/bolt/latest/bolt.html
[bolt-install]: https://puppet.com/docs/bolt/latest/bolt_installing.html
[inventory file]: https://puppet.com/docs/bolt/latest/inventory_file_v2.html
[inventory reference plugin]: https://puppet.com/docs/bolt/latest/using_plugins.html#reference-plugins
[`local` transport]: https://puppet.com/docs/bolt/latest/bolt_transports_reference.html#local
[`remote` transport]: https://puppet.com/docs/bolt/latest/bolt_transports_reference.html#remote
[octokit-rb]: https://github.com/octokit/octokit.rb
[rvm]: https://rvm.io
[`/orgs/{org}/repos`]: https://docs.github.com/en/rest/reference/repos#list-organization-repositories
[`/repos/{username}/repos`]: https://docs.github.com/en/rest/reference/repos#list-repositories-for-a-user
[`http_request`]: https://forge.puppet.com/modules/puppetlabs/http_request
[remote Tasks]: https://puppet.com/docs/bolt/latest/writing_tasks.html#writing-remote-tasks

