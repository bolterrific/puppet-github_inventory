# List and/or set which PR checks are required on each repo
#
# @param targets
#    By default: `github_repos` group from inventory
#
# @param github_api_token
#    GitHub API token.  By default, this will use the `GITHUB_API_TOKEN` environment variable.
#
# @param checks
#    Optional comma-delimited list of required PR Checks to set on all repos
#    If defined, this will overwrite ALL repos' required PR checks
#
plan github_inventory::required_checks(
  TargetSpec           $targets = 'github_repos',
  Sensitive[String[1]] $github_api_token = Sensitive.new(system::env('GITHUB_API_TOKEN')),
  Optional[String[1]]  $checks  = undef,
){
  $github_repos = get_targets($targets)

  if $checks.empty {
    $method = 'get'
    $body = undef
  } else {
    $method = 'put'
    $body = $checks.split(',')
  }

  $results = run_task_with(
    'http_request', $github_repos, "${method.capitalize} status checks protection"
  ) |$target| {
    {
      'base_url' => "${target.facts['url']}/",
      'method'   => $method,
      'body'     => $body,
      'path'     => "branches/${target.facts['default_branch']}/protection/required_status_checks/contexts",
      'headers' => {
        'Accept'        => 'application/vnd.github.v3+json',
        'Authorization' => "token ${github_api_token.unwrap}",
      },
      'json_endpoint' => true
    }
  }

  out::message(format::table({
    title => 'Results',
    head  => ['Repo', 'Required checks on default branch'],
    rows  => $results.map |$r| {
      unless $r.value['status_code'] == 200 {
        [$r.target.name, format::colorize( "${r.value['body']['message']}", 'red' )]
      } else {
        $body = $r.value['body'] =~ Array ? {
          true  => $r.value['body'].join(', '),
          false => String($r.value['body'])[0,60],
        }
        $checks = $r.value['body'].any |$x| { $x =~ /Travis|travis/ } ? {
          true    => format::colorize( $body, 'warning' ),
          default => $body,
        }
        [ $r.target.name, $checks ]
      }
    }
  }))

  # return Hash($results.ok_set.map |$r| { [$r.target.name, $r.value['body']] } )
}
