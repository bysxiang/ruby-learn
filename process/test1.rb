rd, wr = IO.pipe

p rd.class
p wr.class

pid = fork()
if pid
  sleep 1
  puts "父进程"
  wr.close
  puts "Parent got: <#{rd.read}>"
  rd.close
  puts "开始等待"
  Process.wait
  puts "等待完毕"
else
  puts "子进程"
  rd.close
  puts "Sending message to parent"
  wr.write "Hi Dad"
  wr.close
end