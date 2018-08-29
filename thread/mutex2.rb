class Test1
  attr_reader :count

  def initialize()
    @count = 0
    # @mutex = Mutex.new
    # @empty = ConditionVariable.new
  end


  # def use
  #   @mutex.lock
  #     c = @count
  #     c += 1
  #     @count = c
  #     #@empty.signal
  #     #@empty.wait(@mutex)
  #   @mutex.unlock
  # end

  def use
    # c = @count
    # c += 1
    @count += 1
  end

  def release
    # @mutex.synchronize do 
    #   @empty.signal
    # end
  end
end

def test(t1)
  t1.use
end

t1 = Test1.new

trs = []
5000.times do |i|
  trs << Thread.new { 
    #puts "i:#{i}"; 
    test(t1)
  }
end

trs.each do |t|
  t.join()
end

#sleep 10

puts "t1.count = #{t1.count}"