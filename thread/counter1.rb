# mutex互斥锁，即使在锁内部sleep, 也不会容许其他线程进入，被篡改

class Counter
  attr_reader :count

  def initialize
    @count = 0
    @mutex = Mutex.new
    @empty = ConditionVariable.new
  end

  def tick
    @mutex.synchronize do
      puts "进入资源"
      @count = (@count + 1)
      #@empty.wait(@mutex)
      #@mutex.sleep 0.001
      sleep 1

    end
  end

  def tick2
    @count = (@count + 1)
  end
end

c = Counter.new

trs = []
5.times do |i|
  trs << Thread.new { 
    c.tick
  }
end

trs.each do |t|
  t.join()
end

# t1 = Thread.new { 100_000.times { c.tick };  }
# t2 = Thread.new { 100_000.times { c.tick };  }
# t3 = Thread.new { 100_000.times { c.tick } }

# t1.join
# t2.join
# t3.join

p c.count