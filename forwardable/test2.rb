require 'forwardable'

class RecordCollection
  extend Forwardable

  attr_accessor :records
  def_delegators :@records, :push, :size

  def initialize()
    @records = [1, 3, 3, 4]
  end
end

rc = RecordCollection.new

rc.push(55)

p rc.records

p rc.size

