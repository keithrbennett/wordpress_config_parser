require_relative '../spec_helper'
require 'wc_reader'
require 'tempfile'

describe WCReader do


  let(:sample_lines) { %w(abc 789) }
  let(:sample_dirspec) { File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources')) }
  let(:sample_filespec) { File.join(sample_dirspec, 'wp-config.php') }
  let(:sample_reader) { WCReader.new(sample_filespec) }

  it "should initialize correctly when calling create_with_lines" do
    reader = WCReader.new(sample_lines)
    reader.lines.should == sample_lines
  end

  it "reader.lines should be an array when instantiating with a filespec" do
    sample_reader.lines.should be_a Array
  end

  it "reader.lines should equal the initial array when calling create_with_filespec" do
    reader = WCReader.new(sample_filespec)
    reader.lines.should == File.readlines(sample_filespec).map(&:chomp)
  end

  it "should correctly extract the value from a config line" do
    config_line = "define('DB_NAME', 'abcdefgh_0001');"
    sample_reader.extract_value_from_line(config_line).should == 'abcdefgh_0001'
  end

  it "should extract the correct line when > 1 matches are present" do
    line = sample_reader.find_def_line('DB_NAME')
    value = sample_reader.extract_value_from_line(line)
    value.should == 'mysite_wrd2'
  end

  it "(get) should get the correct value" do
    sample_reader.get('DB_NAME').should == 'mysite_wrd2'
  end

  it "[] operator should get the correct value" do
    sample_reader['DB_NAME'].should == 'mysite_wrd2'
  end

  it "should correctly generate a new method when receiving a property in lower case" do
    sample_reader.db_name.should == 'mysite_wrd2'
  end

  it "should correctly create a mysqladmin dump command with parameters from the file" do
    db_name = sample_reader.db_name
    db_password = sample_reader.db_password
    db_hostname = sample_reader.db_host
    db_user = sample_reader.db_user

    # mysqldump -u#{userid} -p#{password} -h#{hostname} #{database_name} 2>&1 > #{outfilespec}`
    command = "mysqldump -u#{db_user} -p#{db_password} -h#{db_hostname} #{db_name}"
    expected = "mysqldump -umysite_user -pgobbledygook -hlocalhost mysite_wrd2"
    command.should == expected
  end

  it "should correctly return true for has_key?(:db_name) and has_key?('DB_NAME')" do
    (sample_reader.has_key?(:db_name) && sample_reader.has_key?('DB_NAME')).should be_true
  end

  it "should correctly return false for has_key?(:zyx) and has_key?('ZYX')" do
    (sample_reader.has_key?(:zyx) || sample_reader.has_key?('ZYX')).should be_false
  end

  it "should throw an ArgumentError if a bad file is provided" do
    lambda { WCReader.new('/:!@#$%^&') }.should raise_error(ArgumentError)
  end

  it "should throw an ArgumentError if a something other than a string or array is provided" do
    lambda { WCReader.new(123) }.should raise_error(ArgumentError)
  end

  it "should throw a NoMethodError if a method is called for which there is no key" do
    lambda { sample_reader.foo }.should raise_error(NoMethodError)
  end

end
