rd, wr = IO.pipe

pid = fork()
if pid # 父进程
  # 这里如果不将写入端关闭，
  # 管道读取端无法生成末尾条件，导致无法读取
  wr.close

  #puts "输出: #{rd.read}"
  puts "结合素"
else # 子进程
  puts "子进程"

  sleep 1
  puts "睡眠结束"
  # wr.write("jhi")
  # wr.close

  puts "子进程完毕"
end