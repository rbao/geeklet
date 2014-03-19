#!/usr/bin/env ruby

def connections
  lsof_output = %x( lsof -i | grep -E "(LISTEN|ESTABLISHED)" | awk '{print $1, $8, $9, $10}' )
  cons = lsof_output.gsub(/\s[a-z0-9.-]+:/, " ")
  return cons
end

puts connections