class Abc
  include Enumerable

  def initialize()
    @arr = [1, 3, 5, 7]
    @index = 0
  end

  def each2(*args)
    puts "进入each2"
    p args
    3.times do |i|
      yield i
    end
  end

  # 事实上，each其实只执行一次，
  # 具体的遍历是由each内部的实现
  # 来决定的
  def each(*args)
    if ! block_given?
      # 这里将:each2绑定到enumerable上
      # ,调用each方法将实际调用:each2
      # 如果提供一个块，这个块用来计算迭代的大小
      # 即调用Enumerator#size来执行这个块
      return to_enum(:each2, *args) { puts "to_enum"; size(); }
    else
      puts "进入each"
      while @index < @arr.length
        yield @arr[@index]
        @index += 1
      end

      self
    end
  end # def each .. end

  def size

  end

end

a = Abc.new

e = a.each("java")

x = e.each do |i|
  p i
end

p e.inspect
p e.size
