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
    end
  end

  it "should know if a subnet is valid when sent#valid_subnet?" do
    @subnets.valid_subnet?("1.1.1.1-1.1.1.0").should be_false
    @subnets.valid_subnet?("xxx").should be_false
    @subnets.valid_subnet?("1.1.1.0-1.1.1.1").should be_true
    @subnets.valid_subnet?("1.1.1.1-1.1.1.1").should be_true
  end
  
  it "should know if an ip is contained by our subnets when sent#contains_ip?" do
    @subnets.add("1.1.1.0-1.1.1.5")
    @subnets.has_ip?("1.1.1.0").should be_true
    @subnets.has_ip?("1.1.1.6").should be_false
  end
  
  it "should know if a subnet is contained by a subnet in our set when sent#contained_by_subnet?" do
    @subnets.add("1.1.1.0-1.1.1.5")
    @subnets.contained_by_subnet?("1.1.1.3-1.1.1.5").should be_true
    @subnets.contained_by_subnet?("1.1.1.0-1.1.1.5").should be_true
    @subnets.contained_by_subnet?("1.1.1.0-1.1.1.0").should be_true    
    @subnets.contained_by_subnet?("1.1.1.5-1.1.1.5").should be_true
    @subnets.contained_by_subnet?("1.1.1.4-1.1.1.5").should be_true
    @subnets.contained_by_subnet?("1.1.1.0-1.1.1.6").should be_false
  end
end


describe "Subnets private methods" do
  before(:each) do
    @subnets = Subnets.new()
    @subnets.subnet_regexp = /\d\.\d\.\d\-\d\.\d\.\d/
    @subnets.octet_upper_bound = 4
    
    @snet = "0.1.2-2.2.2"
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
    @ips = zeros + ones + twos
  end
  
  
  it "should generate all IPs within a subnet when sent#generate_ips" do
    gen_ips = @subnets.send(:generate_ips, "0.1.2-2.2.2").map(&:to_s)
    gen_ips.length.should == @ips.length
    @ips.each { |ip| gen_ips.include?(ip).should be_true }
  end

  it "should add an IP to the subnet graph when sent#add_ip_to_graph" do
    graph = @subnets.instance_variable_get(:@subnets_graph)
    graph.should == {}
    snet = "0.1.2-0.1.3"
    @subnets.send(:add_ip_to_graph, "0.1.2", snet)
    graph.should == {0 => {1 => {2 => snet}} }
  end

  it "should" do
    @subnets.add(@snet)
    @subnets.instance_variable_get(:@subnets_graph)
  end
end

