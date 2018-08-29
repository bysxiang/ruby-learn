require 'securerandom'
require 'set'

s1 = Set.new

1000000.times do |i|
    code = SecureRandom.hex(5)

    s1.add(code)
end

puts "输出长度"
p s1.length

s2 = Set.new
s2.add("33")
s2.add("33")
s2.add("44")

p s2.length