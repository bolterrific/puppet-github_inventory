# Report the highest SemVer tag for each repo (that has SemVer tags)
#
# @note ONLY reports repos with SemVer tags (ignores `/^v/` and `/-d$/`)
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

  $results = run_task_with(
    'http_request', $github_repos, "Get repos' info from API"
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

  $h_results = $results.ok_set.map |$r| {
    $tag = ($r.value['body'].map |$x| { $x['name'] }).filter |$x| {
      $x =~ /^v?\d+\.\d+\.\d+(-\d+)?$/
    }.max |$a, $b| {
      $semver_a = SemVer($a.regsubst(/^v/,'').regsubst(/-\d+$/,'')) # voxpupuli-style `v<SemVer>`
      $semver_b = SemVer($a.regsubst(/^v/,'').regsubst(/-\d+$/,'')) # RPM-style `-<release number>`
      compare($semver_a, $semver_b)
    }
    if $tag {
      $tag_data = $r.value['body'].filter |$x| { $x['name'] == $tag }[0]
      [$r.target.name, $tag_data ]
    } else { undef }
  }.filter |$x| { $x =~ NotUndef }.with |$x|{ Hash($x) }


  if $display_result {
    $tag_results = $h_results.map |$k,$v| { [$k, $v['name']] }.with |$x| { Hash($x) }
    out::message(format::table({
      title => "${tag_results.size} Results",
      head  => ['Repo', 'Latest SemVer Tag'],
      rows  => $tag_results.map |$k,$v| { [$k, $v] }
    }))
  }

  if $return_result { return $h_results }
}
