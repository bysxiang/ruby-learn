require "pathname"

pn = Pathname.new("/root/work/ruby-learn/path_name/test/s1.txt")
p pn.size
p pn.directory?
p pn.dirname
p pn.dirname.class
p pn.split()

data = pn.read

p data