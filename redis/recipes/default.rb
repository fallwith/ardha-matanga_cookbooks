include_recipe 'fallwith_helpers'

set_namespace(:redis)
set_default(:version,      "2.6.7")
set_default(:install_root, "/home/#{node[:user]}/local")
set_default(:config_file,  "/home/#{node[:user]}/dist/shared/conf/redis.conf")
set_default(:source_url,   "http://redis.googlecode.com/files/redis-#{node[:redis][:version]}.tar.gz")

set_default(:install_dir, File.join(node[:redis][:install_root], "redis_#{node[:redis][:version]}"))

package "curl"
package "build-essential"
package "tar"

bash "install redis #{node[:redis][:version]} from source" do
  cwd "/tmp"
  user node[:user] 
  code <<-EOF
    curl -O #{node[:redis][:source_url]}
    tar xzf redis-#{node[:redis][:version]}.tar.gz
    cd redis-#{node[:redis][:version]}
    make
    make PREFIX=#{node[:redis][:install_dir]} install
    cd ..
    rm -rf redis-#{node[:redis][:version]}*
  EOF
  not_if "test -e #{node[:redis][:install_dir]}"
end

template node[:redis][:config_file] do
  mode 00744
  owner node[:user]
  source "redis.conf.erb"
  variables :config => node[:redis][:config] || {}
end

include_recipe "redis::dist"
include_recipe "redis::config"
