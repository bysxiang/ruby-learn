

def process_test(arr)
    [1, 2, 3].each do |i|
        p arr
        # arr = arr.map { |line| line + 1 }

        arr = arr.select{ |line| line > 5}
    end

    return arr
end


arr2 = [5, 6, 7, 8]

p process_test(arr2)
