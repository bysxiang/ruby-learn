# 测试class_eval self

module Kernel
  def class_eval(*args, &block)
    puts "重写了"
    singleton_class.class_eval(*args, &block)
  end
end

class Abc

end

Abc.class_eval <<-RUBY, __FILE__, __LINE__ + 1
  def hh
    puts "我送hih"
  end
RUBY

Abc.new.singleton_class.class_eval <<-xx, __FILE__, __LINE__ + 1
  p self

xx

a = Abc.new
a.hh


