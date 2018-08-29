# 测试included回调

module Abc
    
end

module Abc

    def included()
        puts "sss"
    end
end

class Dccc

    include Abc

end