# Report the highest SemVer tag for each repo (that has SemVer tags)
#
# @note ONLY reports repos with SemVer tags (ignores `/^v/` and `/-d$/`)
#
# @param targets
#    By default: `repo_targets` group from inventory
#
# @param github_api_token
#    GitHub API token.  By default, this will use the `GITHUB_API_TOKEN` environment variable.
#
plan github_inventory::latest_semver_tags(
  TargetSpec           $targets = 'repo_targets',
  Sensitive[String[1]] $github_api_token = Sensitive.new(system::env('GITHUB_API_TOKEN')),
){
  $repo_targets = get_targets($targets)

  $results = run_task_with(
    'http_request', $repo_targets, "Get repos' info from API"
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

  $a_results = $results.ok_set.map |$r| {
    $tag = ($r.value['body'].map |$x| { $x['name'] }).filter |$x| {
      $x =~ /^v?\d+\.\d+\.\d+(-\d+)?$/
    }.max |$a, $b| {
      $semver_a = SemVer($a.regsubst(/^v/,'').regsubst(/-\d+$/,'')) # voxpupuli-style `v<SemVer>`
      $semver_b = SemVer($a.regsubst(/^v/,'').regsubst(/-\d+$/,'')) # RPM-style `-<release number>`
      compare($semver_a, $semver_b)
    }
    if $tag { [$r.target.name, $tag] } else { undef }
  }.filter |$x| { $x =~ NotUndef }
  $h_results = Hash($a_results)

  out::message(format::table({
    title => "${h_results.size} Results",
    head  => ['Repo', 'Latest SemVer Tag'],
    rows  => $h_results.map |$k,$v| { [$k, $v] }
  }))
}
