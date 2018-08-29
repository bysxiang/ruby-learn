class Object
  def initialize
    super
    puts "Module的initialize"
  end
end

class Bff
  def initialize
    #super
    puts "Bff的initialize"
  end
end

class Abc < Bff
  def initialize()
    puts "调用第一个initialize"
    super # 调用Defc#initialize, 它
  end

  module Defc
    def initialize
      puts "Defc的intialize"
      super
      puts "之后"
    end
  end

  include Defc

  private
    def hh
      puts "hh"
      super
    end

end

abc = Abc.new

p Abc.methods.grep(/hh/)

# 类Abc继承自Bff，又include了Defc，这个模块中的
# initialize方法覆盖了initiazlie方法，
# 此文件中的继承链为Bff -> Defc -> Abc
# 每个类多有一个默认的initialize, 调用.new,它将会调用initalize