# 单例模式-残缺版
class Abc
  class << self
    private
      def new
        super
        puts "进入new"
      end
  end

  def self.instance
    new
  end

  def initialize()
    puts "进入init"
  end
end

# 对于一个类来说，new是类方法，initialize是实例方法
# 默认情况下Abc.new调用Abc.new方法，它默认会调用initialize
# 

# 实现单例方法，private :new，只对之前的new有效，对于后边代码定义的:new是无效的，
# ruby是解释性的语言，只对之前的内容有效


#a = Abc.new

a1 = Abc.instance
