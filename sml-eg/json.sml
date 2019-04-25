structure Json = struct

open String
open Char

exception JsError of string
datatype jst = JsNull
             | JsBool of bool
             | JsNum of int (* real *)
             | JsStr of string
             | JsArr of jst list
             | JsObj of (string * jst) list

fun toString x =
let
  fun lst2str lst =
    List.foldr (fn (x, acc) => toString(x) ^ ", " ^ acc) lst
in
  case x of
       JsNull => "JsNull"
      | JsBool x => "JsBool(" ^ Bool.toString x ^ ")"
      | JsNum n => "JsNum(" ^ Int.toString n ^ ")"
      | JsStr s => "JsStr(" ^ s ^ ")"
      | JsArr arr => "JsArr[" ^ lst2str "]" arr
      | JsObj arr => "JsObj{\n" ^
          (
            List.foldr (fn ((k,v), acc) => "\t" ^ k ^ " => " ^ toString v ^ ",\n" ^ acc) "}" arr
          )
end

fun parse [] = raise JsError "end" (* or just return JsNull? *)
  | parse (lst as x::rest) =
let
  fun parseNum (lst as x::rest) acc =
    if isDigit x
    then parseNum rest (acc * 10 + (ord(x) - ord(#"0")))
    else (JsNum acc, lst)
    | parseNum [] acc =
    (JsNum acc, [])

  fun acc2str acc = implode (List.rev acc)

  fun parseIdent [] acc =
    (acc2str acc, [])
    | parseIdent (lst as x::rest) acc =
    if isAlpha x then parseIdent rest (x::acc)
    else (acc2str acc, lst)


  fun parseStr [] acc =
    (JsStr (acc2str acc), [])
    | parseStr (lst as x::rest) acc=
      if x = #"\"" then
        (JsStr (acc2str acc), rest)
      else parseStr rest (x::acc)

  fun parseArr [] acc = raise JsError "unexpected end"
    | parseArr (lst as (x::rest)) acc =
      if x = #"]" then
        (JsArr (List.rev acc), rest)
      else
        let
          (* Here we can't refer to parse? It seems that we can *)
          val (a, rest) = parse lst 
          fun middle [] = raise JsError "unexpected end"
            | middle (#","::rest) = rest
            | middle (lst as (#"]"::rest)) = lst
            | middle (x::rest) =
            if isSpace x then middle rest
            else (
              print (toString (JsArr acc) ^ "\n");
              raise JsError ("expecting ',', found " ^ str x ^ ", rest=" ^
                implode rest)
            )
          val rest' = middle rest
        in
          parseArr rest' (a::acc)
        end

  fun expectChar c (x::rest) =
    if c = x then rest
    else raise JsError ("expected char " ^ str c ^ ", met " ^ str x)
    | expectChar c _ = raise JsError "unexpected end in expectChar"

  fun skipSpaces [] = []
    | skipSpaces (lst as x::rest) =
      if isSpace x then skipSpaces rest
      else lst

  fun parseKeyVal [] = (NONE, [])
    | parseKeyVal lst =
      let
        val rst1 = skipSpaces lst
      in
        case rst1 of
             #"\""::rst2 =>
              let
                val (key, rst3) = parseStr rst2 []
                val rst4 = skipSpaces rst3
                val rst5 = expectChar #":" rst4
                val (a, rst6) = parse rst5
              in
                case key of
                     JsStr k => (SOME (k, a), rst6)
                    | _ => raise JsError "key not string!"
              end
            | _ => (NONE, rst1)
      end

  fun parseM [] acc = raise JsError "unexpected end"
    | parseM lst acc =
      let
        val (pairOpt, rst1) = parseKeyVal lst
      in
        case pairOpt of
             NONE =>
              let
                val rst2 = expectChar #"}" rst1
              in
                (acc, rst2)
              end
          |  SOME pair =>
              let
                val rst2 = skipSpaces rst1
              in
                case rst2 of
                     #"}"::rst3 =>
                      (pair::acc, rst3)
                  |  #","::rst3 =>
                      parseM rst3 (pair::acc)
                  |  _ => raise JsError ("error in middle of object" ^ ", rest="
                            ^ implode rst2)
              end
      end

  fun parseObj lst acc =
  let
    val (acc, rest) = parseM lst []
  in
    (JsObj (List.rev acc), rest)
  end

in
    if isSpace x then parse rest
    else if isDigit x
    then (
      (* parse number *)
      parseNum lst 0
    ) else if isAlpha x
    then (
      let
        val (a, rest) = parseIdent lst []
      in
        (
        case a of
             "true" => JsBool true
          | "false" => JsBool false
          | "null" => JsNull
          | _ => JsStr a (* maybe should raise an error *),
        rest)
      end
    ) else if x = #"\""
    then (
      (* parse string *)
      parseStr rest []
    ) else if x = #"["
    then (
      parseArr rest []
    ) else if x = #"{"
    then (
      parseObj rest []
    ) else raise JsError ("bad char " ^ str(x))
end

fun unmarshal str: jst =
let
  val (a, rest) = parse (explode str)
in
  a
end

end;

(* Tests *)
let 
  open Json
  val res1 = unmarshal "532"
  val res2 = unmarshal "\"hello, world\""
  val rtrue = unmarshal "true"
  val rfalse = unmarshal "false"
  val rnull = unmarshal "null"
  val rarr = unmarshal "[1, \"hello, world\", true, null, 5]"
  val obj1 = unmarshal "{ }"
  val obj2 = unmarshal "{\"age\": 23}"
  val obj3 = unmarshal "{\"age\": 23, \"name\": \"foo\"}"
  val obj4 = unmarshal "{\"foo\": [1, {\"fox\": null}, 3], \"bar\": \"world\", \"baz\": true}"
in
  case res1 of
       JsNum num =>
        print ("result=" ^ Int.toString num ^ ";\n")
      | _ => print "error\n";
  case res2 of
      JsStr s =>
        print ("result=" ^ s ^ ";\n")
      | _ => print "error\n";
    case rtrue of
      JsBool true => print "true;\n"
      | _ => print "error\n";
    case rfalse of
      JsBool false => print "false;\n"
      | _ => print "error\n";
    case rnull of
      JsNull => print "null;\n"
      | _ => print "error\n";
    print (Json.toString rarr ^ "\n");
    print ( "obj1=" ^ Json.toString obj1 ^ "\n");
    print ( "obj2=" ^ Json.toString obj2 ^ "\n");
    print ( "obj3=" ^ Json.toString obj3 ^ "\n");
    print ( "obj4=" ^ Json.toString obj4 ^ "\n")
end
