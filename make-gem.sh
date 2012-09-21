gem uninstall wordpress_config_reader
rm wordpress_config_reader*gem
gem build wordpress_config_reader.gemspec
gem install wordpress_config_reader*gem

ruby -e "require 'wordpress_config_reader'; reader = WCReader.new('spec/resources'); puts reader.db_name; puts reader.db_name"

