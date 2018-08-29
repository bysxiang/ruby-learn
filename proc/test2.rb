class Abc
  def append(&block)
    block.call
  end
end

def abc()
  @acc = Abc.new
  if block_given?
    @acc.append(&Proc.new)
  end
end

# &Proc.new, 将传递给abc方法的块转换为一个Proc对象，传递给Abc#append方法

abc() { puts "123" }