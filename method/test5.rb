class Abc
  def xx

  end
end

class Defc < Abc

  def yy

  end
end

p Defc.public_instance_methods(true).length

p (Defc.public_instance_methods(true) + Defc.public_instance_methods(false)).uniq.length