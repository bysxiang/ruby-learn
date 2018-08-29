class A
  def initialize()
    puts "a的构造函数"
  end

  def p_a
    p self
  end
end

class B < A

end

b = B.new

p b.kind_of? B

p b.kind_of? A

b.p_a