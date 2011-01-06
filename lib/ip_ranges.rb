class IpRanges
  
  def initialize
    @ip_ranges = {}
    @ip_ranges_graph = {}
  end
  
  ##
  # Add an IP Range to our set.  Requires that the set contains unique IP Ranges.
  # However, IP Ranges may overlap.
  #
  # @example
  #   ranges.add("1.1.1.0-1.1.1.1")
  #   ranges.add("1.1.1.2-1.1.1.2")
  #
  # @param [String] the range.
  # @return [true,false] true if the range was added, otherwise false.
  #
  def add(ipr)
    ipr = parse_ip_range(ipr)
    first_ipr, last_ipr = ipr.split("-")
    if @ip_ranges.has_key?(ipr)
      false
    else
      update_ip_ranges_graph(ipr)
      @ip_ranges[ipr] = true
    end
  end
  
  ##
  # Remove an IP Range from our set.
  #
  # @example
  #  ranges.remove("1.1.1.0-1.1.1.1")
  #
  # @param [String] the range.
  # @return [true,false] true if the range was removed, otherwise false.
  #
  def remove(ipr)
  end
  
  ##
  # Removes all IP Range from our set.
  #
  # @return [Array<String>] Array of all IP Ranges that were in our set.
  #
  def clear()
    @ip_ranges = {}
    @ip_ranges_graph = {}
  end
  
  ##
  # Predicate that determines if a given subnet is in our set.
  #
  # @example
  #   ranges.add("1.1.1.0-1.1.1.4")
  #   
  #   ranges.has_ip_range?("1.1.1.0-1.1.1.4")
  #   => true
  #
  #   ranges.has_ip_range?("1.1.1.1-1.1.1.4")
  #   => false
  #
  # @param [String] the IP Range.
  # @return [true,false] 
  #
  def has_range?(ipr)
    ipr = parse_ip_range(ipr)
    @ip_ranges.has_key?(ipr)
  end
  
  ##
  # Predicate that determines if a given IP Range (or IP) is contained by an
  # IP Range in our set.
  #
  # @example
  #   ranges.add("1.1.1.0-1.1.1.4")
  #   
  #   ranges.contained_by_ranges?("1.1.1.0-1.1.1.4")
  #   => true
  #
  #   ranges.contained_by_range?("1.1.1.2-1.1.1.3")
  #   => true
  #  
  #   ranges.contained_by_ip_range?("1.1.1.4-1.1.1.5")
  #   => false
  #  
  #   ranges.contained_by_ip_range?("1.1.1.6")
  #   => false
  #
  # @param [String] the IP Range.
  # @return [true,false] 
  #
  def contained_by_range?(ipr)
    first_ip, last_ip = parse_ip_range(ipr)
    fetch_node(first_ip) == fetch_node(last_ip)
  end

  private
  
  def update_ip_ranges_graph(ipr)
    first_ip, last_ip = ipr.split("-")
    octet_pairs = first_ip.split(".").zip(last_ip.split("."))
    level = 1
    curr_node = nil
    octet_pairs.each do |pair|
      a, b = pair
      if a == b
        @ip_ranges_graph[a] ||= {}
        curr_node = @ip_ranges_graph[a]
      elsif level == 4
        a.upto(b) { |i| curr_node[i] = ipr }
      else
       # placeholder 
      end
      level += 1
    end
  end

  def parse_ip_range(ipr)
    ipr.gsub(/\s+/, "")
  end

  def fetch_node(ip)
    node = nil
    ip.split(".").each do |i|
      node = @ip_ranges_graph[i]
      return nil unless node
    end
    return node
  end
end
