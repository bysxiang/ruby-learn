class Hash
  def deep_dup
    duplicate = self.dup
    duplicate.each_pair do |k,v|
      
      tv = duplicate[k]
      puts "tv.id: #{tv.object_id}, v.id: #{v.object_id}"
      duplicate[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_dup : v
    end
    duplicate
  end
end

hash = { :a => { :b => 'b' } }
dup  = hash.deep_dup
dup[:a][:c] = 'c'

p hash[:a][:c] #=> nil
p dup[:a][:c]  #=> "c"