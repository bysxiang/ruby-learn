def hello
  exception = nil
  begin
    x = 33
    raise "不知道2"
  rescue => e
    puts "发生异常：#{e.message}"
    exception = e
  ensure
    i
  end
end

begin
  x = hello

  p x
rescue => e
  puts "发生了异常，外部"
end