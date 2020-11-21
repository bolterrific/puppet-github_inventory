# Status which checks are required on each repo
plan github_inventory::required_checks(
  TargetSpec $targets = get_targets('repo_targets'),
  Sensitive[String[1]]  $github_api_token = Sensitive.new(system::env('GITHUB_API_TOKEN')),
){
  $results = run_task_with(
    'http_request',
    $targets,
    'Get status checks protection for all repos'
  ) |$target| {
    {
     'base_url' => "${target.facts['url']}/",
     'path'     => 'branches/master/protection/required_status_checks/contexts',
      'headers' => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true
    }
  }
  #  #  debug::break()
  out::message(format::table({
    title => 'Results',
    head  => ['Repo', 'Required checks'],
    rows  => $results.map |$r| {
      $body = $r.value['body'] =~ Array ? {
        true  => $r.value['body'].join(", "),
        false => String($r.value['body'])[0,60],
      }
      $checks = $r.value['body'] == ['WIP', 'Travis CI - Pull Request'] ? {
        false   => format::colorize( $body, 'warning' ),
        default => $body,
      }
      [ $r.target.name, $checks ]
    }
  }))

  return Hash($results.ok_set.map |$r| { [$r.target.name, $r.value['body']] } )
}
