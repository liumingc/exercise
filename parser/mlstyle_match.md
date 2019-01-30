I clone `MLStyle` by running pkg's `develop MLStyle`, then in `DataType.jl::impl`,
add one line to print the defs, now we get macro `data` internal information:
```
julia> @data internal Arith begin
       Number(Int)
       Minus(Arith, Arith)
       end
Inf Test, impl data: Any[(:Number, Tuple{Symbol,Symbol,Symbol}[(:_1, :Int, :Int)], quote
    struct Number{} <: Arith
        #= REPL[3]:2 =#
        _1::Int
    end
    begin
        function Number(; _1::Int)
            Number(_1)
        end
    end
    nothing
end), (:Minus, Tuple{Symbol,Symbol,Symbol}[(:_1, :Arith, :Arith), (:_2, :Arith, :Arith)], quote
    struct Minus{} <: Arith
        #= REPL[3]:3 =#
        _1::Arith
        _2::Arith
    end
    begin
        function Minus(; _1::Arith, _2::Arith)
            Minus(_1, _2)
        end
    end
    nothing
end)]
```
And run `@match` to see what happens when match:
```
julia> @macroexpand @match arith begin
       Number(i) => i
       Minus(e1, e2) => e1 - e2
       end
quote
    #= /Users/infliu/.julia/dev/MLStyle/src/MatchCore.jl:241 =#
    let Main 1 = arith
        #= /Users/infliu/.julia/dev/MLStyle/src/MatchCore.jl:242 =#
        begin
            #= REPL[4]:2 =#
            Main 2 = begin
                    function Main 9(Main 7::Number)
                        $(Expr(:meta, :inline))
                        Number
                        begin
                            Main 8 = (Main 1)._1
                            begin
                                (function (i,)
                                    $(Expr(:meta, :inline))
                                    i
                                end)(Main 8)
                            end
                        end
                    end
                    function Main 9(Main 7)
                        $(Expr(:meta, :inline))
                        MLStyle.MatchCore.Failed()
                    end
                    Main 9(Main 1)
                end
            if Main 2 === MLStyle.MatchCore.Failed()
                #= REPL[4]:3 =#
                Main 2 = begin
                        function Main 6(Main 3::Minus)
                            $(Expr(:meta, :inline))
                            Minus
                            begin
                                Main 4 = (Main 1)._1
                                begin
                                    (function (e1,)
                                        $(Expr(:meta, :inline))
                                        begin
                                            Main 5 = (Main 1)._2
                                            begin
                                                (function (e2,)
                                                    $(Expr(:meta, :inline))
                                                    e1 - e2
                                                end)(Main 5)
                                            end
                                        end
                                    end)(Main 4)
                                end
                            end
                        end
                        function Main 6(Main 3)
                            $(Expr(:meta, :inline))
                            MLStyle.MatchCore.Failed()
                        end
                        Main 6(Main 1)
                    end
                if Main 2 === MLStyle.MatchCore.Failed()
                    #= REPL[4]:3 =#
                    throw((InternalException)("Non-exhaustive pattern found!"))
                else
                    Main 2
                end
            else
                Main 2
            end
        end
    end
end
```
So, basically, it use julia's multi dispatch to test the type.
To descturt fields/array/... is more difficult, will figure out later...
