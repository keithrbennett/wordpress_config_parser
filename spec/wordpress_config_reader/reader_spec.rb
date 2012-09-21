require_relative '../spec_helper'
require 'reader'
require 'tempfile'

describe Reader do

  let(:sample_lines) { %w(abc 789) }
  let(:sample_dirspec) { File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources')) }
  let(:sample_filespec) { File.join(sample_dirspec, 'wp-config.php') }

  it "should initialize correctly when calling create_with_lines" do
    reader = Reader.create_with_line_array(sample_lines)
    reader.lines.should == sample_lines
  end

  it "reader.lines should be an array when calling create_with_filespec" do
    reader = Reader.create_with_filespec(sample_filespec)
    reader.lines.should be_a Array
  end

  it "reader.lines should equal the initial array when calling create_with_filespec" do
    reader = Reader.create_with_filespec(sample_filespec)
    reader.lines.should == sample_lines
  end

  it "should correctly extract the value from a config line" do
    config_line = "define('DB_NAME', 'abcdefgh_0001');"
    Reader.create_with_line_array.extract_value_from_line(config_line).should == 'abcdefgh_0001'
  end

end
