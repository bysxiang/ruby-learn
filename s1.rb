x = "cc"

def my_method
	x = "aa"
	
	puts x 
	
	if block_given?
		yield
	end
end

#x = "bb"

my_method do 
	puts "#{x}"
end


