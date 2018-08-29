# append_features, included执行顺序问题

module Abc

    def self.included(base)
        puts "in"
    end

    def self.append_features(base)
        puts "aapp"
    end
end

class Dcc
    include Abc
end