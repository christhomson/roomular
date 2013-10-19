require 'bundler/vlad'

set :application, "roomular"
set :repository, "git@github.com:christhomson/roomular.git"
set :user, "deploy"
set :domain, "#{user}@roomular.cthomson.ca"
set :deploy_to, "/home/deploy/apps/roomular"
set :revision, "origin/master"

# On the server side, the upstart scripts (config/upstart) should be installed to /etc/init.
# We also need to allow the "[start|stop|restart] roomular" commands with no password for this user.

namespace :vlad do
  remote_task :symlink_config, :roles => :app do
    run "touch #{shared_path}/local.json; ln -s #{shared_path}/local.json #{release_path}/config/local.json"
  end

  namespace :node do
    remote_task :install, :roles => :app do
      run "cd #{latest_release}; npm install"
    end

    remote_task :start, :roles => :app do
      puts "Starting node..."
      sudo "start roomular"
    end

    remote_task :stop, :roles => :app do
      puts "Attempting to stop node..."
      sudo "stop roomular"
    end

    remote_task :restart, :roles => :app do
      puts "Restarting node..."
      sudo "restart roomular"
    end
  end

  task :deploy => [
    "vlad:update",
    "vlad:symlink_config",
    "vlad:node:install",
    "vlad:node:restart",
    "vlad:cleanup"
  ]

  task :start => [
    "vlad:node:restart"
  ]
end