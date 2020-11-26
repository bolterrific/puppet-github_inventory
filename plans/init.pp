# Example plan, prints number of Targets from inventory
#
# @param targets
#    By default: `repo_targets` group from inventory
#
# @param github_api_token
#    GitHub API token.  By default, this will use the `GITHUB_API_TOKEN` environment variable.
#
plan github_inventory(
  TargetSpec $targets = get_targets('repo_targets'),
  String[1]  $github_api_token = system::env('GITHUB_API_TOKEN'),
){
  out::message( "Repos: ${targets.size}" )
}
