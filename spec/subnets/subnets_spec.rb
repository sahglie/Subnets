require File.dirname(__FILE__) + '/../spec_helper'

describe Subnets do

  before(:each) do
    @subnets = Subnets.new()
  end
  
  context "IpRanges#add()" do
    it "should add a valid range" do
      r = "1.1.1.0-1.1.1.1"
      @subnets.has_subnet?(r).should be_false
      @subnets.add(r).should be_true
      @subnets.has_subnet?(r).should be_true
    end

    it "should not add an invalid subnet" do
      r = "xxx"
      @subnets.has_subnet?(r).should be_false
      @subnets.add(r).should be_false
      @subnets.has_subnet?(r).should be_false
    end

    it "should build the subnets graph" do
      r = "1.1.1.0-1.1.1.5"
      @subnets.has_subnet?(r).should be_false
      @subnets.add(r).should be_false
      @subnets.has_subnet?(r).should be_false
    end
  end


end
