#!/opt/puppetlabs/bolt/bin/ruby
# frozen_string_literal: true

require_relative ENV['TASK_HELPER_RB'] || '../../ruby_task_helper/files/task_helper.rb'

require 'pathname'
require 'json'
require 'yaml'

#
class GithubOrg < TaskHelper
  def task(name: nil, **kwargs)
    Dir["#{kwargs[:extra_gem_path]}/gems/*/lib"].each { |path| $LOAD_PATH << path } # for octokit

    org              = kwargs[:org]
    github_api_token = kwargs[:github_api_token]
    archived_repos   = kwargs[:archived_repos]
    private_repos    = kwargs[:private_repos]
    transport_type   = kwargs[:transport_type]
    block_list       = kwargs[:block_list]
    allow_list       = kwargs[:allow_list]

    require 'octokit'
    Octokit.auto_paginate = true
    @client = Octokit::Client.new(
      access_token: github_api_token,
      connection_options: {
        headers: ['application/vnd.github.luke-cage-preview+json'],
      },
    )

    repos = if @client.user(org)['type'] == 'User'
      @client.repos(org)
    else
      @client.org_repos(org)
    end

    repos.reject! do |repo|
      next(true) if repo.archived && !archived_repos
      next(true) if repo.private && !private_repos
      if block_list
        patterns = block_list.select { |item| item =~ %r{\A/.*/\Z} }
        next(true) if patterns.any? { |p| repo.name =~ Regexp.new(p.sub(%r{\A/}, '').sub(%r{/\Z}, '')) }
        next(true) if (block_list - patterns).any? { |block_str| repo.name == block_str }
      end
      next unless allow_list
      patterns = allow_list.select { |item| item =~ %r{\A/.*/\Z} }
      p_match = patterns.any? { |p| repo.name =~ Regexp.new(p.sub(%r{\A/}, '').sub(%r{/\Z}, '')) }
      s_match = (allow_list - patterns).any? { |allow_str| repo.name == allow_str }
      next(true) unless p_match || s_match
    end

    targets = repos.sort_by { |repo| repo.name }.map do |repo|
      target = YAML.safe_load <<~YAML
        name: '#{repo['name']}'
        features:
          - puppet-agent
        config:
          transport: '#{transport_type}'
        vars: {}
        facts: {}
      YAML
      target['facts'] = repo.to_hash

      # There cannot be a fact called 'name', or the Puppet compiler in `apply`
      # blocks will fail with the error `Cannot reassign variable '$name'`
      name = target['facts'].delete(:name)
      target['facts'][:_name] = name

      target
    end
    { value: targets }
  end
end

GithubOrg.run if $PROGRAM_NAME == __FILE__
