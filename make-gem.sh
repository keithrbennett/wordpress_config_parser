gem uninstall wordpress_config_parser
rm wordpress_config_parser*gem
gem build wordpress_config_parser.gemspec
gem install wordpress_config_parser*gem

ruby -e "require 'wordpress_config_parser'; parser = WCParser.new('spec/resources'); puts parser.db_name; puts parser.db_name"

