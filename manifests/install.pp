# Here we install the runner and the
# init script

class gitlab_runner::install (

  $git_url = $::gitlab_runner::git_url,
  $git_revision = $::gitlab_runner::git_revision,

  # The user running the runner
  $user = $::gitlab_runner::user,
  $group = $::gitlab_runner::group,
  $groups = $::gitlab_runner::groups,
  $home = $::gitlab_runner::home,
  $shell = $::gitlab_runner::shell,
  $uid = $::gitlab_runner::uid,
  $gid = $::gitlab_runner::gid,
  $install_dir = $::gitlab_runner::install_dir,
  $log_file = $::gitlab_runner::log_file,
  $log_level = $::gitlab_runner::log_level,
) {

  group { $group:
    gid => $gid,
  }
  user { $user:
    home   => $home,
    shell  => $shell,
    uid    => $uid,
    gid    => $gid,
    groups => $groups,
  }

  common::mkdir_p { "${home}/Go/src/gitlab.com/gitlab-org"
    require => User[$user],
  }

  exec { "gitlab_runner_chown_godir":
    command  => "chown -R ${user} ${home}/Go/"
    owner   => $user,
    group   => $group,
    require => User[$user],
  }

  vcsrepo { $install_dir:
    ensure   => 'present',
    provider => 'git',
    source   => $git_url,
    revision => $git_revision,
    user     => $user,
    require  => Common::Mkdir_p["${home}/Go/src/gitlab.com/gitlab-org"],
  }

  exec { 'install_runner_deps':
    cwd         => "${home}/Go/src/gitlab.com/gitlab-org/gitlab-runner",
    command     => 'gmake deps',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Vcsrepo[$install_dir],
  }
  exec { 'build_runner':
    cwd         => $install_dir,
    command     => 'gmake install',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Exec['install_runner_deps'],
  }
  exec { 'install_runner':
    cwd         => "${home}/Go",
    command     => "/usr/bin/install -o root -g bin -m 0755 src/gitlab.com/gitlab-org/gitlab-runner/.gopath/bin/gitlab-runner /usr/local/bin/gitlab-runner",
    refreshonly => true,
    subscribe   => Exec['build_runner'],
  }

  file { "/etc/rc.d/gitlab_runner":
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template('gitlab_runner/gitlab_runner.erb'),
    require => Exec['install_runner'],
  }

}
