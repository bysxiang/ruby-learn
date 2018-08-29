# 测试method.send

class Abc
  def hello(name)
    puts "#{name}"
  end

  def xx
    Abc.send(:define_method, "xx_object") { puts "我是xx_object" }

    Abc.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def xx_to
        p xx_object
        xx_object.send(:hello, "java")
      end
    RUBY
  end

end

abc = Abc.new
abc.xx
abc.xx_to


