# Example plan, prints number of Targets from inventory
plan github_inventory(
  TargetSpec $targets = get_targets('repo_targets'),
  String[1]  $github_api_token = system::env('GITHUB_API_TOKEN'),
){
  out::message( "Repos: ${targets.size}" )
}
