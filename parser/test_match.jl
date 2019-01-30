
sym_cnt = 0
function _gensym()
    global sym_cnt
    sym_cnt += 1
    return Symbol("_match_var#" * string(sym_cnt))
end

#=
function rewrite_case(ex, var)
    @assert ex.head === :call
    @assert length(ex.args) === 3
    @assert ex.args[1] == :(=>)
    arrow, value, body = ex.args
    :(if $var == $value; begin $body end)
end
=#

function rewrite_cases(cases, var)
    res = nothing
    lastexpr = nothing
    for case in cases
        @assert case.head === :call
        @assert length(case.args) == 3
        @assert case.args[1] === :(=>)
        arrow, value, body = case.args
        if lastexpr == nothing
            lastexpr = Expr(:if, :($var == $value), body)
            res = lastexpr
        elseif value == :(_)
            # ex = Expr(:else, body)
            push!(lastexpr.args, body)
            break
        else
            ex = Expr(:elseif, :($var == $value), body)
            # println("lastexpr: ", lastexpr, "\nex: ", ex, "\n")
            push!(lastexpr.args, ex)
            lastexpr = ex
        end
    end
    return res
end

macro match(expr, body)
    # println(expr, "\n", body)
    @assert body.head === :block
    # println("head:", body.head, "\nargs:", body.args)
    var = _gensym()
    cases = filter(x -> !(x isa LineNumberNode), body.args)
    # cases = map(rewrite_case, cases)
    cases = rewrite_cases(cases, var)
    res = :(let $var = $expr; begin
    $cases
    end
    end)
    # println("cases: ", cases, "\nres: ", res)
    res
end

res1 = @match(1+3, begin
    2 => "hello"
    4 => "world"
    _ => "default"
end)

res2 = @match(2 * 3, begin
    5 => "impossible"
    6 => "yes"
end)

println("res1=", res1, "\nres2=", res2)