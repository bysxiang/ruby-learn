
# 验证append_features, included顺序问题
module Bar

  def show_bar
    puts "Bar.show_bar"
  end 

  def self.included(base = nil)
    puts "输出included base: #{base}"
    super
  end

  def self.append_features(base)
    puts "输出base:#{base}"

    super
  end
end

class Abc
  include 

end

a = Abc.new
#a.show_foo
#a.show_bar