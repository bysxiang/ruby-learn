# 测试Module#const_missing

class Abc
    def self.const_missing(name)
        puts "#{name}丢失"
    end
    
    
end

# Module.nesting 方法返回一个数组，它的模块嵌套结构
# [M1::M2::M3, M1::M2, M1]
module M1
    module M2
        module M3
            p Module.nesting
        end
    end
end

#M1::M2.nesting