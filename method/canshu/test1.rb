def show(a, *dd)
  puts "输出: a:#{a}, dd:#{dd}"
end


arr = [1, 3, 5]

show(*arr)