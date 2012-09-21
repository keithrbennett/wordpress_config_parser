$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'wordpress_config_reader'))

require "wordpress_config_reader/version"


module WordpressConfigReader

  require 'wc_reader'
end
