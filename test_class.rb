class Class
    def class_att(att)

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
    
            def self.#{att}
                nil
            end

            def self.#{att}=(val)
                
                self.singleton_class.class_eval do 
                    begin

                        if method_defined? :#{att}
                            remove_method :#{att}
                        end
                    rescue NameError

                    end
                
                    define_method :#{att} do

                        val
                    end
                end 

            end
        RUBY
    end
end

class A
    class_att :name2

    p @name2
end

class B < A

    
end

# A.name2 = "java"

# p A.name2
# p B.name2

# B.name2 = "dfd"

# p A.name2
# p B.name2

A.name2 = [:foo]

p A.name2
p B.name2

B.name2 << :java2

p A.name2
p B.name2
