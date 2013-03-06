bash "clone the web app" do
  install_dir = "/home/#{node[:user]}/dist/webapp"
  user node[:user]
  code <<-EOF
    mkdir -p #{install_dir}
    git clone "#{node[:webapp][:url]}" "#{install_dir}"
  EOF
  not_if "test -e #{install_dir}"
end

bash "update the web app" do
  user node[:user]
  install_dir = "/home/#{node[:user]}/dist/webapp"
  code <<-EOF
    cd #{install_dir}
    git pull
    /home/#{node[:user]}/bin/rubysetup
  EOF
end

