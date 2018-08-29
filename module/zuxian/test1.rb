module Hello
  APP = 44
  
end

module Hello2
  APP = 55
end

APP = 77

module M1
  #APP = 33
  module M2
    #prepend Hello
    include Hello2
    
    #APP = 88
    puts "输出APP"
    p APP

    p ancestors
  end
end


#p M1::M2.