# extend basic block

include("graph.jl")
using .GraphMod

ebb_tbl = Dict{Node, Set{Node}}()

function build_ebb(r::Node, ebb::Set{Node})
    r in ebb && return
    union!(ebb, [r])
    for succ in r.succ
        if length(succ.pred) == 1
            build_ebb(succ, ebb)
        else
            if haskey(ebb_tbl, succ)
                continue
            end
            new_ebb =Set{Node}()
            merge!(ebb_tbl, Dict(succ => new_ebb))
            build_ebb(succ, new_ebb)
        end
    end
end

function build_ebb(g::Graph)
    for r in g.roots
        ebb = Set{Node}()
        merge!(ebb_tbl, Dict(r => ebb))
        build_ebb(r, ebb)
    end
end

function show_ebb()
    for (k, ebb) in ebb_tbl
        println(k.name, "=>")
        for e in ebb
            print(" | ", e.name)
        end
        println()
    end
end

function main()
    g = make_data()
    build_ebb(g)
    show_ebb()
end

main()
