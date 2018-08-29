module Hello
  APP = 44
  
end

class A
  include Hello
  #APP = 333
  
end

class Object
  #APP = 99
end

module Kernel
  APP = 100
end

module M
  #APP = 7
  class B < A
    #include Hello
    p Module.nesting
    p ancestors
    p APP
  end
end

#p A::B::APP