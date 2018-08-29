# 如果在rescue语句中引发了异常，依然会先执行ensure语句
# 再抛出异常

begin
  raise "java"
rescue => e
  puts "异常: #{e.message}"
  raise "黑河"
ensure
  puts "进入ensure"
end