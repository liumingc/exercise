
function cross_product(fn, xs, ys)
    res = [fn(x, y) for y in ys for x in xs]
    return res
end

function test()
    res = cross_product(+, [1, 2, 3], [10, 20, 30])
    println(res)
    res = cross_product(tuple, ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
                               [1, 2, 3, 4, 5, 6, 7, 8])
    println(res)
end

test()
