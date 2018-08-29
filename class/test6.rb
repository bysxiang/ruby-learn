module RailModule

  def inherited(base)
    puts "base: #{base}, self.superclass: #{self.superclass.name}"
  end
end

class Rail
  def self.inherited(base)

    base.extend RailModule
  end
end

class Abc < Rail

end

class Def < Abc

end