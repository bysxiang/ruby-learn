# 测试模块include
# 类中调用super的关系

module Abc
    def initialize()
        #super()
        @aaa = 33
        puts "这是模块abc的"
    end

    def show_aaa()
        puts @aaa
    end
end

module Def
    def initialize()
        #super()
        puts "这是模块def的"
    end
end

class Show
    include Def
    include Abc
    
    # def initialize()
    #     super()
    #     puts "这是Show类"
    # end


end

s = Show.new
p Show.singleton_class.instance_methods().grep(/init/)

# 当我们include一个模块时，其实就相当于当前类继承了这个模块
# 如果这个模块定义了一个和现有类同名方法，那么在现有类
# 调用super，将调用此模块的同名方法，如果include多个模块
# 都定义了同名方法，将后面的覆盖签名的
# 证明，当我们调用super时，这个super实际调用的是之前模块的intialize方法，
# 实际上当一类或一个模块include一个模块时，这个模块含有initialize,它实际上覆盖了
# 当前类的方法