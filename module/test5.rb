@xx = begin
    mod = Module.new
    include mod
    mod
end

p @xx.methods.length