@@v = "123"

class Abc
    @@v = "456"
end

p Object.class_variables(false)
p Abc.class_variables(false)

p Object.class_variable_get(:@@v)

p Object.class_variable_get(:@@v)

# 类变量可被继承，同时可被任意类在任意范围内覆盖掉
#， 它很类似于常量