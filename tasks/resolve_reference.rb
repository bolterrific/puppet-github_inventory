#!/opt/puppetlabs/bolt/bin/ruby
require_relative ENV['TASK_HELPER_RB'] || '../../ruby_task_helper/files/task_helper.rb'
#require_relative ENV['PLUGIN_HELPER_RB'] || '../../ruby_plugin_helper/lib/plugin_helper.rb'

require 'pathname'
require 'json'
require 'yaml'

class GithubOrg < TaskHelper
#  include RubyPluginHelper

  def task(name: nil, **kwargs)
    Dir["#{kwargs[:extra_gem_path]}/gems/*/lib"].each { |path| $LOAD_PATH << path } # for octokit

    org              = kwargs[:org]
    github_api_token = kwargs[:github_api_token]

    require 'octokit'
    Octokit.auto_paginate = true
    @client = Octokit::Client.new(
      access_token: github_api_token,
      connection_options: {
        headers: ['application/vnd.github.luke-cage-preview+json']
      }
    )
    repos = @client.org_repos(org)

    ## TODO: reject block_listed repos/patterns

    targets = repos.map do |repo|
      # FIXME: handle interpreters for non-linux OSes
      target = YAML.load <<~YAML
        name: #{repo['full_name']}
        features:
          - puppet-agent
        config:
          transport: local
          local:
            interpreters:
              '.rb': '/opt/puppetlabs/bolt/bin/ruby'
            # interpreters: <same as localhost tmpdir>
            # tmpdir: <same as localhost tmpdir>
        vars: {}
        facts: {}
      YAML
      target['facts'] = repo.to_hash
      target
    end
    { value: targets }
  end
end

GithubOrg.run if $PROGRAM_NAME == __FILE__

