# Clone all repos into a local directory
#
# @param targets
#    By default: `repo_targets` group from inventory
#
# @param target_dir
#    Local directory to clone repos into
plan github_inventory::clone_git_repos(
  TargetSpec $targets = 'repo_targets',
  Stdlib::Absolutepath $target_dir = "${system::env('PWD')}/_repos",
){
  apply('localhost', '_description' => "Ensure target directory at '${target_dir}'"){
    file{ $target_dir: ensure => directory }
  }

  $repo_targets = get_targets($targets)
  $repo_targets.each |$target| {
    run_command("cd ${target_dir.shellquote}; git clone '${target.facts['clone_url']}' '${target.facts['_name']}'", 'localhost')
  }

  # This runs concurrently, but can be a LOT slower than just cloning the repos
  # with run_command in a loop:
  ###apply($repo_targets, '_description' => "Ensure targets are cloned into '${target_dir}'"){
  ###  vcsrepo{ "${target_dir}/${facts.get('_name')}":
  ###    ensure   => latest,
  ###    provider => 'git',
  ###    source   => $facts['clone_url'],
  ###  }
  ###}
}
