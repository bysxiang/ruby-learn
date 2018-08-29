class Sheep
  def initialize
    @shorn = false
  end

  def shorn?
    @shorn
  end

  def shear!
    puts "shearing..., #{Thread.current}, #{@shorn}"
    @shorn = true
  end
end

sheep = Sheep.new

def test(sp)
  user1 = Thread.new do
    unless sp.shorn?
      sleep 0.001
      sp.shear!
    end
  end

  user2 = Thread.new do
    unless sp.shorn?
      sp.shear!
    end
  end

  user3 = Thread.new do
    unless sp.shorn?
      sp.shear!
    end
  end

  while !user1.stop? || !user2.stop? || !user3.stop?
    sleep 1
  end
end

def test2(sp)
  user1 = Thread.new do
    unless sp.shorn?
      sleep 0.001
      sp.shear!
    end
  end.join()

  user2 = Thread.new do
    unless sp.shorn?
      sp.shear!
    end
  end.join()

  user3 = Thread.new do
    unless sp.shorn?
      sp.shear!
    end
  end.join()
end

test2(sheep)

puts "结束"



