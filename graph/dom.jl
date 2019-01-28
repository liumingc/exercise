# find dominators

include("graph.jl")
using .GraphMod


function postorder_visit(g::Graph)
    tbl = Dict()
    visited = Set()
    no = 0

    function aux(n::Node)
        if n in visited
            return
        end
        union!(visited, [n])
        no += 1
        tbl[no] = n
        for c in n.succ
            aux(c)
        end
    end

    for r in g.roots
        aux(r)
    end
    return tbl
end

function print_postorder(tbl)
    println("print post order")
    for (no, x) in tbl
        println(no, " => ", x.name)
    end
end

dom = Dict{Node, Set}()

function allnode(tbl)
    Set([v for (_, v) in tbl])
end

function init_dom(tbl)
    r = tbl[1]
    dom[r] = Set([r])

    for i=2:length(tbl)
        n = tbl[i]
        dom[n] = allnode(tbl)
    end
end


function collect_dom(g::Graph)
    tbl = postorder_visit(g)
    print_postorder(tbl)

    init_dom(tbl)
    while true
        change = false
        for i=1:length(tbl)
            n = tbl[i]
            coll = dom[n]
            old_sz = length(coll)

            if length(n.pred) >= 1
                all = allnode(tbl)
                res = reduce(intersect, [dom[x] for x in n.pred]; init=all)
                #=
                for r in res
                    println(" +", n.name, "|", r.name)
                end
                =#
                union!(res, [n])
            else
                continue
            end

            new_sz = length(res)
            # if new_sz != old_sz
            if !issetequal(coll, res)
                change = true
                dom[n] = res
            end
        end
        if !change
            break
        end
    end
end

function main()
    g = make_data()
    # println("g=", g)
    collect_dom(g)
    for (x, lst) in dom
        println("dom: ", x.name)
        for elt in lst
            print("\t", elt.name)
        end
        println("")
    end
end

main()
