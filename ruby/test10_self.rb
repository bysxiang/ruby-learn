class Abc
  def initialize()
    @config = { 
      scope: []
    }

  end

  def kind
    puts "调用我kind"
    "kind"
  end

  def name2
    puts "调用我-name2"
    "name2"
  end

  def hh
    arr = [:kind, :name2, "xx"]

    r = arr.map { |item| item.to_s }.join("_")
    p r
  end
end

a = Abc.new
a.hh