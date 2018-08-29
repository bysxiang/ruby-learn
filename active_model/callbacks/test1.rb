require 'active_model'

class MyModel
  extend ActiveModel::Callbacks

  def create
    run_callbacks :create do 
      puts "创建"
    end
  end

  def before_create
    puts "创建前。。。"
  end

  define_model_callbacks :create

  before_create :before_create
end

mm = MyModel.new
mm.create