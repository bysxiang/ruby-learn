# 继承来的常量

module Abc
    XX = 33
end

module Dcc
    include Abc
end

p Abc.const_defined?(:XX)
p Dcc.const_defined?(:XX, false)

p Dcc::XX

