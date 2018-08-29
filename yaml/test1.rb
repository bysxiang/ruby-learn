require 'psych'
require 'yaml'

class Xx
  def initialize(name)
    @name = name
  end

  def to_yaml(opts = {})
    puts "进入"
    return @name
  end
end

YAML.add_builtin_type("omap") do |type, val|
  Xx.new(val.to_s)
end

xx_arr = [ Xx.new("java"), Xx.new("c#") ]

puts YAML.dump(xx_arr)

