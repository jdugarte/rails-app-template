require "bundler/capistrano"

require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3-p286@APPNAME'
set :rvm_type, :system


set :application, "APPNAME"
set :repository,  "/Users/USERNAME/rails/APPNAME"

set :scm, :git

set :deploy_to, "/Users/USERNAME/Sites/APPNAME"

server "APPNAME.sytes.net", :app, :web, :db, :primary => true

default_run_options[:pty] = true


after "deploy:update_code", "deploy:migrate"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


namespace :rvm do
  desc 'Trust rvmrc file'
  task :trust_rvmrc do
    run "rvm rvmrc trust #{current_release}"
  end
end
 
after "deploy:update_code", "rvm:trust_rvmrc"
