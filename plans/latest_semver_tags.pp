# Report the highest SemVer tag for each repo (that has SemVer tags), including
# information release (if a release exists for that tag) and uploaded assets
#
# @note reports repos with "SemVer-ish" tags (includes `/^v/` and `/-d$/`)
#
# @param targets
#    Name of `github_inventory` Targets (or inventory group)
#
# @param github_api_token
#    GitHub API token.  Doesn't require any scope for public repos.
#
# @param display_result
#    When `true`, plan prints result using `out::message`
#
# @param return_result
#    When `true`, plan returns data in a ResultSet
#
plan github_inventory::latest_semver_tags(
  TargetSpec           $targets = 'github_repos',
  Sensitive[String[1]] $github_api_token = Sensitive.new(system::env('GITHUB_API_TOKEN')),
  Boolean $display_result = true,
  Boolean $return_result  = false,
){
  $github_repos = get_targets($targets)

  $tag_resultset = run_task_with(
    'http_request', $github_repos, "Get repos' tags from API"
  ) |$target| {
    {
      'base_url' => "${target.facts['tags_url']}",
      'method'   => 'get',
      'headers' => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true
    }
  }

  $release_results_hash = run_task_with(
    'http_request', $github_repos, "Get repos' releases from API"
  ) |$target| {
    {
      'base_url' => "${target.facts['releases_url'].regsubst(/\{\/id\}$/, '')}",
      'method'   => 'get',
      'headers' => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true
    }
  }.map |$r| {
    [ $r.target.name, $r ]
  }.with |$kv_pairs| {
    Hash($kv_pairs)
  }



  $repos_latest_tag_data = $tag_resultset.ok_set.map |$r| {
    # Find highest SemVer-ish (1.2.3, v1.2.3, 1.2.3-4) tag
    $tag = ($r.value['body'].map |$x| { $x['name'] }).filter |$x| {
      $x =~ /^v?\d+\.\d+\.\d+(-\d+)?$/
    }.max |$a, $b| {
      $semver_a = SemVer($a.regsubst(/^v/,'').regsubst(/-\d+$/,'')) # voxpupuli-style `v<SemVer>`
      $semver_b = SemVer($a.regsubst(/^v/,'').regsubst(/-\d+$/,'')) # RPM-style `-<release number>`
      compare($semver_a, $semver_b)
    }

    if $tag {
      $tag_data = $r.value['body'].filter |$x| { $x['name'] == $tag }[0]
      $release_for_tag = (
        $release_results_hash[$r.target.name].then |$rel_r| {
          $rel_r.value['body'].filter |$x| { $x['tag_name'] == $tag }
        }.lest || { [] }
      )[0]
      [$r.target.name, $tag_data + {'_release' => $release_for_tag }]
    } else { undef }
  }.filter |$x| { $x =~ NotUndef }.with |$x|{ Hash($x) }

  if $display_result {
    $table_rows = $repos_latest_tag_data.map |$k,$v| {
      $has_release = $v['_release'].empty ? {
        true    => format::colorize( 'no', 'warning' ),
        default => format::colorize( 'yes', 'good' ),
      }
      $release_assets = $v['_release'].lest || {{}}.with |$rel| { $rel['assets'].lest || {{}}.map |$a| { $a['name'] } }
      $release_assets_count = $release_assets.length ? {
        0       => '',
        default => $release_assets.length,
      }

      [ $k, $v['name'], $has_release, $release_assets_count ]
    }
    out::message(format::table({
      title => "${table_rows.size} Results",
      head  => ['Repo', 'Latest SemVer Tag', 'Has Release?', 'Release assets'],
      rows  => $table_rows,
    }))
  }

  if $return_result { return $repos_latest_tag_data }
}
