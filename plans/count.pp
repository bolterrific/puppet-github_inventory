# Example plan, prints number of Targets from inventory
#
# @param targets
#    Name of `github_inventory` Targets (or inventory group)
#
# @param display_result
#    When `true`, plan prints result using `out::message`
#
# @param return_result
#    When `true`, plan returns data in a ResultSet
#
plan github_inventory::count(
  TargetSpec $targets     = 'github_repos',
  Boolean $display_result = true,
  Boolean $return_result  = false,
){
  $github_repos = get_targets($targets)

  if $display_result {
    out::message( "Target count: ${github_repos.size}" )
  }

  if $return_result {
    return( { 'target_count' => $github_repos.size } )
  }
}
