module Admin
  autoload :User, "./user.rb"
  autoload :Aa, "./user.rb"
  #require "./user.rb"

  class Abc

  end
  p constants(false)

  #remove_const :User

  p constants(false)

  #p const_defined?(:Aa)

  #p User
  #p Aa

  User
  # puts "定义了吗"

  # p Object.const_get(:User, false)
  #p Admin.const_get(:User)
end

#p Admin.const_defined?(:User, false)

#require "./user2.rb"

# p Object.const_get(:User, false)
# User.show
#p Admin.const_get(:User, false)


# p Admin.constants().sort

# p Object.const_get(:User)

#p Admin::User