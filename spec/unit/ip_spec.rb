require File.dirname(__FILE__) + '/../spec_helper'


describe Subnets::IP do
  it "should return octets when sent#octets()" do
    ip = Subnets::IP.new("1.2.3")
    ip.octets.should == [1, 2, 3]
  end

  it "should return string representation when sent#to_s" do
    Subnets::IP.new("1.2.3").to_s.should == "1.2.3"
  end
  
  it "should return the next IP when sent#next()" do
    Subnets::IP.new("0.0.254").next.to_s.should == "0.0.255"
    Subnets::IP.new("0.0.255").next.to_s.should == "0.1.0"
    Subnets::IP.new("0.254.0").next.to_s.should == "0.254.1"
    Subnets::IP.new("0.255.255").next.to_s.should == "1.0.0"
    Subnets::IP.new("254.255.255").next.to_s.should == "255.0.0"
  end

  it "should be able to compare two ips" do
    (Subnets::IP.new("1.2.3") <=> Subnets::IP.new("1.2.3")).should == 0
    (Subnets::IP.new("1.0.4") <=> Subnets::IP.new("1.0.3")).should == 1
    (Subnets::IP.new("1.0.4") <=> Subnets::IP.new("1.0.5")).should == -1
    (Subnets::IP.new("1.2.4") <=> Subnets::IP.new("1.1.4")).should == 1
    (Subnets::IP.new("2.0.0") <=> Subnets::IP.new("2.2.5")).should == -1
  end
end
