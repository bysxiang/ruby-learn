require 'singleton'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/remove_method'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/enumerable'
require 'active_support/descendants_tracker'
require 'active_support/concern'
require 'pry'
require 'pry-nav'

require 'set'
module ActiveModel
  class ObserverArray < Array
    attr_reader :model_class
    def initialize(model_class, *args)
      @model_class = model_class
      super(*args)
    end

    def disabled_for?(observer)
      disabled_observers.include?(observer.class)
    end

    def disable(*observers, &block)
      set_enablement(false, observers, &block)
    end

    def enable(*observers, &block)
      set_enablement(true, observers, &block)
    end

    protected
      # 禁用的观察者集合
      def disabled_observers
        @disabled_observers ||= Set.new
      end

      def observer_class_for(observer)
        return observer if observer.is_a?(Class)

        if observer.respond_to?(:to_sym) # string/symbol
          observer.to_s.camelize.constantize
        else
          raise ArgumentError, "#{observer} was not a class or a " +
            "lowercase, underscored class name as expected."
        end
      end

      def start_transaction
        disabled_observer_stack.push(disabled_observers.dup)
        each_subclass_array do |array|
          array.start_transaction
        end
      end

      # 禁用的观察器数组
      def disabled_observer_stack
        @disabled_observer_stack ||= []
      end

      def end_transaction
        @disabled_observers = disabled_observer_stack.pop
        each_subclass_array do |array|
          array.end_transaction
        end
      end

      def transaction
        start_transaction

        begin
          yield
        ensure
          end_transaction
        end
      end

      def each_subclass_array
        model_class.descendants.each do |subclass|
          yield subclass.observers
        end
      end

      def set_enablement(enabled, observers)
        if block_given?
          transaction do
            set_enablement(enabled, observers)
            yield
          end
        else
          observers = ActiveModel::Observer.descendants if observers == [:all]
          observers.each do |obs|
            klass = observer_class_for(obs)

            unless klass < ActiveModel::Observer
              raise ArgumentError.new("#{obs} does not refer to a valid observer")
            end

            if enabled
              disabled_observers.delete(klass)
            else
              disabled_observers << klass
            end
          end

          each_subclass_array do |array|
            array.set_enablement(enabled, observers)
          end
        end
      end
  end
end

module ActiveModel
  module Observing
    extend ActiveSupport::Concern

    included do
      extend ActiveSupport::DescendantsTracker
    end

    module ClassMethods
      
      def observers=(*values)
        observers.replace(values.flatten)
      end

      def observers
        @observers ||= ObserverArray.new(self)
      end

      def observer_instances
        @observer_instances ||= []
      end

      def instantiate_observers
        observers.each { |o| instantiate_observer(o) }
      end

      def add_observer(observer)
        unless observer.respond_to? :update
          raise ArgumentError, "observer needs to respond to `update'"
        end
        observer_instances << observer
      end

      def notify_observers(*arg)
        puts "进入#notify_observers"
        p arg
        p observer_instances
        observer_instances.each { |observer| observer.update(*arg) }
      end

      def count_observers
        observer_instances.size
      end

      protected
        def instantiate_observer(observer) #:nodoc:
          if observer.respond_to?(:to_sym)
            observer.to_s.camelize.constantize.instance
          elsif observer.respond_to?(:instance)
            observer.instance
          else
            raise ArgumentError,
              "#{observer} must be a lowercase, underscored class name (or an " +
              "instance of the class itself) responding to the instance " +
              "method. Example: Person.observers = :big_brother # calls " +
              "BigBrother.instance"
          end
        end

        def inherited(subclass)
          super
          notify_observers :observed_class_inherited, subclass
        end
    end # ClassMethods .. end

    private
      def notify_observers(method)
        puts "进入private方法"
        self.class.notify_observers(method, self)
      end
  end

  class Observer
    include Singleton # 实现单件模式
    extend ActiveSupport::DescendantsTracker

    class << self
      # Attaches the observer to the supplied model classes.
      # 附加要观察的模型类
      def observe(*models)
        models.flatten!
        models.collect! { |model| model.respond_to?(:to_sym) ? model.to_s.camelize.constantize : model }
        redefine_method(:observed_classes) { puts "进入observe"; models }
      end

      def observed_classes
        Array.wrap(observed_class)
      end

      def observed_class
        if observed_class_name = name[/(.*)Observer/, 1]
          observed_class_name.constantize
        else
          nil
        end
      end
    end # .. end class << self

    # Start observing the declared classes and their subclasses.
    def initialize
      observed_classes.each { |klass| add_observer!(klass) }
    end

    def observed_classes #:nodoc:
      self.class.observed_classes
    end

    def update(observed_method, object, &block) #:nodoc:
      return unless respond_to?(observed_method)
      return if disabled_for?(object)
      send(observed_method, object, &block)
    end

    def observed_class_inherited(subclass) #:nodoc:
      puts "输出self"
      p self
      self.class.observe(observed_classes + [subclass])
      add_observer!(subclass)
    end

    protected
      def add_observer!(klass) #:nodoc:
        puts "进入Observer#add_observer, #{klass}"
        klass.add_observer(self)
      end

      def disabled_for?(object)
        klass = object.class
        return false unless klass.respond_to?(:observers)
        klass.observers.disabled_for?(self)
      end
  end
end



class Abc
  include ActiveModel::Observing

  def xx()
    notify_observers(:xx_save)
  end
end

class AbcObserver < ActiveModel::Observer
  def xx_save(record)
    puts "触发xx_save方法, #{record}"
  end
end

Abc.observers = :abc_observer

io = Abc.instantiate_observers

class Defc < Abc

end

abc = Abc.new

p Abc.observers

puts "输出Defc.observers"
p Defc.observers

defc = Defc.new
p Defc.observer_instances