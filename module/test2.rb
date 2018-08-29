# 测试一个类中含有两个同名方法

module Abc
    def show
        puts "我来自Abc.show"
    end
end

class Show
    include Abc

    def show()
        super
        puts "来自Show.show"
    end
end 

s = Show.new

s.show
