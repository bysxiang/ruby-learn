# 测试是否会被include两次,
#
# 结论是不会

module Foo

  def self.included(base)
    puts "foo#included"
    super
  end

  def self.append_features(base)
    puts "foo#append_features, self:#{self}, base:#{base}"
    super
  end
end

module Bar
  include Foo

  def self.included(base)
    puts "bar#included"
    super
  end

  def self.append_features(base)
    puts "bar#append_features, self:#{self}, base:#{base}"
    super
  end
end

class Host
  include Bar
end