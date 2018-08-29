module Admin
  autoload :User, "./user.rb"
  #require "./user.rb"

  class Abc

  end
  p constants(false)

  u = const_get(:User)
  remove_const :User

  p Object.const_get(:User, false)

  #p constants()

  # p User

  # APP = 33
  # remove_const :APP
  # puts "输出app:#{APP}"
end