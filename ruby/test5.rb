# 生成一个9000个元素的数组

arr = []

1.upto(8999) do |i|
    arr << { id: i, name: i.to_s + "_name", created_time: "ldsjfldsjlfjsdljfsldj" }
end

# 计算数组查询的效率
_beforeTime = Time.now

arrHash = Hash[arr.map{ |item| [item[:id], item[:name]] }]
1.upto(8999) do |i|
  index = arr.find_index do |item|
    item[:id] == i
  end

  val = arr[index]

  #val = arrHash[i]

end
_afterTime = Time.now

puts "共耗时#{_afterTime.to_i - _beforeTime.to_i}s"