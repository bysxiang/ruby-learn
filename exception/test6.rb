def hello()
  arr = []

  puts "hello之前"
  arr << 1
  arr << 3
  #raise "xxx"
  puts "hh， #{arr.object_id}"
  arr
rescue => e
  puts "进入rescue"
  [44]
ensure
  arr << 4 
  puts "进入ensure"
  

  return arr
end

arr = hello()

p arr

# 如果ensure显式的return,此值将替换begin块或rescue块中的返回值
# 但可以修改begin、rescue的返回变量，仅修改变量