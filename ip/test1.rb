require 'pathname'

file = Pathname.new("./ip.txt")
data = file.read.split(",")


file = File.new("ip2.txt", "w+")
data.each do |str|
  file.puts str.strip
end
file.close