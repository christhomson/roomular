require 'bundler/vlad'

set :application, "roomular"
set :repository, "git@github.com:christhomson/roomular.git"
set :user, "deploy"
set :domain, "#{user}@roomular.cthomson.ca"
set :deploy_to, "/home/deploy/apps/roomular"
set :revision, "HEAD"

# On the server side, the upstart scripts (config/upstart) should be installed to /etc/init.
# We also need to allow the "[start|stop|restart] [thin|resque]" commands with no password for this user.

namespace :vlad do
  remote_task :symlink_config, :roles => :app do
    run "touch #{shared_path}/local.json; ln -s #{shared_path}/local.json #{release_path}/config/local.json"
  end

  namespace :node do
    remote_task :install do
      run "npm install"
    end
  end

  task :deploy => [
    "vlad:update",
    "vlad:symlink_config",
    "vlad:node:install",
    "vlad:cleanup"
  ]

  task :start => [
  ]
end