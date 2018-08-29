

class Abc
  def show

  end

  def self.new
    super()
  end
end

p Abc.public_methods(false).sort

puts ""

p Abc.superclass.public_methods(false).sort

# public_methods返回的是当前对象的公共方法，即类或对象实例的公共方法，
# 毕竟类或模块也是对象

puts ""
a = Abc.new
p a

# 如果重写了self.new方法，调用super()执行的是Class#new方法, 不执行这个是无法正常生成类对象的