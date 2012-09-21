$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'wordpress_config_parser'))

require "wordpress_config_parser/version"


module WordpressConfigParser

  require 'wc_parser'
end
