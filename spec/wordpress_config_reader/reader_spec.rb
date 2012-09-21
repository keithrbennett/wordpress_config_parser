require_relative '../spec_helper'
require 'reader'

describe Reader do

  let(:sample_lines) { %w(abc 789) }

  it "should do something" do
    sample_lines.should == sample_lines
  end
end