module M
    def self.included(base)
        puts "#{base}我被加入了"
        
        base.extend ClassMethods
    end

    def self.append_features(mod)
        puts "#{mod}模块 -M - append_features"
    end

    module ClassMethods
        def self.extended(mod)
            puts "#{mod}继承了我"
            mod.instance_variable_set("@_xx", [])
        end

        def self.included(base = nil, &block)
            puts "重写的included"
        end

        def self.append_features(mod)
            puts "#{base}模块 - ClassMethods - append_features"
        end

        def my_method
            puts "我是类方法my_method"
        end
    end
end

class Mn
    include M
end

p Mn.methods


#p Mn.methods()
