require_relative '../spec_helper'
require 'reader'
require 'tempfile'

describe Reader do

  let(:sample_lines) { %w(abc 789) }

  it "should initialize correctly when calling create_with_lines" do
    reader = Reader.create_with_line_array(sample_lines)
    reader.lines.should == sample_lines
  end

  it "reader.lines should be an array when calling create_with_filespec" do
    filespec = Tempfile.new('WordpressConfigReaderTest')
    begin
    puts filespec
    File.write(filespec, sample_lines.join("\n"))
    reader = Reader.create_with_filespec(filespec)
    reader.lines.should be_a Array
    ensure
      File.delete(filespec)
    end
  end

  it "reader.lines should equal the initial array when calling create_with_filespec" do
    filespec = Tempfile.new('WordpressConfigReaderTest')
    begin
    puts filespec
    File.write(filespec, sample_lines.join("\n"))
    reader = Reader.create_with_filespec(filespec)
    reader.lines.should == sample_lines
    ensure
      File.delete(filespec)
    end
  end


end
