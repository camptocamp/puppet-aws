# Copyright 2008 Tim Dysinger
# Distributed under the same license as Facter
# 27.02.09 KurtBe
# Added a can_connect? function so that this fact can safely be distributed to non-ec2 instances
# otherwise the script hangs if the amazon-ip is not reachable

require 'open-uri'
require 'timeout'

def can_connect?(ip,port,wait_sec=2)
 Timeout::timeout(wait_sec) {open(ip, port)}
 return true
rescue
  return false
end


def metadata(id = "")
  open("http://169.254.169.254/2008-02-01/meta-data/#{id||=''}").read.
    split("\n").each do |o|
    key = "#{id}#{o.gsub(/\=.*$/, '/')}"
    if key[-1..-1] != '/'
      value = open("http://169.254.169.254/2008-02-01/meta-data/#{key}").read.
        split("\n")
      value = value.size>1 ? value : value.first
      symbol = "ec2_#{key.gsub(/\-|\//, '_')}".to_sym
      Facter.add(symbol) { setcode { value } }
    else
      metadata(key)
    end
  end
rescue
  puts "ec2-metadata not loaded"
end

if can_connect?("169.254.169.254",80)
  begin
    Timeout::timeout(2) { metadata }
  rescue
    puts "ec2-metadata timed out"
  end
else
  puts "ec2-metadata not loaded"
end
