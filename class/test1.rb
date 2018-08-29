# 测试类方法的self
# 在单件类内部，self仍然是外部的self
# 在单件类内部定义的方法，仍可由外部的self来访问

class Abc
    def self.hello
        p self
    end

    class << self
        p self
        def hello3
            puts "我是hello3"
        end

        class_eval <<-ruby, __FILE__, __LINE__ + 1
            def hello2

            end
        ruby
    end
end

Abc.hello
Abc.hello3

p Abc.singleton_class.instance_methods().grep(/^hello/)