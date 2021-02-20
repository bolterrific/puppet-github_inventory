# Example plan, prints number of Targets from inventory
#
# @param targets
#    By default: `github_repos` group from inventory
#
plan github_inventory::count(
  TargetSpec $targets = 'github_repos',
){
  $github_repos = get_targets($targets)
  out::message( "Repos: ${github_repos.size}" )
}
