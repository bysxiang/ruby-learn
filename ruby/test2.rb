module Foo
    def self.included(base)
        base.class_eval do 
            puts "我被夹在 了"
            def self.method_injected_by_foo
                #p self
                puts "Foo模块调用method_injected_by_foo"
            end
        end
    end
end

module Bar
    include Foo

    p self.instance_methods

    def self.included(base)
        #p self
        p base

        base.method_injected_by_foo
    end
end

class Host
    include Bar
end

