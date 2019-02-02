module Parsec

export Value, Succ, Fail, State
export bind, orelse, plus, star, char_parser, char_range_parser, joint, seq, seqs

struct State
    # run :: tokens -> expr, tokens
    run::Function
end

abstract type Value end

struct Fail <: Value
    msg::String
end

struct Succ <: Value
    succ
end

# bind :: (a -> m b) -> m a -> m b, or let's say
# bind :: (a -> State) -> State -> State
function bind(f::Function, s::State)::State
    State(tks -> begin
        ex, rst = s.run(tks)
        if ex isa Fail
            return ex, tks
        else
            return f(ex.succ).run(rst)
        end
    end)
end

function orelse(s1::State, s2::State)::State
    State(tks -> begin
        res = s1.run(tks)
        ex1, rst = res
        if ex1 isa Fail
            return s2.run(tks)
        else
            return res
        end
    end)
end

function seq(s1::State, s2::State)::State
    bind(s1) do e1
        s2
    end
end

function seqs(slst::Vector{})::State
    if length(slst) == 0
        State(tks -> (Succ(nothing), tks))
    elseif length(slst) == 1
        slst[1]
    else
        seq(slst[1], seqs(slst[2:end]))
    end
end

function jointRes(e1::Succ, e2::Succ)::Value
    es1 = e1.succ
    es2 = e2.succ
    if es1 isa Array && es2 isa Array
        return Succ(cat(es1, es2; dims=1))
    elseif es1 isa Array
        return Succ(cat(es1, [es2]; dims=1))
    elseif es2 isa Array
        return Succ(cat([es1], es2; dims=1))
    else
        return Succ([es1, es2])
    end
end

function joint(s1::State, s2::State)::State
    State(tks -> begin
        res = s1.run(tks)
        ex1, rst = res
        if ex1 isa Fail
            return ex1, tks
        else
            res2 = s2.run(rst)
            ex2, rst2 = res2
            if ex2 isa Fail
                return ex2, rst
            else
                return jointRes(ex1, ex2), rst2
            end
        end
    end)
end

function star_aux(s1::State, tks, acc::Array{})
    while true
        res = s1.run(tks)
        ex, rst = res
        # println("acc=", acc, ",tks=", tks, ",ex=", ex)
        # sleep(.5)
        if ex isa Fail
            break
        else
            push!(acc, ex.succ)
            tks = rst
        end
    end
    return Succ(acc), tks
end

function star(s1::State)::State
    State(tks -> star_aux(s1, tks, []))
end

function option(s1::State)::State
end

function plus(s1::State)::State
    joint(s1, star(s1))
end

function char_parser(ch)::State
    State(tks -> begin
        if isempty(tks)
            return Fail("empty"), tks
        elseif tks[1] == ch
            return Succ(string(ch)), tks[2:end]
        else
            return Fail("not match"), tks
        end
    end)
end

function char_range_parser(chs)::State
    parsers = map(char_parser, chs)
    px = parsers[1]
    for p in parsers[2:end]
        px = orelse(px, p)
    end
    return px
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

function myparse(text::AbstractString)
    #toks = split(text)
    toks = tokenize(text)
    println("=toks=")
    println(toks)
end


end
