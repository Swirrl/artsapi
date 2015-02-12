rails_env = ENV['RAILS_ENV'] || 'production' 
worker_processes (rails_env == 'production' ? 30 : 4)
timeout 120
preload_app true

RAILS_ROOT = "/artsapi"

stderr_path RAILS_ROOT + "/log/unicorn.log"
stdout_path RAILS_ROOT + "/log/unicorn.log"

# TODO: use sockets to link to nginx, something like

# The path below is assumed to be /path/to/app/tmp/foo

# NGINX config.conf - use UNIX socket
# upstream artsapi {
#   server unix:/artsapi/tmp/unicorn/sockets/unicorn.sock;
# }

# Uncomment this line - backlog default is 1024
listen (RAILS_ROOT + '/tmp/unicorn/sockets/unicorn.sock'), :backlog => 2048

# Mount the folder that contains the unix sockets in the app Dockerfile and include volumes from the app in the nginx Docker
# VOLUME ["/open_data_communities/tmp/unicorn/sockets"]

#listen 8080

pid RAILS_ROOT + "/tmp/unicorn/pids/unicorn.pid"

before_fork do |server, worker|

  # Close connections that require sockets
  old_pid = RAILS_ROOT + '/tmp/unicorn/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # Start connections that require sockets
end