begin
  puts "进入begin"
  abc
rescue NameError => e
  puts "异常， #{e.message}"
else
  puts "进入else"
ensure
  puts "进入ensure"
end