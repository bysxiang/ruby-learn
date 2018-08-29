# 

def message_function
  str = "java"

  func = lambda do |xx|
    puts "#{str}, #{xx.to_s}"
  end
  str = "ruby"
  return func
end

func = message_function

func.call("c#")