using Test

include("parsec.jl")
using .Parsec

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
        val, rst = res
        if val isa Succ
            return val.succ
        else
            return val
        end
    end
    res = aux("aaab", star(chp))
    @test res == ["a", "a", "a"]
    res = aux("bcd", star(chp))
    @test res == []
    res = aux("aaab", plus(chp))
    @test res == ["a", "a", "a"]
    aux("bcd", plus(chp))

    res = aux("zbcd", joint(char_parser('z'),
                            plus(char_range_parser(['a', 'c', 'z', 'b']))))
    @test res == ["z", "b", "c"]
end

test2()
