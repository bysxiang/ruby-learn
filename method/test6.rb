# 测试私有方法重写
# show方法调用show_name, 当子类也定义此方法，它实际调用的就是
# 子类的方法, 由于show_name对于子类根本是不可见的，这里实际
# 调用的就是子类方法

class Abc
  def show
    show_name
  end

  private
    def show_name
      puts "我是abc"
    end
end

class Defc < Abc

  # def show
  #   puts "Defc"
  # end

  private
    def show_name
      puts "我是defc"
    end
end

d = Defc.new

d.show