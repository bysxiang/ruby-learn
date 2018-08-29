h = { a: 33, b: 44 }

def xx(h)
  v = h.fetch(:a) { return 55}
  return v
end

p xx(h)