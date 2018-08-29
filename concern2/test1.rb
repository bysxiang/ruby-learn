module Foo
  def show_foo
    puts "Foo.show_foo"
  end
end

module Bar
  include Foo

  def self.included(base)
    #base.show_foo
  end

  def show_bar
    show_foo
    puts "Bar.show_bar"
  end 

  def append_features(base)
    puts "输出base:#{base}"

    super
  end
end

class Abc
  #include Foo
  include Bar
end

a = Abc.new
#a.show_foo
a.show_bar