
struct State
    # run :: tokens -> expr, tokens
    run::Function
end

struct SyntaxError <: Exception end

# bind :: m a -> (a -> m b) -> m b
function bind(s::State, f::Function)
    State(tks1 -> begin
        ex, tks2 = s.run(tks1)
        # f(ex) :: State
        f(ex).run(tks2)
    end)
end

function seq(s1::State, s2::State)::State
    #=
    State(tks -> begin
        e1, tks1 = s1.run(tks)
        e2, tks2 = s2.run(tks1)
        return e2, tks2
    end)
    =#
    State(tks -> bind(s1, e1 -> State(tks1 -> begin
        e2, tks2 = s2.run(tks1)
        return [e1, e2], tks2
    end)))
end

function orelse(s1::State, s2::State)::State
    State(tks -> begin
        try
            e1, tks = s1.run(tks)
            return e1, tks
        catch e
            e2, tks = s2.run(tks)
            return e2, tks
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

function main()
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

main()
