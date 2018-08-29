# 测试模块方法
# 证明在模块中执行module_eval, class_eval
# 生成的是实例方法

module Abc

    module_eval <<-ruby, __FILE__, __LINE__ + 1
        def aa
            puts 3333
        end
    ruby

    def aa2

    end
end



p Abc.instance_methods