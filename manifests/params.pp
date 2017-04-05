# The default values of the
# module

class gitlab_runner::params {
  $git_url = 'https://gitlab.com/gitlab-org/gitlab-ci-multi-runner'
  $git_revision = 'HEAD'

  # The user running the runner
  $user = '_gitlab_runner'
  $group = '_gitlab_runner'
  $groups = '_gitlab'
  $home = '/home/gitlab_runner'
  $shell = '/bin/sh'
  $uid = '998'
  $gid = '998'
  $install_dir = '/home/gitlab_runner/GIT/src/gitlab.com/gitlab-org/gitlab-ci-multi-runner'
  $logfile = '/var/www/gitlab/gitlab/log/gitlab-runner.log'
  $loglevel = 'info'
}
