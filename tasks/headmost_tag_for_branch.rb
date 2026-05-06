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

    github_api_token = kwargs[:github_api_token]
    full_repo_name   = kwargs[:repo]
    branch_name      = kwargs[:branch]
    with_release     = kwargs[:with_release]
    accept_header    = kwargs[:accept_header] || 'application/vnd.github.v3+json'

    require 'octokit'
    Octokit.auto_paginate = true
    @client = Octokit::Client.new(
      access_token: github_api_token,
      connection_options: {
        headers: [ accept_header ],
      },
    )
    @client.auto_paginate = true

    repo = @client.repo(full_repo_name)
    tags = @client.tags(repo.full_name)

    if with_release
      releases = @client.releases(repo.full_name)
      releases.reject!{|x| x.draft}
    end

    @client.auto_paginate = false
    # get commits for branch_name, and find the headmost tag

    commits = @client.commits(repo.full_name, {sha: branch_name})
    headmost_tag = nil
    headmost_release = nil


    loop do
      next_commit_page = @client.last_response.rels[:next] ? @client.last_response.rels[:next].href : nil
      commits.each do |c|
        t_ = tags.select{|t| t.commit.sha == c.sha }
        headmost_tag = t_.empty? ? nil : t_.first
        if with_release
          r_ = releases.select{|r| r.tag_name == headmost_tag.name }
          unless r_.empty?
            headmost_release = r_.first
            headmost_release['_tag_commit'] = headmost_tag.commit.sha
            headmost_release['_tag_data'] = headmost_tag
          end
          headmost_tag = nil unless headmost_release
        end
        break if headmost_tag
      end
      break if headmost_tag
      break unless next_commit_page
      commits = @client.commits(next_commit_page, {sha: branch_name})
    end

    result = nil
    if headmost_tag
      result = (headmost_release ? headmost_release : headmost_tag).to_h
    end
    result
  end
end

GithubOrg.run if $PROGRAM_NAME == __FILE__
