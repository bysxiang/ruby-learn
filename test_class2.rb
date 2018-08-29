
class Class
    def class_att(att)
        attr_writer :name2
    end

end

class A
    class_att :name2
end

p A.methods
p A.instance_methods