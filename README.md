Subnets
============

Subnets is a data strucuture for storing a set of subnets.  Its key functionality 
is quick lookups: determining if an IP or Subnet is in this set or contained by a
Subnet in this set.


Usage
--------

Create a new Subnet container

    subnets = Subnets.new()

Add Subnets

    subnets.add("1.1.1.0-1.1.1.10")
    subnets.add("1.1.2.0-1.1.2.10")

    # You can also use CIDR Format
    subnets.subnets()
    => ["1.1.1.0-1.1.1.10", "1.1.2.0-1.1.2.10"]

Query Subnets/IPs

    subnets.has_subnet?("1.1.1.0-1.1.1.10")
    => true

    subnets.has_subnet?("1.1.1.1-1.1.1.5")
    => false

    subnets.contained_by_subnet?("1.1.1.1-1.1.1.5")
    => true

    subnets.contained_by_subnet?("1.1.1.6")
    => true

    subnets.contained_by_subnet?("1.1.1.11")
    => false

    subnets.has_ip?("1.1.1.5")
    => true

    subnets.has_ip?("2.1.1.0")
    => false

Clear Subnets

    subnets.clear()
    => ["1.1.1.0-1.1.1.10", "1.1.2.0-1.1.2.10"]

    subnets.subnets()
    => []

