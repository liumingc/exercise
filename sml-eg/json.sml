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
            List.foldr (fn ((k,v), acc) => k ^ " => " ^ toString v ^ ",\n") "}" arr
          )
end

fun parse [] = raise JsError "end" (* or just return JsNull? *)
  | parse (lst as (x::rst)) =
let
  fun parseNum (lst as (x::rst)) acc =
    if isDigit x
    then parseNum rst (acc * 10 + (ord(x) - ord(#"0")))
    else (JsNum acc, lst)
    | parseNum [] acc =
    (JsNum acc, [])

  fun acc2str acc = implode (List.rev acc)

  fun parseIdent [] acc =
    (acc2str acc, [])
    | parseIdent (lst as (x::rst)) acc =
    if isAlpha x then parseIdent rst (x::acc)
    else (acc2str acc, lst)


  fun parseStr [] acc =
    (JsStr (acc2str acc), [])
    | parseStr (lst as (x::rst)) acc=
      if x = #"\"" then
        (JsStr (acc2str acc), rst)
      else parseStr rst (x::acc)

  fun parseArr [] acc = raise JsError "unexpected end"
    | parseArr (lst as (x::rst)) acc =
      if x = #"]" then
        (JsArr (List.rev acc), rst)
      else
        let
          (* Here we can't refer to parse? It seems that we can *)
          val (a, rst) = parse lst 
          fun middle [] = raise JsError "unexpected end"
            | middle (#","::rst) = rst
            | middle (lst as (#"]"::rst)) = lst
            | middle (x::rst) =
            if isSpace x then middle rst
            else (
              print (toString (JsArr acc) ^ "\n");
              raise JsError ("expecting ',', found " ^ str x ^ ", rst=" ^
                implode rst)
            )
          val rst' = middle rst
        in
          parseArr rst' (a::acc)
        end

  fun parseObj lst =
    (JsObj [], lst)

in
    if isSpace x then parse rst
    else if isDigit x
    then (
      (* parse number *)
      parseNum lst 0
    ) else if isAlpha x
    then (
      let
        val (a, rst) = parseIdent lst []
      in
        (
        case a of
             "true" => JsBool true
          | "false" => JsBool false
          | "null" => JsNull
          | _ => JsStr a (* maybe should raise an error *),
        rst)
      end
    ) else if x = #"\""
    then (
      (* parse string *)
      parseStr rst []
    ) else if x = #"["
    then (
      parseArr rst []
    ) else if x = #"{"
    then (
      (JsNull, [])
    ) else raise JsError ("bad char " ^ str(x))
end

fun unmarshal str: jst =
let
  val (a, rst) = parse (explode str)
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
    print (Json.toString rarr ^ "\n")
end