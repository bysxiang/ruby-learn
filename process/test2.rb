rd, wr = IO.pipe

pid = fork()
if pid
  #sleep 1
  puts "父进程"
  
  wr.close()
  puts "Parent got: <#{rd.read}>"
  rd.close()
  cid = 0
  #cid = Process.wait
  puts "等待完毕, #{cid}"
else
  puts "子进程"
  puts "Sending message to parent"

  sleep 10

  wr.write "hi, java"
  wr.close
  
  puts "子进程完毕"
end