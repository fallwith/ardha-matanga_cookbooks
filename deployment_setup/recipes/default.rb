home = "/home/#{node[:user]}"

user node[:user] do
  supports :manage_home => true
  home home
  shell "/bin/bash"
end

["#{home}/dist",
 "#{home}/dist/shared",
 "#{home}/dist/shared/conf",
 "#{home}/dist/shared/data",
 "#{home}/dist/shared/log",
 "#{home}/dist/shared/pids",
 "#{home}/dist/shared/system",
 "#{home}/dist/shared/tmp",
 "#{home}/local",
 "#{home}/bin"].each do |dir|
  directory dir do
    owner node[:user] 
    mode '0755'
    action :create
  end
end

bash "add ~/bin to user #{node[:user]}'s PATH" do
  user node[:user] 
  bashrc = "#{home}/.bashrc"
  label = 'propagation system driven local bin path'
  code 'echo "PATH=\$PATH:\$HOME/bin # ' + label + %Q{" >>#{bashrc}}
  not_if %Q{grep -q "#{label}" #{bashrc}}
end

bash "add ./.binstubs to user #{node[:user]}'s PATH" do
  user node[:user] 
  bashrc = "#{home}/.bashrc"
  label = 'add support for local .binstubs dirs to PATH'
  code 'echo "PATH=./.binstubs:\$PATH # ' + label + %Q{" >>#{bashrc}}
  not_if %Q{grep -q "#{label}" #{bashrc}}
end

bash "configure user #{node[:user]}'s .bash_profile to call .bashrc" do
  user node[:user] 
  bashprofile = "#{home}/.bash_profile"
  label = 'source .bashrc if present'
  code 'echo "[ -f \$HOME/.bashrc ] && . \$HOME/.bashrc # ' + label + %Q{" >>#{bashprofile}}
  not_if %Q{grep -q "#{label}" #{bashprofile}}
end
