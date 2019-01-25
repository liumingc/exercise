import Base.==

mutable struct Node
    pred::Set # = Set()
    succ::Set # = Set()
    name::String
end

function Node(; name::String)
    Node(Set(), Set(), name)
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

function findNode(g::Graph, x::Node)
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
    res = findNode(g, x)
    if res == nothing
        union!(g.roots, [x])
        res = x
    end
    union!(res.succ, [y])
    union!(y.pred, [res])
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
    show(stdout, g)
end

main()
