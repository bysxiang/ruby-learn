arr = [1, 2, 3, 4]

h = { a: 1, b: 2, c: 3 }

pattern = {}

arr.each { |pat, *v| pattern[pat] = v.fetch(0) {pat} }

p pattern

pattern = {}
h.each { |pat, *v| pattern[pat] = v.fetch(0) {pat} }

p pattern