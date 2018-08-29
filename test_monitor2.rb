require 'monitor.rb'

buf = []
buf.extend(MonitorMixin)
empty_cond = buf.new_cond

# consumer
Thread.start do
  loop do
    buf.synchronize do
        while buf.empty?
          b = empty_cond.wait(5)
          puts "b: #{b}"
        end
        
        puts "线程1得到了#{Time.now}"
        print buf.shift
      
    end
    #sleep(1)
  end
end

# Thread.start do 
#   loop do
#     buf.synchronize do
#       #empty_cond.wait(1)
#       puts "线程2开始等待"
#       empty_cond.wait_while { buf.empty? }
#       puts "线程2得到了"
#       print buf.shift
#     end
#     #sleep(1)
#   end
# end

# Thread.start do 
#   loop do
#     buf.synchronize do
#       empty_cond.wait_while { buf.empty? }
#       puts "线程3得到了"
#       print buf.shift
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