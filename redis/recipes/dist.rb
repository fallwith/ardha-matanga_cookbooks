set_namespace(:redis)
set_default(:dist_dir, "/home/#{node[:user]}/dist/redis")

template "/home/#{node[:user]}/bin/redis" do
  mode 00755
  owner node[:user]
  source "bin_redis.erb"
  variables :dist => node[:redis] || {}
end

remote_directory node[:redis][:dist_dir] do
  owner node[:user]
  files_mode 00755
  files_owner node[:user]
  source "dist"
  action :create
  overwrite true
  purge true
end

bash "redis' bin/setup script" do
  code "sudo -iu #{node[:user]} /home/#{node[:user]}/bin/rubysetup #{node[:redis][:dist_dir]}"
end
