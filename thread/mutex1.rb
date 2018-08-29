require "thread"

class Resource
  attr_reader :left, :times_had_to_wait

  def initialize(count)
    @left = count
    @times_had_to_wait = 0
    @mutex = Mutex.new
    @empty = ConditionVariable.new
  end

  def use
    @mutex.synchronize do 
      while @left <= 0
        @times_had_to_wait += 1
        @empty.wait(@mutex)
      end
      @left -= 1
    end

  end

  def release
    @mutex.synchronize do 
      @left += 1
      if @left == 1
        @empty.signal
      end
      
    end
  end

end

def do_something_with(resource)
  resource.use
  sleep 0.001
  resource.release
end

class Test1
  attr_reader :count

  def initialize()
    @count = 0
    @mutex = Mutex.new
    @empty = ConditionVariable.new
  end

  # def use
  #   @mutex.synchronize do 
  #     @count += 1
  #     #@empty.wait(@mutex)
  #   end
  # end

  def use
    @mutex.lock
      c = @count
      c += 1
      @count = c
      #@empty.signal
      #@empty.wait(@mutex)
    @mutex.unlock
  end

  def use
    c = @count
    c += 1
    @count = c
  end

  def use1000
    10000.times { self.use; sleep 0.001; }
  end

  def release
    @mutex.synchronize do 
      @empty.signal
    end
  end
end

def test(t1)
  t1.use
  
  #t1.release
end

t1 = Test1.new
user1 = Thread.new { t1.use1000 }
user2 = Thread.new { t1.use1000 }
user3 = Thread.new { t1.use1000 }
user4 = Thread.new { t1.use1000 }

while ! user1.stop? || ! user2.stop? || ! user3.stop? || ! user4.stop?
  sleep 1
end

puts "t1.count = #{t1.count}"