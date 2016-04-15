require_relative '../spec_helper'
require 'wordpress_config_parser'
require 'tempfile'

module WordpressConfigParser

describe Parser do


  let(:sample_lines) { %w(abc 789) }
  let(:sample_dirspec) { File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources')) }
  let(:sample_filespec) { File.join(sample_dirspec, 'wp-config.php') }
  let(:sample_parser) { Parser.new(sample_filespec) }

  it "should initialize correctly when creating with an array of lines" do
    parser = Parser.new(sample_lines)
    expect(parser.lines).to eq(sample_lines)
  end

  it "parser.lines should be an array when instantiating with a filespec" do
    expect(sample_parser.lines).to be_an(Array)
  end

  specify "parser.lines should equal the initial array when instantiating with a filespec" do
    parser = Parser.new(sample_filespec)
    expect(parser.lines).to eq(File.readlines(sample_filespec).map(&:chomp))
  end

  it "should correctly extract the value from a config line" do
    config_line = "define('DB_NAME', 'abcdefgh_0001');"
    expect(sample_parser.send(:extract_value_from_line, config_line)).to eq('abcdefgh_0001')
  end

  it "should extract the correct (i.e., the last) matching line when > 1 matches are present" do
    line = sample_parser.send(:find_def_line, 'DB_NAME')
    value = sample_parser.send(:extract_value_from_line, line)
    expect(value).to eq('mysite_wrd2')
  end

  specify "get should get the correct value" do
    expect(sample_parser.get('DB_NAME')).to eq('mysite_wrd2')
  end

  it "[] operator should get the correct value" do
    expect(sample_parser['DB_NAME']).to eq('mysite_wrd2')
  end

  it "should correctly generate a new method when receiving a property in lower case" do
    expect(sample_parser.db_name).to eq('mysite_wrd2')
  end

  it "should correctly create a mysqladmin dump command with parameters from the file" do
    db_name     = sample_parser.db_name
    db_password = sample_parser.db_password
    db_hostname = sample_parser.db_host
    db_user     = sample_parser.db_user

    # mysqldump -u#{userid} -p#{password} -h#{hostname} #{database_name} 2>&1 > #{outfilespec}`
    command = "mysqldump -u#{db_user} -p#{db_password} -h#{db_hostname} #{db_name}"
    expected = "mysqldump -umysite_user -pgobbledygook -hlocalhost mysite_wrd2"
    expect(command).to eq(expected)
  end

  it "should correctly return true for has_key?(:db_name) and has_key?('DB_NAME')" do
    expect(sample_parser.has_key?(:db_name) && sample_parser.has_key?('DB_NAME')).to eq(true)
  end

  it "should correctly return false for has_key?(:zyx) and has_key?('ZYX')" do
    expect(sample_parser.has_key?(:zyx) || sample_parser.has_key?('ZYX')).to eq(false)
  end

  it "should throw an ArgumentError if a bad file is provided" do
    expect{ Parser.new('/:!@#$%^&') }.to raise_error(ArgumentError)
  end

  it "should throw an ArgumentError if a something other than a string or array is provided" do
    expect { Parser.new(123) }.to raise_error(ArgumentError)
  end

  it "should throw a NoMethodError if a method is called for which there is no key" do
    expect { sample_parser.foo }.to raise_error(NoMethodError)
  end

end
end

