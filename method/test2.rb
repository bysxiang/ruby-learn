# 测试方法别名

class Dcc
    def show
        puts "我是show1"
    end
end

class Abc < Dcc

    def show
        super
        puts "我是show2"
    end

    alias :al_show :show

    
end

a = Abc.new
a.al_show

a.show