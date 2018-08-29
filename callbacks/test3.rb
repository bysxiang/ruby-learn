require 'active_support/concern'
require 'active_support/descendants_tracker'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/object/inclusion'
require 'pry'
require 'pry-nav'

module ActiveSupport
  
  module Callbacks
    extend Concern

    included do
      extend ActiveSupport::DescendantsTracker
    end

    # 执行事件的回调
    def run_callbacks(kind, *args, &block)
      send("_run_#{kind}_callbacks", *args, &block)
    end

    private

    def halted_callback_hook(filter)
    end

    class Callback #:nodoc:#
      @@_callback_sequence = 0

      attr_accessor :chain, :filter, :kind, :options, :per_key, :klass, :raw_filter

      # kind 表示回调的类型【before, after, around】
      def initialize(chain, filter, kind, options, klass)
        @chain, @kind, @klass = chain, kind, klass
        normalize_options!(options)

        @per_key              = options.delete(:per_key)
        @raw_filter, @options = filter, options
        @filter               = _compile_filter(filter)
        @compiled_options     = _compile_options(options)
        @callback_id          = next_id

        _compile_per_key_options
      end

      def clone(chain, klass)
        obj                  = super()
        obj.chain            = chain
        obj.klass            = klass
        obj.per_key          = @per_key.dup
        obj.options          = @options.dup
        obj.per_key[:if]     = @per_key[:if].dup
        obj.per_key[:unless] = @per_key[:unless].dup
        obj.options[:if]     = @options[:if].dup
        obj.options[:unless] = @options[:unless].dup
        obj
      end

      def normalize_options!(options)
        options[:if] = Array.wrap(options[:if])
        options[:unless] = Array.wrap(options[:unless])

        options[:per_key] ||= {}
        options[:per_key][:if] = Array.wrap(options[:per_key][:if])
        options[:per_key][:unless] = Array.wrap(options[:per_key][:unless])
      end

      def name
        chain.name
      end

      def next_id
        @@_callback_sequence += 1
      end

      def matches?(_kind, _filter)
        @kind == _kind && @filter == _filter
      end

      def _update_filter(filter_options, new_options)
        filter_options[:if].push(new_options[:unless]) if new_options.key?(:unless)
        filter_options[:unless].push(new_options[:if]) if new_options.key?(:if)
      end

      def recompile!(_options, _per_key)
        _update_filter(self.options, _options)
        _update_filter(self.per_key, _per_key)

        @callback_id      = next_id
        @filter           = _compile_filter(@raw_filter)
        @compiled_options = _compile_options(@options)
                            _compile_per_key_options
      end

      def _compile_per_key_options
        key_options  = _compile_options(@per_key)

        @klass.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def _one_time_conditions_valid_#{@callback_id}?
            true if #{key_options}
          end
        RUBY_EVAL
      end

      def start(key=nil, object=nil)
        return if key && !object.send("_one_time_conditions_valid_#{@callback_id}?")

        case @kind
        when :before
          <<-RUBY_EVAL
            if !halted && #{@compiled_options}
              # This double assignment is to prevent warnings in 1.9.3 as
              # the `result` variable is not always used except if the
              # terminator code refers to it.
              result = result = #{@filter}
              halted = (#{chain.config[:terminator]})
              if halted
                halted_callback_hook(#{@raw_filter.inspect.inspect})
              end
            end
          RUBY_EVAL
        when :around
          
          name = "_conditional_callback_#{@kind}_#{next_id}"
          @klass.class_eval <<-RUBY_EVAL,  __FILE__, __LINE__ + 1
             def #{name}(halted)
              if #{@compiled_options} && !halted
                #{@filter} do
                  yield self
                end
              else
                yield self
              end
            end
          RUBY_EVAL
          "#{name}(halted) do"
        end
      end

      def end(key=nil, object=nil)
        return if key && !object.send("_one_time_conditions_valid_#{@callback_id}?")

        case @kind
        when :after
          # after_save :filter_name, :if => :condition
          <<-RUBY_EVAL
          if #{@compiled_options}
            #{@filter}
          end
          RUBY_EVAL
        when :around
          <<-RUBY_EVAL
            value
          end
          RUBY_EVAL
        end
      end

      private

      def _compile_options(options)
        conditions = ["true"]

        unless options[:if].empty?
          conditions << Array.wrap(_compile_filter(options[:if]))
        end

        unless options[:unless].empty?
          conditions << Array.wrap(_compile_filter(options[:unless])).map {|f| "!#{f}"}
        end

        conditions.flatten.join(" && ")
      end

      def _compile_filter(filter)
        method_name = "_callback_#{@kind}_#{next_id}"
        case filter
        when Array
          filter.map {|f| _compile_filter(f)}
        when Symbol
          filter
        when String
          "(#{filter})"
        when Proc
          @klass.send(:define_method, method_name, &filter)
          return method_name if filter.arity <= 0

          method_name << (filter.arity == 1 ? "(self)" : " self, Proc.new ")
        else
          @klass.send(:define_method, "#{method_name}_object") { filter }

          _normalize_legacy_filter(kind, filter)
          scopes = Array.wrap(chain.config[:scope])
          method_to_call = scopes.map{ |s| s.is_a?(Symbol) ? send(s) : s }.join("_")

          @klass.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{method_name}(&blk)
              #{method_name}_object.send(:#{method_to_call}, self, &blk)
            end
          RUBY_EVAL

          method_name
        end
      end

      def _normalize_legacy_filter(kind, filter)
        if !filter.respond_to?(kind) && filter.respond_to?(:filter)
          filter.singleton_class.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{kind}(context, &block) filter(context, &block) end
          RUBY_EVAL
        elsif filter.respond_to?(:before) && filter.respond_to?(:after) && kind == :around
          def filter.around(context)
            should_continue = before(context)
            yield if should_continue
            after(context)
          end
        end
      end
    end # .. end Callback

    class CallbackChain < Array #:nodoc:#
      attr_reader :name, :config

      def initialize(name, config)
        @name = name
        @config = {
          :terminator => "false",
          :rescuable => false,
          :scope => [ :kind ]
        }.merge(config)
      end

      def compile(key=nil, object=nil)
        method = []
        method << "value = nil"
        method << "halted = false"

        each do |callback|
          xx = callback.start(key, object)
          method << xx
        end

        if config[:rescuable]
          method << "rescued_error = nil"
          method << "begin"
        end

        method << "value = yield if block_given? && !halted"

        if config[:rescuable]
          method << "rescue Exception => e"
          method << "rescued_error = e"
          method << "end"
        end

        reverse_each do |callback|
          method << callback.end(key, object)
        end

        method << "raise rescued_error if rescued_error" if config[:rescuable]
        method << "halted ? false : (block_given? ? value : true)"
        method.compact.join("\n")
      end
    end # .. end CallbackChain

    module ClassMethods
      # Generate the internal runner method called by +run_callbacks+.
      # 生成_run_#{callback}_callbacks方法，用于+run_callbacks+方法调用
      def __define_runner(symbol) #:nodoc:
        runner_method = "_run_#{symbol}_callbacks" 
        unless private_method_defined?(runner_method)
          class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{runner_method}(key = nil, &blk)
              self.class.__run_callback(key, :#{symbol}, self, &blk)
            end
            private :#{runner_method}
          RUBY_EVAL
        end
      end

      def __run_callback(key, kind, object, &blk) #:nodoc:
        name = __callback_runner_name(key, kind)
        unless object.respond_to?(name, true)
          str = object.send("_#{kind}_callbacks").compile(key, object)
          puts "输出str"
          puts str
          class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{name}() #{str} end
            protected :#{name}
          RUBY_EVAL
        end
        object.send(name, &blk)
      end

      def __reset_runner(symbol)
        name = __callback_runner_name(nil, symbol)
        undef_method(name) if method_defined?(name)
      end

      def __callback_runner_name(key, kind)
        "_run__#{self.name.hash.abs}__#{kind}__#{key.hash.abs}__callbacks"
      end

      def __update_callbacks(name, filters = [], block = nil) #:nodoc:
        type = filters.first.in?([:before, :after, :around]) ? filters.shift : :before
        options = filters.last.is_a?(Hash) ? filters.pop : {}
        filters.unshift(block) if block

        ([self] + ActiveSupport::DescendantsTracker.descendants(self)).reverse.each do |target|
          chain = target.send("_#{name}_callbacks")
          yield target, chain.dup, type, filters, options
          target.__reset_runner(name)
        end
      end

      def set_callback(name, *filter_list, &block)
        mapped = nil

        __update_callbacks(name, filter_list, block) do |target, chain, type, filters, options|
          mapped ||= filters.map do |filter|
            Callback.new(chain, filter, type, options.dup, self)
          end

          filters.each do |filter|
            chain.delete_if {|c| c.matches?(type, filter) }
          end

          options[:prepend] ? chain.unshift(*(mapped.reverse)) : chain.push(*mapped)
          
          target.send("_#{name}_callbacks=", chain)
        end
      end

      def skip_callback(name, *filter_list, &block)
        __update_callbacks(name, filter_list, block) do |target, chain, type, filters, options|
          filters.each do |filter|
            filter = chain.find {|c| c.matches?(type, filter) }

            if filter && options.any?
              new_filter = filter.clone(chain, self)
              chain.insert(chain.index(filter), new_filter)
              new_filter.recompile!(options, options[:per_key] || {})
            end

            chain.delete(filter)
          end
          target.send("_#{name}_callbacks=", chain)
        end
      end

      def reset_callbacks(symbol)
        callbacks = send("_#{symbol}_callbacks")

        ActiveSupport::DescendantsTracker.descendants(self).each do |target|
          chain = target.send("_#{symbol}_callbacks").dup
          callbacks.each { |c| chain.delete(c) }
          target.send("_#{symbol}_callbacks=", chain)
          target.__reset_runner(symbol)
        end

        self.send("_#{symbol}_callbacks=", callbacks.dup.clear)

        __reset_runner(symbol)
      end

      # 设置一个_#{callback}_callbacks的类属性
      # 并将每个(种)callback都设置为CallbackChain对象
      def define_callbacks(*callbacks)
        config = callbacks.last.is_a?(Hash) ? callbacks.pop : {}
        
        callbacks.each do |callback|
          class_attribute "_#{callback}_callbacks"
          cc = CallbackChain.new(callback, config)
          send("_#{callback}_callbacks=", cc)
          __define_runner(callback)
        end
      end
    end
  end
end

# 测试同一事件，多个回调

class Abc
  include ActiveSupport::Callbacks

  define_callbacks :save
  set_callback :save, :saving_message
  #set_callback :save, :before, :saving_message2, per_key: { :if => proc { |abc| puts "输出abc"; return false; } }
  #set_callback :save, :before, :saving_message2, per_key: { :if => proc { |abc| abc.hh == "index2" } }
  # 如果set_callback指定了per_key选项，必须在执行run_run_callbacks也要传递一个key才能执行这里的条件
  set_callback :save, :before, :saving_message3, per_key: { if: :hh4 }

  def saving_message
    puts "saving..."

    return false
  end

  def saving_message2
    puts "saving2..."
  end

  def saving_message3
    puts "saving3..."
  end

  def hh
    puts "进入hh"
    return "index"
  end

  def hh4
    return true
  end

  def save
    
    run_callbacks :save, :action do 
      puts "- save"
    end
  end
end

a = Abc.new
a.save
