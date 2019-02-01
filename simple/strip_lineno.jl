#=
@macroexpand will dump a verbose representation,
where the LineNumberNode can be distracting, so
I write this util function to strip the unnecessary info.
=#

function strip_lineno(ex::Expr)
    args = ex.args
    res = []
    for arg in args
        if arg isa Expr
            arg = strip_lineno(arg)
        elseif arg isa LineNumberNode
            continue
        end
        push!(res, arg)
    end
    Expr(ex.head, res...)
end
