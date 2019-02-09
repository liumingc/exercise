abstract type Result end
struct Succ <: Result
    path::Vector
end

struct Fail <: Result end

function filter1(pred, xs)
    acc = []
    flag = false
    for x in xs
        if !pred(x)
            if flag == false
                flag = true
                continue
            end
        end
        push!(acc, x)
    end
    return acc
end

function calc_24(cards, path)
    if length(cards) == 1
        if cards[1] == 24
            println("Got! ", path)
            return Succ(path)
        else
            # println("Fail, path=", path)
            return Fail
        end
    end

    for x in cards
        rst1 = filter1(elt -> elt != x, cards)
        for y in rst1
            for op in (+, -, *, /)
                nx = 0
                if op == /
                    if y == 0
                        continue
                    end
                    nx, remain = divrem(x, y)
                    if remain > 0
                        continue
                    end
                else
                    nx = op(x, y)
                end
                # nx = floor(op(x, y))
                rst2 = filter1(elt -> elt != y, rst1)
                # path = push!(path, (x, op, y))
                lpath = cat(path, [(x, op, y)]; dims=1)
                ncards = cat(rst2, [nx]; dims=1)
                res = calc_24(ncards, lpath)
                if res isa Succ
                    break
                end
            end
        end
    end
end

calc_24([3, 8, 10, 10], [])
