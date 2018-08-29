def show()
  count = 0
  while count < 10
    sleep 1
    puts "count:#{count}"
    count += 1
  end
end

show()

puts "完毕"