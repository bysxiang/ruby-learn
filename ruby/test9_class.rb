module Abc

    module Xxx

    end
end

module Dess
    p const_defined?("Abc")
end 