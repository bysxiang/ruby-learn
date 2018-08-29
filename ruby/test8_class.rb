# 验证单件类与类的关系

class Module
    def yuanshuai_show
        puts "火狐"
    end
end

class Abc
    private
    def show

    end
end


p Abc.private_instance_methods(false)

p Abc.singleton_class.instance_methods().grep(/^yuanshuai/)

Abc.yuanshuai_show