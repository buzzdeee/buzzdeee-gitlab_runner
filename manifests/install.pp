# Here we install the runner and the
# init script

class gitlab_runner::install (

  $git_url = $::gitlab_runner::git_url,
  $git_revision = $::gitlab_runner::git_revision,

  # The user running the runner
  $user = $::gitlab_runner::user,
  $group = $::gitlab_runner::group,
  $home = $::gitlab_runner::home,
  $shell = $::gitlab_runner::shell,
  $uid = $::gitlab_runner::uid,
  $gid = $::gitlab_runner::gid,
  $install_dir = $::gitlab_runner::install_dir,
) {

  group { $group:
    gid => $gid,
  }
  user { $user:
    home  => $home,
    shell => $shell,
    uid   => $uid,
    gid   => $gid,
  }

  common::mkdir_p { dirname($install_dir):
    require => User[$user],
  }

  vcsrepo { $install_dir:
    ensure   => 'present',
    provider => 'git',
    source   => $git_url,
    revision => $git_revision,
    user     => $user,
    require  => Common::Mkdir_p[dirname($install_dir)],
  }

  exec { 'install_runner_deps':
    cwd         => $install_dir,
    command     => 'gmake deps',
    environment => [ "PATH=${home}/gocode/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/gocode:${home}/GIT",
                     "BUILD_PLATFORMS='-os openbsd'", ],
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Vcsrepo[$install_dir],
  }
  exec { 'build_runner':
    cwd         => $install_dir,
    command     => 'gmake build',
    environment => [ "PATH=${home}/gocode/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin",
                     "GOPATH=${home}/gocode:${home}/GIT",
                     "BUILD_PLATFORMS='-os openbsd'", ],
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Exec['install_runner_deps'],
  }
  exec { 'install_runner':
    cwd         => $install_dir,
    command     => '/usr/bin/install -o root -g bin -m 0755 out/binaries/gitlab-ci-multi-runner /usr/local/bin/gitlab-runner',
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
