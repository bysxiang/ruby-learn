module Abc
    def acc
        p self
        
        singleton_class.class_eval <<-ruby, __FILE__, __LINE__ + 1
            p self
            def aa()
                p self
                puts "我是aa"
            end
        ruby

        # class << self
        #     def aa()
                
        #     end
        # end

        aa()
        puts "我是acc"
    end
end

class Dcc
    extend Abc
end

Dcc.acc
