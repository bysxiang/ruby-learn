# 使用多行字符串，<<-ABC是一个占位符，可以将它作为一个参数来对待
# 和使用，包括调用方法

def show(str, inx)
  puts "输出参数, in: #{inx}"
  p str
  #puts str
end


show(<<ABC, 3)
  lsjdflsd
  sdlfjdsljfsd
  jslfjsd
ABC