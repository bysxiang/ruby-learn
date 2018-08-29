class Abc
  include Enumerable

  def initialize()
    @arr = [1, 3, 5, 7]
    @index = 0
  end

  def each2
    puts "进入each2"
    3.times do |i|
      yield i + 1
    end
  end

  # 事实上，each其实只执行一次，
  # 具体的遍历是由each内部的实现
  # 来决定的
  def each
    if ! block_given?
      return to_enum(:each2) { size }
    else
      puts "进入each, #{@index}"
      while @index < @arr.length
        yield @arr[@index]
        @index += 1
      end

      self
    end
  end # def each .. end

end

a = Abc.new
e = a.each
e.each_with_index do |obj, index|
  puts "#{obj} - #{index}"
end

