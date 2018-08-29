# alias 为方法创建别名
# 如果这个方法的新别名与现有方法冲突，将取代现有方法
# 即使将include M语句放到alias之后，还是无效。

module M
  def show
    puts "M.show"
  end
end

class Abc
  include M

  def show2
    puts "Abc.show2"
  end

  

  alias :show :show2


end

a = Abc.new
a.show