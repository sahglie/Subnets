class Subnets
  class IP
    include Comparable
    
    OCTET_UPPER_BOUND = 255
    
    def initialize(ip)
      @ip = ip
      @octets = ip.split(".").map(&:to_i)
    end
    
    ##
    # @example
    #  Subnets::IP.new("1.2.3.4").octets()
    #  => [1, 2, 3, 4]
    #
    # return [Array<Integer>] Decimal representation of the IP's octets.
    #
    def octets()
      @octets.dup()
    end
    
    ##
    # @example
    #  Subnets::IP.new("1.2.3.4").next()
    #  => <Subnets::IP "1.2.3.5">
    #
    # return [Subnets::IP] The next IP
    #
    def next(octet_upper_bound = OCTET_UPPER_BOUND)
      octets = self.octets()
      (octets.length-1).downto(0) do |i|
        if octets[i] < octet_upper_bound
          octets[i] += 1
          break
        else
          octets[i] = 0
        end
      end
      self.class.new(octets.join("."))
    end

    def to_s()
      @ip.dup()
    end
    
    def <=>(other_ip)
      octet_pairs = self.octets.zip(other_ip.octets())
      result = 0
      octet_pairs.inject(result) do |result, pair|
        result = (pair[0] <=> pair[1])
        break if result != 0
      end
      result
    end
  end
end
