module Concern
  class MultipleIncludedBlocks < StandardError #:nodoc:
    def initialize
      super "Cannot define multiple 'included' blocks for a Concern"
    end
  end

  # 当有模块继承此模块时，它包含此模块中的实例方法
  # 到base中，这个方法在base模块中定义了@_dependencies实例
  # 变量@_dependencies
  def self.extended(base) #:nodoc:
    base.instance_variable_set(:@_dependencies, [])
  end

  def append_features(base)
   #puts "输出self: #{self}, base: #{base}, #{base.instance_variable_defined?(:@_dependencies)}"

    # 只有继承了Concern模块的模块才可以处理依赖
    if base.instance_variable_defined?(:@_dependencies)
      base.instance_variable_get(:@_dependencies) << self
      false
    else
      if base < self
        return false
      else
        puts "else self:#{self}, base:#{base}  11111"

        p @_dependencies
        # 这里是一个递归操作，先include依赖的模块
        @_dependencies.each { |dep| base.include(dep) }

        puts "else self:#{self}, base:#{base}  22222"
        super
        
        if instance_variable_defined?(:@_included_block)
          puts "block: base:#{base},self: #{self}"
          base.class_eval(&@_included_block)
        end
      end
      
    end # else .. end
  end # append_features .. end

  def included(base = nil, &block)
    #puts "输出base1: #{base}, self: #{self}"
    if base.nil?
      if instance_variable_defined?(:@_included_block)
        raise MultipleIncludedBlocks
      end

      # 在模块实例中保存block
      # puts "在#{self}上保存了block"
      @_included_block = block
    else
      super
    end
  end
end

module Foo
  extend Concern

  included do 
    #puts "输出self, #{self}"
    def self.method_injected_by_foo
      puts "foo模块的方法"
    end
  end
end

module Bar
  extend Concern

  include Foo
  included do
    self.method_injected_by_foo
  end
end

class Host
  include Bar
end

p Foo.instance_variable_get("@_dependencies")

p Bar.instance_variable_get("@_dependencies")