def hello()
  r = 0
  begin
    puts "进入begin"
    r = 5
    #raise "sljdf"
  ensure
    puts "进入ensure, r: #{r}"
    r = 10
  end
end

x = hello()

p x