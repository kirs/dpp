worker_processes 4

deploy_to  = "/var/www/dpp"

rails_root = "#{deploy_to}/current"
pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file = "#{deploy_to}/shared/unicorn.sock"
log_file = "#{rails_root}/log/unicorn.log"
err_log = "#{rails_root}/log/unicorn.error.log"
old_pid    = pid_file + '.oldbin'

preload_app true

timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen socket_file, :backlog => 64
pid pid_file
stderr_path err_log
stdout_path log_file

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=) # from Max Rivero

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
