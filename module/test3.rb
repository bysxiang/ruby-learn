# 测试private 对类的修饰

# private对类无效

module Abc
    private
        class Dcc

        end
end

class Dbb
    include Abc
end

x = Dbb::Dcc.new

p x