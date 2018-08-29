module Abc
    def show

    end

    def self.included(mod)
        puts "我被加载了#{mod}"
    end

    def self.append_features(mod)
        puts "我被钓鱼那个#{mod}"
    end
end

class Hello
    include Abc

end

