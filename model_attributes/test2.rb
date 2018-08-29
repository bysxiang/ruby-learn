require 'active_model'

class Abc
    include ActiveModel::AttributeMethods

    attr_accessor :attributes

    attr_accessor :name

    attribute_method_prefix 'clear_'
    define_attribute_methods [:name]


    def initialize()
        @attributes= { name: "java", age: 14 }
    end

    private
        def attribute(attr_name)
            puts "执行"
            @attributes[attr_name.to_sym]
        end

        def clear_attribute(attr_name)
            send("#{attr_name}=", nil)
        end
    
end

a = Abc.new

p a.name

a.name = "xxx"

p a.name

a.clear_name

p a.name



