require "active_model"

class Person
  include ActiveModel::Dirty

  define_attribute_methods [:name]

  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def name=(val)
    unless val == @name
      name_will_change!()
    end

    @name = val
  end

  def save
    @previously_changed = changes
    @changed_attributes.clear
  end

end

person = Person.new("java")
p person.changed?
person.name = "cxx"
person.name = "cbb"
p person.changed?
p person.changes
p person.changed_attributes
person.reset_name!

p person