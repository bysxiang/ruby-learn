require 'psych'
require 'yaml'

class Xx
  def initialize(name)
    @name = name
    @pxx = 13
  end

  def to_yaml_type
    puts "进入to_yaml_type"
  end

  def to_yaml(opts = {})
    puts "输出opts, #{opts}"
    YAML.quick_emit(self, opts) do |out|
      out.seq() do |seq|
        puts "输出"
        p seq
        seq.add(:name => @name)
      end
    end
    
  end
end

class Yy
  def initialize(name)
    @name = name
  end
end

types = YAML.add_builtin_type("omapxx") do |type, val|
  puts "type: #{type}, val: #{val}"
  Xx.new(val.to_s)
end

xx = YAML.load_file("./omap.yml")

p xx

p xx["pool"].class

p xx["pool"].to_yaml()
