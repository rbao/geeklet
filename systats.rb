#!/usr/bin/env ruby

def total_cpu_usage
  cpu_re = /CPU usage: (\d+\.\d+)% user, (\d+\.\d+)% sys, (\d+\.\d+)% idle/
  top_output = %x( top -l1 -n 0 | grep CPU )
  matched = cpu_re.match(top_output)

  return "unkonwn" unless matched

  user = matched[1].to_f
  sys = matched[2].to_f
  total = user + sys - 9 # cpu used by top is around 9

  return total.ceil
end

def disk_usage
  disk_re = /\/dev\/disk0s2\s+(\d+[BKMG])\s+(\d+[BKMG])\s+(\d+[BKMG])/
  df_output = %x( df -H -l )
  matched = disk_re.match(df_output)

  return "unkonwn" unless matched

  cap = matched[1]
  used = matched[2]
  free = matched[3]

  return used
end

def internal_ip
  inet_re = /inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
  ifconfig_output = %x( ifconfig en0 | grep inet )
  matched = inet_re.match(ifconfig_output)

  return "unkonwn" unless matched
  return matched[1]
end

def external_ip
  return %x( curl -s http://icanhazip.com ).strip
end

def bandwidth_usage
  netstat_output1 = %x( netstat -I en0 -b | grep '<Link#4>' ).strip
  sleeped = sleep(1)
  netstat_output2 = %x( netstat -I en0 -b | grep '<Link#4>' ).strip

  data1 = netstat_output1.split
  data2 = netstat_output2.split

  i1 = data1[6].to_i
  i2 = data2[6].to_i
  o1 = data1[9].to_i
  o2 = data2[9].to_i

  i = (i2 - i1) / 1024
  o = (o2 - o1) / 1024

  if i >= 1024
    istr = "#{(i / 1024.0).round(2)} MB/S"
  else
    istr = "#{i} KB/S"
  end

  if o >= 1024
    ostr = "#{(o / 1024.0).round(2)} MB/S"
  else
    ostr = "#{o} KB/S"
  end

  return [istr, ostr]
end

b_usage = bandwidth_usage
puts "CPU:          #{total_cpu_usage}%"
puts "Disk:         #{disk_usage}"
puts "Internal IP:  #{internal_ip}"
puts "External IP:  #{external_ip}"
puts "Network In:   #{b_usage[0]}"
puts "Network Out:  #{b_usage[1]}"

