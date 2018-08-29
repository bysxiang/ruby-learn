class Abc
  def initialize()
    @arr = [nil, nil, false, 10, 2, 3, 4, 5, 6]
    @i = 0
  end

  def next()
    item = @arr[@i]
    @i += 1

    return item
  end

  def last?
    return @i >= @arr.length
  end 
end

abc = Abc.new

# until item = abc.next() || abc.last?()  do

# end

# while !!(item = abc.next()) == false && abc.last?() == false do 

# end

while !!(item = abc.next()) == false && abc.last?() == false; end


puts "item = #{item}"