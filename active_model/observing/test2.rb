require 'singleton'
require 'active_model/observer_array'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/remove_method'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/enumerable'
require 'active_support/descendants_tracker'
require 'active_support/concern'
require 'pry'
require 'pry-nav'

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
        puts "输出observers, #{observers.object_id}"
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
end

class AbcObserver < ActiveModel::Observer
end

class AbbObserver < ActiveModel::Observer
  observe :abc
end

Abc.observers = :abc_observer, :abb_observer

io = Abc.instantiate_observers
p io.object_id

puts "输出"
p Abc.observer_instances
p Abc.observer_instances.class



# class Defc < Abc

# end

# puts "输出Defc.observer_instances"
# p Defc.observer_instances
