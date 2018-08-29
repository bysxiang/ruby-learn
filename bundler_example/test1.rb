before = $LOAD_PATH

require 'bundler/setup'

Bundler.require(:default)

foo = Atomic.new(true)
puts "输出Atomic Foo?"
puts foo.value

# 当使用Bundler.require(:default)时，它夹在这些gem，并加载依赖
# 它修改了$LOAD_PATH, 将当前gem安装目录插入在前面
# 确保当require 'active_support/all'时，使用的是bundler指定的版本
require 'active_support/all'

p ActiveSupport::VERSION::STRING
