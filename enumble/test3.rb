module Enumerable
  def filter_map(&block)
    map(&block).compact
  end
end

le = (1..Float::INFINITY)

result = le.filter_map { |i| i * i if i.even? }.first(5)
p result