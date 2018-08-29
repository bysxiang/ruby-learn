module Abc
    def initialize()
        super()
        puts "这是模块abc的"
    end
end

module Def
    def initialize()
        #super()
        puts "这是模块def的"
    end
end

class Show
    #include Def
    include Abc
    

    def initialize()
        super()
        puts "这是Show类"
    end
end

s = Show.new