class Subnets
  VALID_SUBNET_REGEX = /\d\.\d\.\d\.\d-\d\.\d\.\d\.\d/
  
  attr_reader :subnets, :subnets_graph
  
  def initialize
    @subnets = {}
    @subnets_graph = {}
  end
  
  ##
  # Add a subnet to our set.  Requires that the set contains unique subnets;
  # however, subnets may overlap.
  #
  # @example
  #   subnets.add("1.1.1.0-1.1.1.1")
  #   subnets.add("1.1.1.2-1.1.1.2")
  #
  # @param [String] the subnet.
  # @return [true,false] true if the subnet was added, otherwise false.
  #
  def add(ipr)
    ipr = parse_subnet(ipr)
    return false unless valid_subnet?(ipr)
    
    first_ipr, last_ipr = ipr.split("-")
    if @subnets.has_key?(ipr)
      false
    else
      update_subnets_graph(ipr)
      @subnets[ipr] = true
    end
  end
  
  ##
  # Remove a subnet from our set.
  #
  # @example
  #  subnets.remove("1.1.1.0-1.1.1.1")
  #
  # @param [String] the subnet.
  # @return [true,false] true if the subnet was removed, otherwise false.
  #
  def remove(ipr)
  end
  
  ##
  # Removes all subnets from our set.
  #
  # @return [Array<String>] Array of all subnets that were in our set.
  #
  def clear()
    @subnets = {}
    @subnets_graph = {}
  end
  
  ##
  # Predicate that determines if a given subnet is in our set.
  #
  # @example
  #   subnets.add("1.1.1.0-1.1.1.4")
  #   
  #   subnets.has_subnet?("1.1.1.0-1.1.1.4")
  #   => true
  #
  #   ranges.has_subnet?("1.1.1.1-1.1.1.4")
  #   => false
  #
  # @param [String] the subnet.
  # @return [true,false] 
  #
  def has_subnet?(ipr)
    ipr = parse_subnet(ipr)
    @subnets.has_key?(ipr)
  end
  
  ##
  # Predicate that determines if a given subnet (or ip address) is contained by a
  # subnet in our set.
  #
  # @example
  #   subnets.add("1.1.1.0-1.1.1.4")
  #   
  #   subnets.contained_by_subnet?("1.1.1.0-1.1.1.4")
  #   => true
  #
  #   subnets.contained_by_subnet?("1.1.1.2-1.1.1.3")
  #   => true
  #  
  #   subnets.contained_by_subnet?("1.1.1.4-1.1.1.5")
  #   => false
  #  
  #   ranges.contained_by_subnet?("1.1.1.6")
  #   => false
  #
  # @param [String] the subnet (or ip address).
  # @return [true,false] 
  #
  def contained_by_subnet?(ipr)
    first_ip, last_ip = parse_subnet(ipr)
    fetch_node(first_ip) == fetch_node(last_ip)
  end
  
  
  private
  
  def update_subnets_graph(ipr)
    first_ip, last_ip = ipr.split("-")
    octet_pairs = first_ip.split(".").zip(last_ip.split("."))
    level = 1
    curr_node = nil
    octet_pairs.each do |pair|
      a, b = pair
      if a == b
        @subnets_graph[a] ||= {}
        curr_node = @subnets_graph[a]
      elsif level == 4
        a.upto(b) { |i| curr_node[i] = ipr }
      else
       # placeholder 
      end
      level += 1
    end
  end
  

  def valid_subnet?(ipr)
    ipr =~ VALID_SUBNET_REGEX
  end
  
  def parse_subnet(ipr)
    ipr.gsub(/\s+/, "")
  end

  def fetch_node(ip)
    node = nil
    ip.split(".").each do |i|
      node = @subnets_graph[i]
      return nil unless node
    end
    return node
  end
end
