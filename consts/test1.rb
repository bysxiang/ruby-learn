# 常量to_s
# ::BB 引用的是Object中的常量

class Abc
    AAA = 33
end

class Object
    BB = 44
end

p ::BB