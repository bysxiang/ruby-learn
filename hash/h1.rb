a = { a: 1, b: 3}

t = :a

case t
when a.keys
  puts "包含:a, :b"
else
  puts "不包含"
end