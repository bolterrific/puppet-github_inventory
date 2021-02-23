# Example plan, prints number of Targets from inventory
#
# @param targets
#    Name of `github_inventory` Targets (or inventory group)
#
plan github_inventory::count(
  TargetSpec $targets = 'github_repos',
){
  $github_repos = get_targets($targets)
  out::message( "Repos: ${github_repos.size}" )
}
