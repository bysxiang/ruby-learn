require 'pry'
require 'pry-nav'

begin
  require './st.rb'
rescue Exception => e
  binding.pry
  p e.message.class
  p e.message
  puts "输出"
  
end