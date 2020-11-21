plan github_org(
  TargetSpec $targets = get_targets('repo_targets'),
  String[1]  $github_api_token = system::env('GITHUB_API_TOKEN'),
){
  $results = run_task_with(
    'http_request',
    $targets[0,2],
    'Check if vulnerability-alerts are enabled on each repo'
  ) |$target| {
    {
      'base_url'      => "${target.facts['url']}/branches/master/protection/required_status_checks/contexts",
      'method'        => 'get',
      'headers'       => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token $github_api_token",
      },
      'json_endpoint' => true
    }
  }
  # debug::break()

  Hash($results.ok_set.map |$r| { [$r.target.name, $r.value['body']] } )
}
