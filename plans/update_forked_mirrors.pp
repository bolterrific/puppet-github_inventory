# Update default branches & tags on forked GitHub repos
# (with an option to only affect Puppet module projects for a specific forge org)
#
# For each target repo (provided by `github_inventory` plugin):
#   * Clone repo
#   * (Optional) skip if repo is not a Puppet module for desired `forge_org`
#   * Add parent repo as remote, fetchparent's default branch and tags
#   * (Optional) skip if `noop` or repo is in `noop_repos`
#   * Push parent's default branch to repo (and push tags on branch)
#   * Ensure repo's default branch matches parent's default branch
#
# Target repos can be fine-tuned in the inventory by using the
# `allow_list`/`block_list` parameters in the `github_inventory` plugin
#
# @param targets
#    Name of `github_inventory` Targets (or inventory group)
#
# @param target_dir
#    Local directory to clone repos into (when clone_repos = true)
#
# @param noop
#    When true, all repos will run through all prep steps, but not push up
#    changes.
#
# @param noop_repos
#    List of specific repos to always treat as noop, even when noop=false
#
plan github_inventory::update_forked_mirrors(
  TargetSpec $targets                    = 'github_repos',
  Sensitive[String[1]] $github_api_token = Sensitive.new(system::env('GITHUB_API_TOKEN')),
  Boolean $clone_repos                   = true,
  Stdlib::Absolutepath $target_dir       = "${system::env('PWD')}/_repos",
  Optional[String[1]] $forge_org         = 'puppetlabs',
  Boolean $noop                          = true,
  Array[String,0] $noop_repos            = [],
){
  $github_repos = get_targets($targets)
  $forked_unarchived_github_repos = $github_repos.filter |$repo| {
    unless $repo.facts['fork'] {
      warning( "-- '${repo.name}' is not a fork; skipping"); next(false)
    }
    if $repo.facts['archived'] {
      warning( "-- '${repo.name}' is archived; skipping"); next(false)
    }
    true
  }

  if $clone_repos {
    $clone_results = run_plan('github_inventory::clone_git_repos', {
      'targets'            => $forked_unarchived_github_repos,
      'target_dir'         => $target_dir,
      'collision_strategy' => 'overwrite',
      'return_result'      => true,
      'clone_protocol'     => 'ssh',
    })
  }

  unless file::exists($target_dir) {
    fail_plan( "ERROR: repos target_dir '$target_dir' does not exist!  Have the repos not been cloned, or are they under some other directory?" )
  }

  $results = $forked_unarchived_github_repos.map |$repo| {
    $repo_dir = "${target_dir}/${repo.facts['_name']}"
    unless file::exists($repo_dir) {
      out::message("Repo dir not found: ${repo_dir}, skipping repo '${repo.facts['_name']}'!")
      next(false)
    }

    if $forge_org {
      $metadata_json_path = "${repo_dir}/metadata.json"
      unless file::exists($metadata_json_path) {
        out::message("WARNING: Not found: ${metadata_json_path}, skipping repo '${repo.facts['_name']}'!")
        next(false)
      }

      $mod_metadata = loadjson($metadata_json_path)
      $mod_forge_org = $mod_metadata['name'].split('-')[0]

      unless $mod_forge_org == $forge_org {
        warning("Repo module org ('${mod_forge_org}') does not match forge org '${forge_org}'; skipping ${repo.facts['_name']}")
        next(false)
      }
    }

    # A special case re: the "list all repos" GitHub API endpoint (which
    # provided the inventory repos' facts) doesn't include the parent repo's
    # info, so we query it here:
    $repo_info = run_task( 'http_request', $repo, "GET fork info", {
      'base_url' => "${repo.facts['url']}",
      'method'   => 'get',
      'headers' => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true
    })

    $parent_info = $repo_info[0].value['body']['parent']
    $rdb = $repo.facts['default_branch']
    $pdb = $parent_info['default_branch']

    if $parent_info['archived'] {
      warning "!!!!!!!!!! Parent repo ARCHIVED: ${parent_info['html_url']}"
      # unless $noop { debug::break() } # TODO log?
      next(false)
    }

    # Check out default branch & tags from parent (upstream) repo
    $git_pull_cmds = @("GIT_PULL_FROM_UPSTREAM_CMDS"/L)
       cd ${repo_dir.shellquote}
       if git remote | grep upstream; then
         git remote set-url upstream ${parent_info['clone_url']}
       else
         git remote add upstream ${parent_info['clone_url']}
       fi
       git fetch upstream
       git fetch upstream --tags
       git checkout upstream/${pdb}
       git checkout -B ${pdb}
       | GIT_PULL_FROM_UPSTREAM_CMDS
    $git_pull_result = run_command($git_pull_cmds, 'localhost', {'_catch_errors' => true})

    unless $git_pull_result[0].status == 'success' {
      $msg = [
        "ERROR: git fetch --tags/git pull ${pdb} from upstream failed for '${repo.name}'",
        "\n\n${git_pull_result[0].value.to_yaml}\n\n",
      ].join("\n")
      warning( $msg )
      next( $git_pull_result[0] )
    }

    $status = ($rdb == $pdb) ? { true => 'ok', default => '!!!! DIFFERENT !!!!' }
    $pull_msg = sprintf("%-35s | origin: %-6s | upstream: %-6s | $status", $repo.name, $rdb, $pdb)
    out::message($pull_msg)
    $result_data = {
      'default_branch'        => $rdb,
      'parent_default_branch' => $pdb,
      'pull_msg'              =>  $pull_msg,
    }

    if $repo.name in $noop_repos {
      out::message( "${repo.name}: NOOP REPO; not applying changes" )
      next( Result.new( $repo, $git_pull_result[0].value + {
        'extra' => $result_data + { 'skipped?' => 'repo marked as noop' }
      }))
    }

    if $noop {
      out::message( "NOOP: Dry run; not applying changes to any repo" )
      next( Result.new( $repo, $git_pull_result[0].value + {
        'extra' => $result_data + { 'skipped?' => 'global noop' }
      }))
    }

    # Push updated branch back to origin, with tags along that branch
    # git push --follow-tags origin <branch>
    $git_push_cmds = @("GIT_PUSH_TO_ORIGIN_CMDS"/L)
       cd ${repo_dir.shellquote}
       git push --follow-tags origin ${pdb}
       | GIT_PUSH_TO_ORIGIN_CMDS

    $git_push_result = run_command($git_push_cmds, 'localhost', {'_catch_errors' => true})

    unless $git_push_result[0].status == 'success' {
      $msg = [
        "ERROR: git push --follow-tags origin ${pdb} failed for '${repo.name}'",
        "\n\n${git_push_result[0].value.to_yaml}\n\n",
      ].join("\n")
      warning( $msg )
      next( Result.new( $repo, $git_push_result[0].value + {
        'extra' => $result_data
      }))
    }

    if $rdb == $pdb {
      out::message( "== ${repo.name} origin default branch '${rdb}' same as parent '${pdb}' ... done!" )
      next( Result.new( $repo, $git_push_result[0].value + {
        'extra' => $result_data
      }))
    }

    # Ensure repo's default branch matches parent repo
    $repo_db_result = run_task( 'http_request', $repo,
      "Ensure default branch of ${repo.name} is '$pdb' (currently", {
      'base_url'      => "${repo.facts['url']}",
      'method'        => 'patch',  # Needs https://github.com/puppetlabs/puppetlabs-http_request/pull/11
      'body'          => { 'default_branch' => $pdb },
      'headers'       => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true,
    })
    Result.new( $repo, $repo_db_result[0].value + {
      'extra' => $result_data
    })
  }.filter |$x| { $x }

  # Reporting
  # ----------------------------------------------------------------------------
  $fetch_ok_set = ResultSet.new($results).ok_set
  $fetch_error_set = ResultSet.new($results).error_set

  out::message( "\n\n" )
  out::message( "${fetch_ok_set.count} successesful" )
  ### debug::break()

  $fetch_ok_set.each |$r| { out::message("${r.value['extra']['pull_msg']}") }
  out::message( "${fetch_ok_set.filter |$r| { $r.value['extra']['default_branch'] != $r.value['extra']['parent_default_branch'] }.count  } forked mirrors have a different default branch than their parent\n\n" )
  out::message( "${fetch_error_set.count} errors" )
  out::message( $fetch_error_set.map |$r| { "${r.target.name}:\n${r.value['stderror']}" }.join("\n---------------------------------------------\n") )
  ### debug::break()

  $prep_only = $fetch_ok_set.filter |$x| { $x.value['extra']['skipped?'] == 'repo marked as prep-only' }
  out::message( "\n\n ${prep_only.count} repos skipped because they were marked as prep-only:" )
  out::message( $prep_only.map |$r| { "  - ${r.target.name}" }.join("\n") )

}
