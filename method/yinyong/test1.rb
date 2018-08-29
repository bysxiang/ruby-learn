def show(is_a = true)
  arr = lambda do
    if is_a
      [1, 3, 3]
    else
      puts "输出&arr"
      p &arr
      test(&arr)
    end
  end
  arr.call
end

def test(arr)
  puts "输出arr"
  p arr

  arr << 7
end

show()
a = show(false)

puts "输出a"
p a