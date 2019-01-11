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
  File { "${home}/Go/src":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }
  File { "${home}/Go/src/github.com":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }
  File { "${home}/Go/src/github.com/buzzdeee":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }

  vcsrepo { "${home}/Go/src/github.com/buzzdeee/gitlab-runner":
    source   => 'https://github.com/buzzdeee/gitlab-runner.git',
    user     => $user,
    provider => 'git',
    require  => File["${home}/Go/src/github.com/buzzdeee"],
  }

  exec { 'install_runner_deps':
    cwd         => "${home}/Go/src/github.com/buzzdeee/gitlab-runner",
    user        => $user,
    command     => 'gmake deps',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    creates     => "${home}/Go/src/gitlab.com/gitlab-org/gitlab-runner/.gopath/src/gitlab.com/gitlab-org",
    timeout     => 2000,
    require     => Vcsrepo["${home}/Go/src/github.com/buzzdeee/gitlab-runner"],
  }
  exec { 'build_runner':
    cwd         => "${home}/Go/src/github.com/buzzdeee/gitlab-runner",
    user        => $user,
    command     => 'gmake install',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    timeout     => 2000,
    creates => "${home}/Go/src/github.com/buzzdeee/gitlab-runner/.gopath/bin/gitlab-runner",
    require     => Exec['install_runner_deps'],
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
