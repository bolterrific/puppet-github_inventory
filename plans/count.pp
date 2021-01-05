# Example plan, prints number of Targets from inventory
#
# @param targets
#    By default: `repo_targets` group from inventory
#
plan github_inventory::count(
  TargetSpec $targets = 'repo_targets',
){
  $repo_targets = get_targets($targets)
  out::message( "Repos: ${targets.size}" )
}
