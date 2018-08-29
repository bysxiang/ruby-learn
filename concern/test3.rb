module Dcc
    def show()
        puts "我是Dcc#show"
        super
    end
end 

class Abc
    def initialize()
        extend Dcc
    end

    def show
        puts "我是hh"
    end

end

a = Abc.new

a.show