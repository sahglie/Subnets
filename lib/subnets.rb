require 'subnets/ip'


class Subnets
  SUBNET_REGEXP = /\d\.\d\.\d\.\d-\d\.\d\.\d\.\d/
  OCTET_UPPER_BOUND = 255
  
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
  def add(subnet)
    subnet = parse_subnet(subnet)
    return false unless valid_subnet?(subnet)
    
    first_ip, last_ip = subnet.split("-")
    if @subnets.has_key?(subnet)
      false
    else
      add_subnet_to_graph(subnet)
      @subnets[subnet] = true
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
  def remove(subnet)
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
  def has_subnet?(subnet)
    subnet = parse_subnet(subnet)
    @subnets.has_key?(subnet)
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
  def contained_by_subnet?(subnet)
    first_ip, last_ip = parse_subnet(subnet)
    fetch_node(first_ip) == fetch_node(last_ip)
  end
  
  def octet_upper_bound=(ub)
    @upper_bound = ub
  end

  def octet_upper_bound
    @upper_bound || OCTET_UPPER_BOUND
  end
  
  def subnet_regexp()
    @subnet_regexp || SUBNET_REGEXP
  end

  def subnet_regexp=(regexp)
    @subnet_regexp = regexp
  end
  
  
  private
  
  def add_subnet_to_graph(subnet)
    generate_ips(subnet).each do |ip|
      add_ip_to_graph(ip.to_s, subnet)
    end
  end

  def add_ip_to_graph(ip, subnet)
    octets = ip.split(".").map(&:to_i)
    curr = @subnets_graph
    while ( !octets.empty? )
      oct = octets.shift()
      if octets.empty?
        curr[oct] = subnet
      else
        curr[oct] ||= {}
        curr = curr[oct]
      end
    end
  end
  
  def valid_subnet?(subnet)
    subnet =~ subnet_regexp()
    # make sure the subnet's 1st ip is smaller than the 2nd ip
  end
  
  def fetch_node(ip)
    node = nil
    ip.split(".").each do |i|
      node = @subnets_graph[i]
      return nil unless node
    end
    return node
  end
  
  def parse_subnet(subnet)
    subnet.gsub(/\s+/, "")
  end
  
  def generate_ips(subnet)
    subnet = parse_subnet(subnet)
    a, b = subnet.split("-")
    first_ip, last_ip = Subnets::IP.new(a), Subnets::IP.new(b)
    ips = []
    while (first_ip <= last_ip)
      ips << first_ip
      first_ip = first_ip.next(octet_upper_bound())
    end
    ips
  end

end
