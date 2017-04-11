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
  $configure_puppetforge_yml = $::gitlab_runner::configure_puppetforge_yml,
  $puppetforge_user = $::gitlab_runner::puppetforge_user,
  $puppetforge_password = $::gitlab_runner::puppetforge_password,
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

  if $configure_puppetforge_yml {
    if !$puppetforge_user || !$puppetforge_password {
      fail("$::module_name must have 'puppetforge_user' and 'puppetforge_password' set")
    }
    file { "${home}/.puppetforge.yml":
      owner   => '0',
      group   => $group,
      mode    => '0640',
      content => template('gitlab_runner/puppetforge.yml.erb'),
    }
  }
}
