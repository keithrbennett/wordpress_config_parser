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
#
# backup-wordpress-db.rb
#
# Calls mysqldump to create a backup of a MySQL data base
# in the form of a .sql file containing the SQL commands
# required to reconstruct it.
#
# Assumptions:
#
# 1) The directory containing the output (backup) files is in a git repo.
#
# 2) Either you have .ssh keys set up, or you're willing to
#    type in your password for the git push.
#
# 3) You're storing your SQL backup files in ~/sql-backups, and
#    that directory already exists.
#
# 4) The blogs are all under the $HOME/public_html directory.
#
# 5) There are no changes git added when you run this script.
#    Otherwise, those changes will be included in the commit,
#    without any commit message to describe them.

require 'wordpress_config_reader'
require 'shellwords'

if ARGV.empty?
  puts "Syntax is backup-wordpress.rb blog_dir_name_1 [...blog_dir_name_n]."
  exit -1
end


def run_command(command)
  puts(command)
  puts(`#{command}`)
end


home = ENV['HOME']
output_dir = File.join(home, 'sql-backups')
blognames = ARGV

blognames.each do |blogname|

  blog_dir = File.join(home, 'public_html', blogname)
  reader = WCReader.new(blog_dir)
  outfilespec = File.join(output_dir, "#{blogname}-db-backup.sql")

  user     = Shellwords.escape(reader.db_user)
  password = Shellwords.escape(reader.db_password)
  host     = Shellwords.escape(reader.db_host)
  name     = Shellwords.escape(reader.db_name)


  Dir.chdir(output_dir) do  # make sure we're in the right repo
    run_command("mysqldump -u#{user} -p#{password} -h#{host} #{name} 2>&1 | tee #{outfilespec}")
    run_command("git add #{outfilespec} 2>&1")
  end
end


run_command("git commit -m \"Updated SQL backups for blogs: #{blognames.join(', ')}.\"")
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
before trying to get it.  This function pulls the value into
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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
