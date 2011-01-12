require File.dirname(__FILE__) + '/../spec_helper'

describe Subnets do

  before(:each) do
    @subnets = Subnets.new()
    @subnets.octet_upper_bound = 5
  end
  
  context "Subnets#add()" do
    it "should add a valid subnet" do
      snet = "1.1.1.0-1.1.1.1"
      @subnets.has_subnet?(snet).should be_false
      @subnets.add(snet).should be_true
      @subnets.has_subnet?(snet).should be_true
    end

    it "should not add an invalid subnet" do
      snet = "xxx"
      @subnets.has_subnet?(snet).should be_false
      @subnets.add(snet).should be_false
      @subnets.has_subnet?(snet).should be_false
      
#       snet = "1.1.2.0-1.1.1.0"
#       @subnets.has_subnet?(snet).should be_false      
#       @subnets.add(snet).should be_false
#       @subnets.has_subnet?(snet).should be_false
    end
  end
  
end


describe "Subnets private methods" do
  before(:each) do
    @subnets = Subnets.new
  end
  
  it "should generate all IPs within a subnet when sent#generate_ips" do
    @subnets = Subnets.new()
    @subnets.octet_upper_bound = 4    
    @subnets.subnet_regexp = /\d\.\d\.\d\-\d\.\d\.\d/
    
    zeros = ["0.1.2", "0.1.3", "0.1.4",
             "0.2.0", "0.2.1", "0.2.2", "0.2.3", "0.2.4",
             "0.3.0", "0.3.1", "0.3.2", "0.3.3", "0.3.4",
             "0.4.0", "0.4.1", "0.4.2", "0.4.3", "0.4.4"]
    
    ones = [ "1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.0.4",
             "1.1.0", "1.1.1", "1.1.2", "1.1.3", "1.1.4",
             "1.2.0", "1.2.1", "1.2.2", "1.2.3", "1.2.4",
             "1.3.0", "1.3.1", "1.3.2", "1.3.3", "1.3.4",
             "1.4.0", "1.4.1", "1.4.2", "1.4.3", "1.4.4"]
    
    twos =  [ "2.0.0", "2.0.1", "2.0.2", "2.0.3", "2.0.4",
              "2.1.0", "2.1.1", "2.1.2", "2.1.3", "2.1.4",
              "2.2.0", "2.2.1", "2.2.2"]

    expected_ips = zeros + ones + twos
    ips = @subnets.send(:generate_ips, "0.1.2-2.2.2").map(&:to_s)
    ips.length.should == expected_ips.length
    ips.each { |ip| ips.include?(ip).should be_true }
  end

  it "should add an IP to the subnet graph when sent#add_ip_to_graph" do
    graph = @subnets.instance_variable_get(:@subnets_graph)
    graph.should == {}
    snet = "0.1.2-0.1.3"
    @subnets.send(:add_ip_to_graph, "0.1.2", snet)
    graph.should == {0 => {1 => {2 => snet}} }
  end
end

