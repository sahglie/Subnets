require File.dirname(__FILE__) + '/../spec_helper'

describe IpRanges do
  
  it "should crap" do
    ranges = IpRanges.new
    ranges.should be_nil
    pp ranges
  end
  
end
