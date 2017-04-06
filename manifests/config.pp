# this class configures the runner

class gitlab_runner::config (
  $concurrency = $::gitlab_runner::concurrency,
  $check_interval = $::gitlab_runner::check_interval,
  $runner_name = $::gitlab_runner::runner_name,
  $runner_url = $::gitlab_runner::runner_url,
  $runner_token = $::gitlab_runner::runner_token,
  $runner_executor = $::gitlab_runner::runner_executor,
  $home = $::gitlab_runner::home,
  $group = $::gitlab_runner::group,
) {
  file { "${home}/.gitlab-runner":
    ensure => 'directory',
  }  

  file { "${home}/.gitlab-runner/config.toml":
    owner   => '0',
    group   => $group,
    mode    => '0640',
    content => template('gitlab_runner/config.toml.erb'),
  }
}
