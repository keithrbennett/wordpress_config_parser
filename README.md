# WordpressConfigReader

Reads a Wordpress configuration file (wp-config.php) and
makes its define() data values easily accessible.

This is useful, for example, in the creation of a mysqldump command
without having to store config information (especially passwords) in a second place, to avoid
wasted effort, risk of stale data, and password compromise.

The parsing algorithm is extremely primitive, but "works for me".

The WCReader constructor will handle any of the following as its argument:

* an array of lines
* a filespec of a Wordpress config file
* a filespec of a directory containing a Wordpress config file
  ('wp-config.php' is assumed to be the file's name).

After instantiating a reader, you can access the variables defined
in the config file in the following ways:

```ruby

reader = WCReader.new('/Users/me/public_html/blog')

db_name = reader.db_name
# or
db_name = reader['DB_NAME']
# or
db_name = reader[:db_name]
# or
db_name = reader.get(:db_name)
# or
db_name = reader.get('DB_NAME')
```

Here's an example of a possibly useful script:

```ruby
require 'wordpress_config_reader'

reader = WCReader.new('/Users/me/public_html/blog')

time_str = Time.now.strftime("%Y_%m_%d__%H%M%S")

outfilespec = "my-wp-db-backup-#{time_str}.sql" # (generate a good filespec)

command = """mysqldump -u#{reader.db_user} -p#{reader.db_password} \
    -h#{reader.db_hostname} #{reader.db_name} > outfilespec

puts `#{command} 2>&1`
puts `git add #{outfilespec} 2>&1`
puts `git commit -m "Added #{outfilespec}.
```

CAUTION:

It is assumed that the key in the config file is always, and all, upper case.
Any key passed to the get and [] methods, and as a method name, will be
converted to an upper case string for which to search in the config file.

If you use the method name approach of reading the value for a key,
then an exception will be raised if the key did not exist in the file.
If you don't want that to happen, you can use the get or [] methods instead,
as they return nil rather than raising an error.  For example:

```ruby
value = reader[:db_xyz]
# instead of
value = reader.db_xyz
```

calling has_key? with string or symbol is recommended, and is very fast,
since the found value will be cached. For example:

It is highly recommended to use Shellwords.escape on any values found
in the config file before passing those values to a command line.
You wouldn't want someone modifying a value to include "; rm -rf ~"!





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
