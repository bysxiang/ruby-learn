require "strscan"

s = StringScanner.new("This is an example string")

p s.scan(/\w+/)
p s.pos

p s.scan(/\w+/)
p s.pos

p s.scan(/\s+/)
p s.pos

p s.scan(/\s+/)
p s.pos