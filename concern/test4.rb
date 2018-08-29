# 测试include中的base, self

module Concern
    def self.extended(base)
        base.instance_variable_set("@_dependencies", [])
    end

    def append_features(base)
        if  base.instance_variable_defined?("@_dependencies")

            base.instance_variable_get("@_dependencies") << self
            puts "输出继承了Concern:#{base}"
            p @_dependencies
            return false
        else
            puts "输出self, #{self}, base, #{base}"
            p @_dependencies
            return false if base < self
            @_dependencies.each { |dep| base.send(:include, dep) }
            super
            base.extend const_get("ClassMethods") if const_defined?("ClassMethods")
            
            if const_defined?("InstanceMethods")
                base.send :include, const_get("InstanceMethods")
                ActiveSupport::Deprecation.warn "The InstanceMethods module inside ActiveSupport::Concern will be " \
                    "no longer included automatically. Please define instance methods directly in #{self} instead.", caller
            end
            
            if instance_variable_defined?("@_included_block")
                base.class_eval(&@_included_block)
            end
        end
    end
    
    def included(base = nil, &block)
        if base.nil?
            #puts "当前self: #{self}"
            @_included_block = block
        else
            super
        end
    end
end

module Dcc
    extend Concern

    included do 
        class_eval do 
            def self.show
                puts "woshi show"
            end
        end
    end
end

module Dbb
    extend Concern
    include Dcc

    included do
        self.show()
    end
end

class Hello
    include Dbb
end