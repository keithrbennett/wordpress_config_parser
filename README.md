# WordpressConfigParser

Reads a Wordpress configuration file (wp-config.php) and
makes its define() data values easily accessible.

This is useful, for example, in the creation of a mysqldump command
without having to store config information (especially passwords) in a second place, to avoid
wasted effort, risk of stale data, and password compromise.

The parsing algorithm is extremely primitive, but "works for me".

The WCParser constructor will handle any of the following as its argument:

* an array of lines
* a filespec of a Wordpress config file
* a filespec of a directory containing a Wordpress config file
  ('wp-config.php' is assumed to be the file's name).

After instantiating a parser, you can access the variables defined
in the config file in the following ways:

```ruby

parser = WCParser.new('/Users/me/public_html/blog')

db_name = parser.db_name
# or
db_name = parser['DB_NAME']
# or
db_name = parser[:db_name]
# or
db_name = parser.get(:db_name)
# or
db_name = parser.get('DB_NAME')
```

Here's an example of a possibly useful script that creates a sql backup
of multiple blogs on a shared host, adds them to the git repo (of the
entire shell account), and pushes them to the origin repo:

```ruby
#!/usr/bin/env ruby

require 'wordpress_config_parser'
require 'shellwords'


def run_command(command)
  puts(command)
  puts(`#{command}`)
end


home = ENV['HOME']
output_dir = File.join(home, 'sql-backups')
blognames = %w(blog1 blog2)


blognames.each do |blogname|

  blog_dir = File.join(home, 'public_html', blogname)
  parser = WCParser.new(blog_dir)
  time_str = Time.now.strftime("%Y_%m_%d__%H%M%S")
  outfilespec = File.join(output_dir, "#{blogname}-db-backup-#{time_str}.sql")

  user     = Shellwords.escape(parser.db_user)
  password = Shellwords.escape(parser.db_password)
  host     = Shellwords.escape(parser.db_host)
  name     = Shellwords.escape(parser.db_name)


  Dir.chdir(home) do   # in case you have another .git dir where you are
    run_command("mysqldump -u#{user} -p#{password} -h#{host} #{name} 2>&1 | tee #{outfilespec}")
    run_command("git add #{outfilespec} 2>&1")
    run_command("git commit -m \"Added #{outfilespec}.\"")
  end
end

run_command("git push -u origin master")
```

CAUTION:

It is assumed that the key in the config file is always, and all, upper case.
Any key passed to the get and [] methods, or as a method name, will be
converted to an upper case string for which to search in the config file.

If you use the method name approach of reading the value for a key,
then a NoMethodError will be raised if the key did not exist in the file.
If you don't want that to happen, you can use the get or [] methods instead,
as they return nil rather than raising an error.  For example:

```ruby
value = parser[:db_xyz]
# instead of
value = parser.db_xyz
```

You can also call has_key? (with either string or symbol) to see if it's there
before trying to get it.  This function is very fast, and pulls the value into
the cache if it wasn't already there, so the subsequent access to get the
actual value is very fast.

It is highly recommended to use Shellwords.escape on any values found
in the config file before passing those values to a command line.
You wouldn't want someone modifying a value to include "; rm -rf ~"!





## Installation

Add this line to your application's Gemfile:

    gem 'wordpress_config_parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wordpress_config_parser

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
