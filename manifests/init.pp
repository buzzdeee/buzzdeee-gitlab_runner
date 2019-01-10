# Class: gitlab_runner
# ===========================
#
# Full description of class gitlab_runner here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'gitlab_runner':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Sebastian Reitenbach <sebastia@l00-bugdead-prods.de>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class gitlab_runner (
  $git_url = $::gitlab_runner::params::git_url,
  $git_revision = $::gitlab_runner::params::git_revision,

  # The user running the runner
  $user = $::gitlab_runner::params::user,
  $group = $::gitlab_runner::params::group,
  $groups = $::gitlab_runner::params::groups,
  $home = $::gitlab_runner::params::home,
  $shell = $::gitlab_runner::params::shell,
  $uid = $::gitlab_runner::params::uid,
  $gid = $::gitlab_runner::params::gid,
  $install_dir = $::gitlab_runner::params::install_dir,
  $log_level = $::gitlab_runner::params::log_level,
  $log_facility = $::gitlab_runner::params::log_facility,
  $configure_puppetforge_yml = $::gitlab_runner::params::configure_puppetforge_yml,
  $puppetforge_password = undef,
  $puppetforge_user = undef,
  $concurrency = '1',
  $check_interval = '0',
  $runner_name = $::fqdn,
  $runner_url,
  $runner_token,
  $runner_executor,
) inherits gitlab_runner::params {

  include gitlab_runner::install
  include gitlab_runner::config
  include gitlab_runner::service

  Class['gitlab_runner::install'] ~>
  Class['gitlab_runner::config'] ~>
  Class['gitlab_runner::service']

}
