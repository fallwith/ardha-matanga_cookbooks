bash "install rbenv for user #{node[:user]}" do
  install_dir = "/home/#{node[:user]}/.rbenv"
  user node[:user]
  code <<-EOF
  	git clone git://github.com/sstephenson/rbenv.git #{install_dir}
  	mkdir -p #{install_dir}/plugins
  	git clone git://github.com/sstephenson/ruby-build.git #{install_dir}/plugins/ruby-build
  EOF
  not_if "test -e #{install_dir}"
end

bash "configure user #{node[:user]}'s .bash_profile to initialize rbenv" do
  user node[:user] 
  bashprofile = "/home/#{node[:user]}/.bash_profile"
  label = 'init rbenv if present'
  addition = <<-EOF

# #{label}
if [ -s \"\$HOME/.rbenv/bin\" ]; then
  export PATH=\"\$HOME/.rbenv/bin:\$PATH\"
  eval \"\$(rbenv init -)\"
fi
  EOF
  code %Q{echo '#{addition}' >>#{bashprofile}}
  not_if %Q{grep -q "#{label}" #{bashprofile}}
end

remote_file "/home/#{node[:user]}/bin/rubysetup" do
  owner node[:user]
  mode 00755
  owner node[:user]
  source "rubysetup"
  action :create
  checksum "de6de56a144f0f2ff4bf8a0c7a2c9354cade6a5a"
end
