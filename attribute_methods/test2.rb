require 'active_support/concern'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/class/attribute'
require 'active_support/deprecation'
require 'pry'
require 'pry-nav'

module ActiveModel
  class MissingAttributeError < NoMethodError
  end
  
  module AttributeMethods
    extend ActiveSupport::Concern

    # 定义可由def 形式定义的方法规则
    NAME_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?=]?\z/
    # 定义调用方法的规则，对于"c?x"，无法直接调用，只能通过send来调用
    # 规则中=结尾也不支持，可能是由于不需要处理那样的方法
    CALL_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?]?\z/

    included do
      # 保存属性方法匹配对象的集合
      class_attribute :attribute_method_matchers, :instance_writer => false
      self.attribute_method_matchers = [ClassMethods::AttributeMethodMatcher.new]
    end

    module ClassMethods

      def attribute_method_prefix(*prefixes)
        self.attribute_method_matchers += prefixes.map { |prefix| AttributeMethodMatcher.new :prefix => prefix }
        undefine_attribute_methods
      end

      def attribute_method_suffix(*suffixes)
        self.attribute_method_matchers += suffixes.map { |suffix| AttributeMethodMatcher.new :suffix => suffix }
        undefine_attribute_methods
      end

      def attribute_method_affix(*affixes)
        self.attribute_method_matchers += affixes.map { |affix| AttributeMethodMatcher.new :prefix => affix[:prefix], :suffix => affix[:suffix] }
        undefine_attribute_methods
      end

      # 定义别名属性方法
      def alias_attribute(new_name, old_name)
        attribute_method_matchers.each do |matcher|
          matcher_new = matcher.method_name(new_name).to_s
          matcher_old = matcher.method_name(old_name).to_s
          define_optimized_call self, matcher_new, matcher_old
        end
      end

      def define_attribute_methods(attr_names)
        attr_names.each { |attr_name| define_attribute_method(attr_name) }
      end

      # 定义attribute_method属性方法
      # 根据匹配器集合，如果方法还未被定义，通过define_optimized_call来处理
      # 你需要定义prefix_attribute_suffix方法，来处理这些前后缀方法
      def define_attribute_method(attr_name)
        attribute_method_matchers.each do |matcher|
          method_name = matcher.method_name(attr_name)

          unless instance_method_already_implemented?(method_name)
            generate_method = "define_method_#{matcher.method_missing_target}"

            if respond_to?(generate_method, true)
              send(generate_method, attr_name)
            else
              define_optimized_call generated_attribute_methods, method_name, matcher.method_missing_target, attr_name.to_s
            end
          end
        end
        attribute_method_matchers_cache.clear
      end

      # Removes all the previously dynamically defined methods from the class
      # 从类中删除所有先前动态定义的方法
      def undefine_attribute_methods
        generated_attribute_methods.module_eval do
          instance_methods.each { |m| undef_method(m) }
        end
        attribute_method_matchers_cache.clear
      end

      # Returns true if the attribute methods defined have been generated.
      # 这个方法第一次调用，生成一个Module的实例对象, 返回true
      # 这个@generated_attribute_methods用于保存定义在其之上的方法，
      # 当前的类include这个模块，后续在@generated_attribute_methods
      # 上定义的新方法，当前类的实例方法都会生成
      def generated_attribute_methods #:nodoc:
        @generated_attribute_methods ||= begin
          mod = Module.new
          include mod
          mod
        end

        @generated_attribute_methods
      end

      protected
        # 方法是否已存在于@generated_attribute_methods中
        def instance_method_already_implemented?(method_name)
          generated_attribute_methods.method_defined?(method_name)
        end

      private
        def attribute_method_matchers_cache #:nodoc:
          @attribute_method_matchers_cache ||= {}
        end

        # 获取匹配此方法名称的AttributeMethodMatch结构对象
        # 优先从缓存中读取
        def attribute_method_matcher(method_name) #:nodoc:
          if attribute_method_matchers_cache.key?(method_name)
            attribute_method_matchers_cache[method_name]
          else
            matchers = attribute_method_matchers.partition(&:plain?).reverse.flatten(1)
            match = nil
            matchers.detect { |method| match = method.match(method_name) }
            binding.pry
            attribute_method_matchers_cache[method_name] = match
          end
        end

        def define_optimized_call(mod, name, send, *extra) #:nodoc:
          p "#{mod}, #{name}, #{send}"

          if name =~ NAME_COMPILABLE_REGEXP
            defn = "def #{name}(*args)"
          else
            defn = "define_method(:'#{name}') do |*args|"
          end

          extra = (extra.map(&:inspect) << "*args").join(", ")

          if send =~ CALL_COMPILABLE_REGEXP
            target = "#{send}(#{extra})"
          else
            target = "send(:'#{send}', #{extra})"
          end

          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            #{defn}
              #{target}
            end
          RUBY
        end

        # 属性方法匹配类
        class AttributeMethodMatcher
          attr_reader :prefix, :suffix, :method_missing_target

          AttributeMethodMatch = Struct.new(:target, :attr_name, :method_name)

          def initialize(options = {})
            options.symbolize_keys!

            if options[:prefix] == '' || options[:suffix] == ''
              ActiveSupport::Deprecation.warn(
                "Specifying an empty prefix/suffix for an attribute method is no longer " \
                "necessary. If the un-prefixed/suffixed version of the method has not been " \
                "defined when `define_attribute_methods` is called, it will be defined " \
                "automatically."
              )
            end

            @prefix, @suffix = options[:prefix] || '', options[:suffix] || ''
            @regex = /\A(#{Regexp.escape(@prefix)})(.+?)(#{Regexp.escape(@suffix)})\z/
            @method_missing_target = "#{@prefix}attribute#{@suffix}"
            @method_name = "#{prefix}%s#{suffix}"
          end

          def match(method_name)
            
            result = nil
            if @regex =~ method_name
              result = AttributeMethodMatch.new(method_missing_target, $2, method_name)
            else
              nil
            end

            return result
          end

          # 获取生成的属性名称
          def method_name(attr_name)
            @method_name % attr_name
          end

          def plain?
            prefix.empty? && suffix.empty?
          end
        end # .. end AttributeMethodMatcher
    end # ClassMethods .. end

    def method_missing(method, *args, &block)
      # 判断此方法是否已存在于所有方法中
      # 如果是私有方法，仍由系统逻辑来处理
      binding.pry
      if respond_to_without_attributes?(method, true)
        super
      else
        #binding.pry
        puts "进入method_missing分支处理"
        match = match_attribute_method?(method.to_s)
        binding.pry
        match ? attribute_missing(match, *args, &block) : super
      end
    end

    def attribute_missing(match, *args, &block)
      __send__(match.target, match.attr_name, *args, &block)
    end

    alias :respond_to_without_attributes? :respond_to? # respond_to_without_attributes? 指向之前的旧方法
    def respond_to?(method, include_private_methods = false)
      if super
        true
      elsif !include_private_methods && super(method, true)
        # If we're here then we haven't found among non-private methods
        # but found among all methods. Which means that the given method is private.
        # 意味着此方法是私有的
        false
      else
        !match_attribute_method?(method.to_s).nil?
      end
    end

    protected
      def attribute_method?(attr_name)
        respond_to_without_attributes?(:attributes) && attributes.include?(attr_name)
      end

    private
      def match_attribute_method?(method_name)
        match = self.class.send(:attribute_method_matcher, method_name)
        binding.pry
        match && attribute_method?(match.attr_name) ? match : nil
      end

      def missing_attribute(attr_name, stack)
        raise ActiveModel::MissingAttributeError, "missing attribute: #{attr_name}", stack
      end
  end
end

class Abc
  include ActiveModel::AttributeMethods

  attr_accessor :attributes

  attribute_method_prefix "clear_"

  define_attribute_methods [:name2]

  

  def initialize()

  end

  # def name2
  #   puts "我是name2"
  # end

  private
    def attribute(val)
      puts "输出val: #{val}"
    end

    def clear_attribute(val)
      puts "clear_ 输出val: #{val}"
    end
end

p Abc.instance_methods.grep(/name2/)

a = Abc.new
a.name2
