# 测试extend语法
#
# 如果是一个对象extend一个模块，则模块实例方法成为对象的实例方法
# 如果一个模块或类extend一个模块，则模块实例方法成为对象类方法

module M
  def self.show2
    puts "self.show2"
  end

  def show
    puts "m.show"
  end
end

class Abc
  
end

a = Abc.new
a.extend M

a.show
p a.singleton_class.methods