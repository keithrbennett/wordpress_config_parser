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
