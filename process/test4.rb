# 测试管道，从父进程流入子进程
# 管道是半双工的，意味着数据只能从一端流入另一端
# 例如：以下例子从父进程流入子进程，那么需要关闭父进程
# 的写入端，从父进程写入管道。
# 关闭子进程的写入端，以便读取父进程的输入。

# 如果父进程未写入，而且关闭了读取端。
# 那么子进程通过reader.read将会产生阻塞，除非
# 父端执行writer.close方法。

reader, writer = IO.pipe

pid = fork()
if pid

  #sleep 1

  puts "输出pid: #{pid}"

  puts "进入父进程"
  reader.close()

  #sleep(10)

  puts "现在父进程写入"
  # writer.write("hello, java")
  # writer.close()

  puts "父进程写入完毕"

  Process.wait
else
  puts "进入子进程"

  writer.close()

  puts "获取父进程输入：#{reader.read()}"

  puts "子进程完毕"
end