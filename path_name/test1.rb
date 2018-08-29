# 测试Pathname 与 文件是否存在等信息

require "pathname"

current_path = Pathname.new("/root/work/ruby-learn/path_name")


p current_path
  
path = current_path.join("test").to_s + "/s1.txt"; 
exist = File.exist? path

puts "current_path是否冻结了：#{current_path.frozen?()}, #{current_path.to_s.frozen?}"

puts "path: #{path}"
puts "是否存在？#{exist}"