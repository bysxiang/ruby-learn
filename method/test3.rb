# 测试respond_to?

class Abc
    @attributes = {}
    attr_reader :attributes
end

a = Abc.new

p a.respond_to?(:attributes)