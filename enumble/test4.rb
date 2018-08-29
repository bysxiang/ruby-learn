# enum_for与to_enum方法作用是一样的。
# enum_for将str的each_byte方法绑定到了
# 迭代器上。

str = "xyz"

#enum = str.enum_for(:each_byte)

enum = str.to_enum(:each_byte)

enum.each { |b| puts b }

