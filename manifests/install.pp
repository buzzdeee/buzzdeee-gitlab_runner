# Here we install the runner and the
# init script

class gitlab_runner::install (
  $log_facility = $::gitlab_runner::log_facility,
  $log_level = $::gitlab_runner::log_level,
  $user = $::gitlab_runner::user,
){
  package { 'gitlab-runner':
    ensure => 'installed'
  }

  file { "/etc/rc.d/gitlab_runner":
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template('gitlab_runner/gitlab_runner.erb'),
    require => Package['gitlab-runner'],
  }

}
