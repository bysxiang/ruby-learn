# 因为Abc会被继承，所以这里的方法，都变成了类方法
# 而最终的模块是要被include的，所以这里实际是覆盖了
# 继承此模块的接收者的
# append_features, included方法
module Abc

    def self.extended(base)
        puts "#{base}继承了我"
    end

    def append_features(base)
        puts "append的base, #{base}, #{self}"
    end

    def included(base)
        puts "我是#{base}.abc"
    end
end

module Dcc
    extend Abc

end

class Aee
    include Dcc
end

a = Aee.new

p Abc.singleton_class
