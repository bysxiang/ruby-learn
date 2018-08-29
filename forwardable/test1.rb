require 'forwardable'

class RecordCollection
  extend Forwardable

  attr_accessor :records
  def_delegator :@records, :[], :at_index_ff

  def initialize()
    @records = [1, 3, 3, 4]
  end
end

rc = RecordCollection.new


p rc.records[1]

p rc.send(:[], 1)

p rc.at_index_ff(1)