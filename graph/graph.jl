module GraphMod

import Base.==

export Node, Graph, addedge, show, make_data

mutable struct Node
    pred::Set # = Set()
    succ::Set # = Set()
    name::String
    no::Int
end

function Node(; name::String)
    Node(Set(), Set(), name, 0)
end

mutable struct Graph
    roots::Set{Node}
end

function ==(x::Node, y::Node)
    x.name == y.name
end

function hash(x::Node)
    hash(x.name)
end

function findnode(g::Graph, x::Node)
    visited = Set{Node}()
    function inner_find(r::Node)
        if r in visited
            return nothing
        end
        union!(visited, [r])
        if r == x
            return r
        end
        for elt = r.succ
            res = inner_find(elt)
            if res != nothing
                return res
            end
        end
        return nothing
    end

    for r = g.roots
        res = inner_find(r)
        if res != nothing
            return res
        end
    end
    return nothing
end

function addedge(g::Graph, x::Node, y::Node)
    res = findnode(g, x)
    if res == nothing
        union!(g.roots, [x])
        res = x
    end
    resy = findnode(g, y)
    resy == nothing && (resy = y)
    union!(res.succ, [resy])
    union!(resy.pred, [res])
end

function addedge(g::Graph, x::String, y::String)
    addedge(g, Node(name=x), Node(name=y))
end

function show(io::IO, x::Node)
    visited = Set{Node}()
    function inner_show(n::Node, indent)
        println(io, ' '^indent, n.name)
        if n in visited
            return
        end
        union!(visited, [n])
        for elt = n.succ
            inner_show(elt, indent+1)
        end
    end

    inner_show(x, 0)
end

function show(io::IO, g::Graph)
    for r = g.roots
        println("=====")
        show(io, r)
    end
end

function main()
    g = Graph(Set())
    addedge(g, Node(name="a"), Node(name="b"))
    addedge(g, Node(name="a"), Node(name="c"))
    addedge(g, Node(name="b"), Node(name="c"))
    addedge(g, Node(name="c"), Node(name="a"))
    addedge(g, Node(name="c"), Node(name="d"))
    addedge(g, Node(name="d"), Node(name="a"))
    addedge(g, Node(name="b"), Node(name="e"))
    show(stdout, g)
end

#=
entry -- b1 -- b2 -- exit
         |               ^
         |           b5 -+
         +---- b3 -- b4 -- b6
                     ^     |
                     |     |
                     +-----+
=#
function make_data()
    g = Graph(Set())
    addedge(g, "entry", "b1")
    addedge(g, "b1", "b2")
    addedge(g, "b1", "b3")
    addedge(g, "b2", "exit")
    addedge(g, "b3", "b4")
    addedge(g, "b4", "b6")
    addedge(g, "b6", "b4")
    addedge(g, "b4", "b5")
    addedge(g, "b5", "exit")
    return g
end

# main()

end # end module Graph