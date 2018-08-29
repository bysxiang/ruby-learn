module Foo
    def self.included(base)
        base.class_eval do 

            def self.method_injected_by_foo
                p self
                puts "Foo模块调用method_injected_by_foo"
            end
        end
    end
end

module Bar
    def self.included(base)
        base.method_injected_by_foo
    end
end

class Host
    include Foo
    include Bar
end

p Host.singleton_class.instance_methods
