# github_inventory

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with github_inventory](#setup)
    * [What github_inventory affects](#what-github_inventory-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with github_inventory](#beginning-with-github_inventory)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module includes a Bolt plugin to generate `local` Transport Targets from a GitHub org's repositories.

## Setup

### What github_inventory affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For example, folks can probably figure out that your mysql_instance module affects their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* Files, packages, services, or operations that the module will alter, impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements

* [Puppet Bolt 2.15+][bolt], installed from an [OS package][bolt-install] (don't use the RubyGem)
* A GitHub API personal auth token with sufficient scope
* The [`octokit` RubyGem][octokit-rb]

### Beginning with github_inventory

1. If you are using [rvm], you **must disable it** before running bolt:

   ```sh
   rvm use system
   ```

2. Install the RubyGem deps using Bolt's `gem` command

   On most platforms:

   ```sh
   /opt/puppetlabs/bolt/bin/gem install --user-install -g gem.deps.rb
   ```

   On Windows:

   ```pwsh
   "C:/Program Files/Puppet Labs/Bolt/bin/gem.bat" install --user-install -g gem.deps.rb
   ```

3. (If using the example Bolt plans in this module)

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.

[octokit-rb]: https://github.com/octokit/octokit.rb
[bolt]: https://puppet.com/docs/bolt/latest/bolt.html
[bolt-install]: https://puppet.com/docs/bolt/latest/bolt_installing.html
[rvm]: https://rvm.io
