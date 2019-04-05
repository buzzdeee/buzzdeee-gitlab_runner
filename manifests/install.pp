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

  $pathelems = split($git_url, '/')

  File { "${home}/Go/src/${pathelems[2]}":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }
  File { "${home}/Go/src/${pathelems[2]}/${pathelems[3]}":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }

  vcsrepo { "${home}/Go/src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}":
    source   => $git_url,
    user     => $user,
    provider => 'git',
    require  => File["${home}/Go/src/${pathelems[2]}/${pathelems[3]}"],
  }

  exec { 'install_runner_deps':
    cwd         => "${home}/Go/src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}",
    user        => $user,
    command     => 'gmake deps',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    creates     => "${home}/Go/src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}/.gopath/bin/mockery",
    timeout     => 2000,
    require     => Vcsrepo["${home}/Go/src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}"],
  }
  exec { 'build_runner':
    cwd         => "${home}/Go/src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}",
    user        => $user,
    command     => 'gmake install',
    environment => [ "PATH=${home}/Go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/Go", ],
    timeout     => 2000,
    creates => "${home}/Go/src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}/.gopath/bin/gitlab-runner",
    require     => Exec['install_runner_deps'],
  }
  exec { 'install_runner':
    cwd     => "${home}/Go",
    command => "/usr/bin/install -o root -g bin -m 0755 src/${pathelems[2]}/${pathelems[3]}/${pathelems[4]}/.gopath/bin/gitlab-runner /usr/local/bin/gitlab-runner",
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
