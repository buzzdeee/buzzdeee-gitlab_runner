# takes care of the service

class gitlab_runner::service (
) {

  service { 'gitlab_runner':
    ensure => 'running',
    enable => true,
  }
}
