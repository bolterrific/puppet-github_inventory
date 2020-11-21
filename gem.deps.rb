# Using bolt's packaged gem command, install with:
#
#
#  On most platforms:
#
#     /opt/puppetlabs/bolt/bin/gem install --user-install -g gem.deps.rb
#
#  On Windows:
#
#     "C:/Program Files/Puppet Labs/Bolt/bin/gem.bat" install --user-install -g gem.deps.rb
#
# See the following for reference:
#
# - https://puppet.com/docs/bolt/latest/bolt_installing.html#install-gems-in-bolts-ruby-environment
# - http://docs.ruby-lang.org/en/2.5.0/Gem/RequestSet/GemDependencyAPI.html
# - http://docs.ruby-lang.org/en/2.5.0/Gem/RequestSet/GemDependencyAPI.html#method-i-group
# - http://docs.ruby-lang.org/en/2.5.0/Gem/RequestSet/GemDependencyAPI.html#method-i-platform
# - http://docs.ruby-lang.org/en/2.5.0/Gem.html#method-c-use_gemdeps
#
source 'https://rubygems.org'

gem 'octokit', '~> 4.18'
gem 'puppet-debugger', '~> 1.0'
gem 'facterdb', ['>= 1.5.0', '< 2.0']
