# The default values of the
# module

class gitlab_runner::params {
  $git_url = 'https://github.com/buzzdeee/gitlab-runner'
  $git_revision = 'HEAD'

  # The user running the runner
  $user = '_gitlabrunner'
  $group = '_gitlabrunner'
  $groups = '_gitlab'
  $home = '/home/_gitlabrunner'
  $shell = '/bin/sh'
  $uid = '998'
  $gid = '998'
  $install_dir = '/home/_gitlab_runner/GIT/src/gitlab.com/gitlab-org/gitlab-ci-multi-runner'
  $log_file = '/var/www/gitlab/gitlab/log/gitlab-runner.log'
  $log_level = 'info'

  $configure_puppetforge_yml = false

}
