class Abc

  def initialize()

    puts "初始化方法"
  end

  private_class_method :new

  class << self
    @_instance = nil
    def instance()
      if @_instance.nil?
        @_instance = new
      else
        puts "单例对象已存在"
      end

      return @_instance
    end
  end


end

Abc.new

# abc = Abc.instance

# abc2 = Abc.instance

# p abc

# p abc2