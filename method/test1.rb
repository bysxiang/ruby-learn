# 测试方法调用的问题

class Abc

    define_method :"c?x" do 
        puts "我是c?x"
    end
end


a = Abc.new

a.send(:"c?x")
