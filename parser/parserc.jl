
struct State
    # run :: tokens -> expr, tokens
    run::Function
end

struct SyntaxError <: Exception end

# bind :: (a -> m b) -> m a -> m b
function bind(f::Function, s::State)::State
    State(tks -> begin
        ex, rst = s.run(tks)
        if ex == nothing
            return nothing, tks
        else
            return f(ex).run(rst)
        end
    end)
end

function orelse(s1::State, s2::State)::State
    State(tks -> begin
        res = s1.run(tks)
        ex1, rst = res
        if ex1 == nothing
            return s2.run(tks)
        else
            return res
        end
    end)
end

function seq(s1::State, s2::State)::State
    State(tks -> begin
        res = s1.run(tks)
        ex1, rst = res
        if ex1 == nothing
            return nothing, tks
        else
            return s2.run(rst)
        end
    end)
end

function combine(s1::State, s2::State)::State
    State(tks -> begin
        res = s1.run(tks)
        ex1, rst = res
        if ex1 == nothing
            return nothing, tks
        else
            res2 = s2.run(rst)
            ex2, rst2 = res2
            if ex2 == nothing
                return nothing, tks
            else
                return [ex1, ex2], rst2
            end
        end
    end)
end

function star_aux(s1::State, tks, acc::Array{})
    while true
        res = s1.run(tks)
        ex, rst = res
        # println("ex=", string(ex), ",rst=", rst, ",tks=", tks)
        println("acc=", acc, "tks=", tks)
        sleep(.5)
        if ex == nothing
            break
        else
            push!(acc, ex)
            tks = rst
        end
    end
    return acc, tks
end

function star(s1::State)::State
    State(tks -> star_aux(s1, tks, []))
end

function option(s1::State)::State
end

function plus(s1::State)::State
    combine(s1, star(s1))
end

function char_parser(ch)::State
    State(tks -> begin
        if isempty(tks)
            return nothing, tks
        elseif tks[1] == ch
            return string(ch), tks[2:end]
        else
            return nothing, tks
        end
    end)
end

kwtbl = Dict(
    "if" => :if,
    "elseif" => :elseif,
    "else" => :else,
    "begin" => :begin,
    "end" => :end
)

opset = Set{Any}(
    ['<', '=', '(', ')', '[', ']', ';', ',', '{', '}', '"', '\'']
)


function skip_space(text::AbstractString)
    i = 1
    while i < length(text)
        if !isspace(text[i])
            break
        end
        i += 1
    end
    return nothing, text[i:end]
end


function word(text::AbstractString)
    ign, text = skip_space(text)
    ch = text[1]
    if ch in opset
        return string(ch), text[2:end]
    end

    i = 1
    while i < length(text)
        if isspace(text[i]) || text[i] in opset
            i -= 1
            break
        end
        i += 1
    end
    return text[1:i], text[i+1:end]
end


function tokenize(text::AbstractString)
    lst = []
    while true
        wd, text = word(text)
        println("wd=|", wd, "|, rest=...")
        # sleep(.5)
        push!(lst, wd)
        if length(text) <= 0
            break
        end
    end
    return lst
end

function match_word(wd)
    State(tks -> begin
        tk = tks[1]
        if tk == wd
            return tk, tks[1:end]
        else
            throw(SyntaxError("expect " * wd * " found " * tk))
        end
    end)
end

function myparse(text::AbstractString)
    #toks = split(text)
    toks = tokenize(text)
    println("=toks=")
    println(toks)
end

function test1()
    res = myparse("""
    if a < 5
        println("small")
    elseif a < 10
        println("media")
    else
        println("big")
    """)
    #println("parsing result: ", res)
end

function test2()
    chp = char_parser('a')
    chstar = star(chp)
    function aux(tks, parser)
        res = parser.run(tks)
        println("input=", tks, ",result=", res)
    end
    aux("aaab", star(chp))
    aux("bcd", star(chp))
    aux("aaab", plus(chp))
    aux("bcd", plus(chp))
end

function main()
end

test2()
