# Return repos with GitHub Actions workflows
#
# @param targets
#    By default: `github_repos` group from inventory
#
# @param github_api_token
#    GitHub API token.  By default, this will use the `GITHUB_API_TOKEN` environment variable.
#
plan github_inventory::workflows(
  TargetSpec           $targets = get_targets('github_repos'),
  Sensitive[String[1]] $github_api_token = Sensitive.new(system::env('GITHUB_API_TOKEN')),
){
  $github_repos = get_targets($targets)
  $results = run_task_with(
    'http_request', $targets, 'Find repos with GitHub Actions workflows'
  ) |$target| {
    {
      'base_url' => "${target.facts['url']}/",
      'path'     => 'actions/workflows',
      'headers' => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true
    }
  }.filter |$r| { $r.value['status_code'] == 200 and $r.value['body']['total_count'] > 0  }

  out::message(format::table({
    title => 'Results',
    head  => ['Repo', 'Workflows'],
    rows  => $results.map |$r| { [ $r.target.name, $r.value['body']['total_count'] ] }
  }))

}
