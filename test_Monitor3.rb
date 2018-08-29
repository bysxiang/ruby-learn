require 'monitor.rb'

buf = []
buf.extend(MonitorMixin)
empty_cond = buf.new_cond

Thread.start do 
  loop do
    buf.synchronize do
      empty_cond.wait_while { buf.empty? }
      puts "线程3得到了"
      print buf.shift
    end
    #sleep(1)
  end
end

# consumer
Thread.start do
  loop do
    buf.synchronize do
        while buf.empty?
          beforeTime = Time.now
          puts "线程1开始等待。。。"
          b = empty_cond.wait(5)
          afterTime = Time.now
          puts "b: #{b}, 等待了#{afterTime.to_i - beforeTime.to_i}s"
        end
        
        print buf.shift

        empty_cond.signal
    end
    #sleep(1)
  end
end

Thread.start do 
  loop do
    buf.synchronize do
      puts "线程2开始等待。。。"
      #empty_cond.wait_while { buf.empty? }
      
      puts "线程2完成10s等待"
      sleep(10)
      empty_cond.wait(2)
      empty_cond.signal
    end
    #sleep(1)
  end
end

# Thread.start do 
#   loop do
#     buf.synchronize do
#       #empty_cond.wait_while { buf.empty? }
      
#       empty_cond.wait(2)
#       puts "线程3完成5s等待"
#       empty_cond.signal
#     end
#     #sleep(1)
#   end
# end


# producer
while line = ARGF.gets
  buf.synchronize do
    buf.push(line)
    #empty_cond.signal
    puts "#{Time.now}"
  end
end