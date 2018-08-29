module Foo
    def self.included(base)
        p base
        base.class_eval do 
            p self
            def self.method_injected_by_foo
                p self
                puts "Foo模块调用method_injected_by_foo"
            end
        end
    end
end

module Bar
    include Foo # Bar包含了Foo，执行Foo.included方法，它实际是在Bar.singleton_class上定义了方法

    puts "输出Bar,的方法"
    p self.singleton_class.instance_methods().grep(/method_injected_by_foo/)

    def self.included(base)
        # 要想处理这种依赖，必须将依赖模块的included回调内的代码在当前
        # 环境上执行
        
        # base.class_eval do 
        #     def self.method_injected_by_foo
        #         p self
        #         puts "Foo模块调用method_injected_by_foo"
        #     end
        # end

        puts "base:#{base}"
        base.method_injected_by_foo

        
    end
end

class Host
    include Bar
end

# 对于这种情况，