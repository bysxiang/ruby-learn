a = 3

catch(:error) do 
  a = 4
end

puts "a:#{a}"