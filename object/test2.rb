class Defc
  @@abc = 5577
end

module Agc
  
end

class Abc
  @@abc = "33"

  def show
    @@abc
  end
end



class Object
  #@@abc = 44
end



p Abc.new.show