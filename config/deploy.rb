$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano' # 2 lines for capability with RVM
require 'bundler/capistrano'
# require 'thinking_sphinx/deploy/capistrano'
#set :rvm_ruby_string, '1.9.2'
set :rvm_type, :user # using rvm-per-user

set :application, "dpp"
set :rails_env, "production"
# set :domain, "mitwell@mitwell.iempire.ru:235"
set :domain, "mitwell@m2.iempire.tk"
set :repository,  "git@github.com:kirs/dpp.git"
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"
set :keep_releases, 3 # store only this number of releases

set :scm, :git
# set :scm_passphrase, "111222"

role :web, domain # Your HTTP server, Apache/etc
role :app, domain # This may be the same as your `Web` server
role :db, domain, :primary => true # This is where Rails migrations will run

set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{try_sudo} bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "[ -f #{unicorn_pid} ] && #{try_sudo} kill `cat #{unicorn_pid}` || true"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
  
  # From Max Rivero config - see http://pastie.org/2427209
  # desc "Preserve images"
  # task :symlink_images, :roles => :web do
  #   run "ln -sf #{deploy_to}/shared/uploads/filters #{latest_release}/public/images/filters"
  #   # run "ln -sf #{deploy_to}/shared/data #{latest_release}/public/data"
  #   # run "ln -sf #{deploy_to}/shared/pids #{latest_release}/tmp/pids"
  # end
  
  # Swap in the maintenance page
  # namespace :web do
  #   task :disable, :roles => :web do
  #     on_rollback { run "rm #{shared_path}/system/maintenance.html" }
  #     run "if [[ !(-f #{shared_path}/system/maintenance.html) ]] ; then ln -s #{shared_path}/system/maintenance.html.not_active #{shared_path}/system/maintenance.html ; else echo 'maintenance page already up'; fi"
  #   end
  # 
  #   task :enable, :roles => :web do
  #     run "rm #{shared_path}/system/maintenance.html"
  #   end
  # end
  
end

# to remove old releases
# see :keep_releases
after "deploy:update", "deploy:cleanup"