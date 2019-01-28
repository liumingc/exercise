
abstract type Ast end

mutable struct IfAst <: Ast
    test::Ast
    ifso::Ast
    ifnot::Ast
end

mutable struct SeqAst <: Ast
    e0::Ast
    e1::Ast
end

mutable struct CallAst <: Ast
    fun::Ast
    args::Array{Ast}
end

mutable struct VarAst <: Ast
    name::String
end

function _eval(ex::IfAst)
    println("eval test")
    _eval(ex.test)
    println("eval ifso")
    _eval(ex.ifso)
    println("eval ifnot")
    _eval(ex.ifnot)
end

function _eval(ex::SeqAst)
    println("eval seq 0")
    _eval(ex.e0)
    println("eval seq 1")
    _eval(ex.e1)
end

function _eval(ex::CallAst)
    println("eval fun")
    _eval(ex.fun)
    println("eval args")
    for a in ex.args
        _eval(a)
    end
end

function _eval(ex::VarAst)
    println("eval var ", ex.name)
end

function main()
    _eval(SeqAst(
        CallAst(VarAst("println"), [VarAst("a"), VarAst("b")]),
        SeqAst(
            CallAst(VarAst("+"), [VarAst("c"), VarAst("d")]),
            IfAst(
                CallAst(VarAst("<"), [VarAst("e"), VarAst("f")]),
                CallAst(VarAst("print"), [VarAst("yes")]),
                CallAst(VarAst("raise"), [VarAst("no")])
            )
        )
    ))
end

main()
