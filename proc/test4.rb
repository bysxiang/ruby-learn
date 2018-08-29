
def hello
  yield
end

#result = nil

hello { result = 44 }

p result