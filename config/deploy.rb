# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

app = "snitch"

set :application, app

set :user, "flexibleplan"
set :deploy_to, "/var/www/#{app}"
set :repo_url, "git@github.com:AnthonyHewins/snitch.git"

set :default_stage, :production

set :keep_releases, 2

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp


# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
