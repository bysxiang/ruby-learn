# 模块类级方法是否会被继承

module Abc

    def self.xxx

    end

    def x2

    end
end

class Cxx
    include Abc
end

c = Cxx.new

p c.methods.grep(/^x/)
p Cxx.methods.grep(/^x/)

# 模块类级方法不会被继承

class Bxx
    def initialize()
        extend Abc
    end
end

b = Bxx.new

p b.methods.grep(/^x/)
p Bxx.methods.grep(/^x/)

# 模块类级方法不会被继承