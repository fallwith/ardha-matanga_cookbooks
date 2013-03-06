recipe_version = '0.1'
root_profile = '/root/.profile'
root_profile_backup = root_profile + '.backup.' + recipe_version

bash "backup original #{root_profile}" do
  code "mv #{root_profile} #{root_profile_backup}"
  not_if "test -e #{root_profile_backup}"
end

template root_profile do
  mode 00644
  owner "root"
  group "root"
  source "root_profile"
  not_if "test -e #{root_profile_backup}"
end 

bash "run 'sudo apt-get update'" do
  code "sudo apt-get update"
end

package "build-essential"
package "libxml2"
package "libxml2-dev"
package "libxslt-dev"
package "imagemagick"
package "libmagickcore-dev"
package "libmagickwand-dev"
package "libssl-dev"
package "git"
