# 使用惰性遍历



class Enumerator::Lazy
  def filter_map
    Lazy.new(self) do |yielder, *values|
      puts "输出values"
      p values

      result = yield *values
      yielder << result if result
    end
  end
end

le = (1..Float::INFINITY).lazy

result = le.filter_map { |i| i * i if i.even? }.first(8)
p result