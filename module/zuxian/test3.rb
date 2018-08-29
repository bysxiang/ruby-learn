# module Hello
#   APP = 44
  
# end

# class A
#   include Hello
#   #APP = 77
# end

# module M
#   #include Hello
#   #APP = 55
#   class B < A
#     #include Hello

#     p ancestors
#   end
# end

# puts "输出B::A::APP"
# p M::B::APP

class A

  def self.const_missing(name)
    puts "进入A. #{name}"
  end
end

module M

  def self.const_missing(name)
    puts "进入M. #{name}"
    super
  end

  class B < A

    def self.const_missing(name)
      puts "进入B. #{name}"
      super
    end
  end
end

p M::B::APP