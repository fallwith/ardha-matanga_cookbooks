# TODO: it would nice to be able to perform set_namespace(:redis, :config)
# and have the key/val pairs reach node[:redis][:config][key] = val
set_namespace(:redis)
set_default(:config_yaml_file, "/home/#{node[:user]}/dist/shared/conf/redis.yml")
set_default(:dump_file, "/home/#{node[:user]}/dist/shared/data/dump.rdb")
set_default(:check_command, "#{node[:redis][:install_dir]}/bin/redis-cli PING")
set_default(:startup_check_loop_count, "10")
set_default(:startup_check_sleep_secs, "15")
set_default(:shared_dir, "/home/#{node[:user]}/dist/shared")

template node[:redis][:config_yaml_file] do
  mode 00744
  owner node[:user] 
  source "redis.yml.erb"
  variables :config => node[:redis] || {}
end
