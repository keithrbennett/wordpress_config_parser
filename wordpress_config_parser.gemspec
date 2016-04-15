# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordpress_config_parser/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Keith Bennett"]
  gem.email         = ["keithrbennett@gmail.com"]
  gem.description   = %q{Gets values defined in Wordpress wp-config.php file.}
  gem.summary       = %q{Gets values defined in Wordpress wp-config.php file.}
  gem.homepage      = "https://github.com/keithrbennett/wordpress_config_parser"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordpress_config_parser"
  gem.require_paths = ["lib"]
  gem.version       = WordpressConfigParser::VERSION

  gem.add_development_dependency "rspec", '~> 3.0'

end
