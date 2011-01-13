require 'subnets/ip'
require 'netaddr'


class Subnets
  SUBNET_REGEXP = /\d\.\d\.\d\.\d-\d\.\d\.\d\.\d/
  OCTET_UPPER_BOUND = 255
  
  def initialize
    @subnets = {}
    @subnets_graph = {}
  end
  
  ##
  # @return [Array<String>] all the subnets in our set.
  #
  def subnets()
    @subnets.keys()
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
    subnets = self.subnets()
    @subnets = {}
    @subnets_graph = {}
    subnets
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
    subnet = parse_subnet(subnet)
    return false unless valid_subnet?(subnet)
    
    first_ip, last_ip = ip_obj_array(subnet)
    first_node = fetch_node(first_ip.to_s)
    last_node = fetch_node(last_ip.to_s)
    
    first_node == last_node
  end
  
  ##
  # Predicate indicating if the ip is contained by one of our subnets.
  #
  # @example
  #  subnets = Subnets.new()
  #  subnets.add("1.1.1.0-1.1.1.5")
  #  subnets.has_ip?("1.1.1.1")
  #  => true
  #
  #  subnets.has_ip?("1.1.1.9")
  #  => false
  #
  # @param [String] The IP
  # @return [true, false]
  # 
  def has_ip?(ip)
    return false unless valid_subnet?("#{ip}-#{ip}")
    fetch_node(ip)
  end
  
  ##
  # Predicate indicating if the subnet is valid.
  #
  # @example
  #  subnets = Subnets.new()
  #  subnets.valid_subnet?("xxx")
  #  => false
  #
  #  subnets.valid_subnet?("1.1.1.1-1.1.1.0")
  #  => false
  #
  #  subnets.valid_subnet?("1.1.1.0-1.1.1.1")
  #  => true
  #
  # @param [String] The subnet
  # @return [true, false]
  # 
  def valid_subnet?(subnet)
    subnet = parse_subnet(subnet)
    unless (subnet =~ subnet_regexp())
      return false
    end

    first, last = ip_obj_array(subnet)
    return false unless octets_within_upper_bound?(first, last)
    first <= last
  end
  
  ##
  # Set the upper bound value for each octet.  The default is 255
  #
  # @example
  #  subnets = Subnets.new()
  #  subnets.octet_upper_bound = 4
  #
  #  Now the largest ip for the first or last value of a subnet
  #  is 4.4.4.4
  #
  # @param [Integer] 
  # 
  def octet_upper_bound=(ub)
    @upper_bound = ub.to_i
  end
  
  ##
  # @return [Integer] The current upper bound for each octet
  # 
  def octet_upper_bound
    @upper_bound || OCTET_UPPER_BOUND
  end

  ##
  # Changes the regexp used to determine if a subnet is valid.  You
  # restring subnets to 3 octets instead of 4 (the default) by swapping
  # out the regexp.
  #
  # @example
  #  subnets = Subnets.new()
  #  subnets.valid_subnet?("1.1.0-1.1.1")
  #  => false
  #
  #  subnets.subnet_regexp = /\d\.\d\.\d\-\d\.\d\.\d/
  #  subnets.valid_subnet?("1.1.0-1.1.1")
  #  => true
  #
  # @param [Regexp]
  # 
  def subnet_regexp=(regexp)
    @subnet_regexp = regexp
  end
  
  ##
  # @return [Regexp] The current regexp used to validate the format of
  # a subnet.
  # 
  def subnet_regexp()
    (@subnet_regexp || SUBNET_REGEXP).dup
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
  
  ##
  # @example
  #  ip_obj_array("1.1.1.0-1.1.1.1")
  # => [<Subnets::IP 1.1.1.0>, <Subnets::IP 1.1.1.1>]
  #
  # @param [String] Subnet
  # @return [Array<Subnets::IP>]  First and last IP of the subnets
  # 
  def ip_obj_array(subnet)
    a, b = subnet.split("-")
    [Subnets::IP.new(a), Subnets::IP.new(b)]
  end
  
  def fetch_node(ip)
    node = @subnets_graph
    ip.split(".").map(&:to_i).each do |i|
      return nil unless node[i]
      node = node[i]
    end
    return node
  end
  
  def parse_subnet(subnet)
    subnet = subnet.to_s.gsub(/\s+/, "")
    cidr = ::NetAddr::CIDR.create(subnet)
    return "#{cidr.first}-#{cidr.last}"
  rescue ::NetAddr::ValidationError => e
    return subnet
  end
  
  def generate_ips(subnet)
    first_ip, last_ip = ip_obj_array(parse_subnet(subnet))    
    
    ips = []
    while (first_ip <= last_ip)
      ips << first_ip
      first_ip = first_ip.next(octet_upper_bound())
    end
    ips
  end
  
  def octets_within_upper_bound?(first, last)
    result = (first.octets() + last.octets()).all? do |oct|
      oct <= octet_upper_bound()
    end
  end
end
