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
  $log_level = $::gitlab_runner::log_level,
  $log_facility = $::gitlab_runner::log_facility,
) {

  File { "${home}/Go":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }

  exec { 'go_get_gitlab_runner':
    user        => $user,
    cwd         => "${home}",
    command     => 'go get github.com/buzzdeee/gitlab-runner github.com/docker/go-units github.com/docker/spdystream || true',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    timeout     => 2000,
    creates     => "${home}/Go/src",
    require => File["${home}/Go"],
  }

  exec { 'install_runner_deps':
    cwd         => "${home}/Go/src/github.com/buzzdeee/gitlab-runner",
    user        => $user,
    command     => 'gmake deps',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    timeout     => 2000,
    require     => Exec['go_get_gitlab_runner'],
  }
  exec { 'move_docker_deps':
    command => "mv ${home}/Go/src/github.com/docker ${home}/Go/src/github.com/buzzdeee/gitlab-runner/.gopath/src/github.com",
    user    => $user,
    cwd     => "${home}",
    creates => "${home}/Go/src/github.com/buzzdeee/gitlab-runner/.gopath/src/github.com/docker",
    require => Exec['install_runner_deps'],
  }

  exec { 'build_runner':
    cwd         => "${home}/Go/src/github.com/buzzdeee/gitlab-runner",
    user        => $user,
    command     => 'gmake install',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    timeout     => 2000,
    creates => "${home}/Go/src/github.com/buzzdeee/gitlab-runner/.gopath/bin/gitlab-runner",
    require     => Exec['move_docker_deps'],
  }
  exec { 'install_runner':
    cwd     => "${home}/Go",
    command => "/usr/bin/install -o root -g bin -m 0755 src/github.com/buzzdeee/gitlab-runner/.gopath/bin/gitlab-runner /usr/local/bin/gitlab-runner",
    creates => '/usr/local/bin/gitlab-runner',
    require => Exec['build_runner'],
  }

  file { "/etc/rc.d/gitlab_runner":
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template('gitlab_runner/gitlab_runner.erb'),
    require => Exec['install_runner'],
  }

}
