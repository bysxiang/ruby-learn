# 在类范围内，无论是使用define还是class_eval都是在定义类方法

class Abc

end

Abc.singleton_class.instance_eval do 
  define_method(:hello) {  }

  class_eval "def use_xx; true; end", __FILE__, __LINE__
end

p Abc.singleton_class.instance_methods
