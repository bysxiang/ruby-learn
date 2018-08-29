

def hello()
  r = nil

  begin
    puts "进入begin"
    raise "hh"
    r = 44

    puts "进入begin之后"
    
    r
  rescue => e
    puts "进入rescue"
    
    r = 55

    puts "rescue之后，r:#{r}"

    r
  ensure
    puts "进入ensure"
    r = 33
    puts "进入ensure之后r: #{r}"
    
    r
  end

  # puts "我要输出77"
  # 77
end

# 对于begin rescue ensure 如果这三个分支都包括return语句，ensure权限最高，只会执行
# ensure中的语句，begin rescue 中return语句之后的不会执行
# 如果ensuce语句下面还有return，即return 77，这句不会执行

p hello()