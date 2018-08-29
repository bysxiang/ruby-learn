# 定义了别名，即使原方法被删除，依然有效

class Abc
  def show
    puts "你是谁"
  end

  alias :show2 :show

  remove_method :show
end

abc = Abc.new

abc.show