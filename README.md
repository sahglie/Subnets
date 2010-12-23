IpRanges
============

IpRanges is a data strucuture for storing a set of IpRanges.  Its key functionality 
is quick lookup: determining if an IP or IP Range is in this set or contained by an
Ip Range in this set.


Usage
--------

Create a new IP Range container

    ranges = IpRanges.new

Add IP Ranges

    ranges.add("1.1.1.0-1.1.1.10")
    ranges.add("1.1.2.0-1.1.2.10")

Query IP Ranges

    ranges.has_range?("1.1.1.0-1.1.1.10")
    => true

    ranges.has_range?("1.1.1.1-1.1.1.5")
    => false

    ranges.contained_by_range?("1.1.1.1-1.1.1.5")
    => true

    ranges.contained_by_range?("1.1.1.6")
    => true

    ranges.contained_by_range?("1.1.1.11")
    => false

