
f = File.new("./s1.csv", 'w')

puts "开始读写"

startTime = Time.now
1.upto(63000) do |i|
	f.puts "#{i}  写文dsflsdjfdsldsjlfkjdsljflsdjflksjdlkfjsdjjjjjjjfkjldjfldsjlfjdsljfldsjflsdjlfjslkjflskjfljsljdflsjdlkfjsdkljflksdjfsjflkjslfjslfjlsjflsjdlkf "
end
f.close()
endTime = Time.now

puts "共用时#{endTime - startTime}"