def a(skip)
  caller(skip)
end

arr = a(0)
call_stack = arr.map { |p| p.sub(/:\d+.*/, '') }

p call_stack