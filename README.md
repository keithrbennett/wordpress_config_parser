# WordpressConfigReader

Reads a Wordpress configuration file (wp-config.php) and
makes its define() data values easily accessible.

This is useful, for example, in the creation of a mysqldump command
without having to store config information in a second place, to avoid
wasted effort and risk of stale data.

The parsing algorithm is extremely primitive.

The Reader constructor will handle any of the following as its parameter

* an array of lines
* a filespec of a Wordpress config file
* a filespec of a directory containing a Wordpress config file
  ('wp-config.php' is assumed to be the file's name).

After instantiating a reader, you can access the variables defined
in the config file.  Here's a code example:

```ruby
require 'wordpress_config_reader'

reader = Reader.new('/Users/me/public_html/blog')
time_str = Time.now.strftime("%Y_%m_%d__%H%M%S")
outfilespec = "my-wp-db-backup-#{time_str}.sql" # (generate a good filespec)
command = """mysqldump -u#{reader.db_user} -p#{reader.db_password} \
    -h#{reader.db_hostname} #{reader.db_name} > outfilespec
puts `#{command} 2>&1`
puts `git add #{outfilespec} 2>&1`
puts `git commit -m "Added #{outfilespec}.

```

## Installation

Add this line to your application's Gemfile:

    gem 'wordpress_config_reader'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wordpress_config_reader

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
