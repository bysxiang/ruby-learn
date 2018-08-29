def hello()
  puts "hello之前"
  raise "xxx"
  puts "hh"
ensure
  puts "进入ensure"
end

hello()