# 模块Abc禁用于被继承
module Abc
    def show

    end

    def self.extended(mod)
        puts "我被继承#{mod}"
        mod.instance_variable_set("@_xx", 33)
    end

    def append_features(mod)

        puts "我被钓鱼那个#{mod}"
    end

    def included(base = nil)

    end

end

singleton = class << Module
    self
end



p Module.instance_methods(false).grep(/include/)

p Module.public_class_method()

p singleton.private_instance_methods().grep(/include/)

# module Dcc
#     extend Abc
# end




