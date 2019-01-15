(* graph edge, node etc *)
open Printf

type node = {
  mutable lowlink: int;
  mutable no: int;
  mutable succ: node list;
  value: string;
}

type graph = {
  mutable roots: node list;
}

exception Stop_iter

module NSet = Set.Make(struct
  type t = node
  let compare n1 n2 =
    Pervasives.compare n1.value n2.value
end)
module GSet = Set.Make(struct
  type t = NSet.t
  let compare = NSet.compare
end)

let _cnt = ref 0
let stk = Stack.create ()
let scc_coll = ref GSet.empty

let stk_mem n stk =
  let found = ref false in
  Stack.iter (fun x -> if x.value = n.value then found := true) stk;
  !found

let rec build_scc (r: node) =
  incr _cnt;
  r.no <- !_cnt;
  r.lowlink <- !_cnt;
  Stack.push r stk;
  printf "trav %s no=%d lowlink=%d\n" r.value r.no r.lowlink;
  List.iter (fun succ ->
    printf "%s.%d->%s.%d\n" r.value r.no succ.value succ.no;
    if succ.no = 0 then (
      build_scc succ;
      r.lowlink <- min r.lowlink succ.lowlink;
      printf "+%s no=%d lowlink=%d(succ=%s)\n" r.value r.no r.lowlink succ.value
    ) else (
      if succ.no < r.no && stk_mem succ stk then (
        r.lowlink <- min r.lowlink succ.no;
        printf "-%s no=%d lowlink=%d(succ=%s)\n" r.value r.no r.lowlink succ.value
      )
    )
  ) r.succ;
  if r.no = r.lowlink then (
    let scc = ref NSet.empty in
    try
      while not (Stack.is_empty stk) do
        let top = Stack.top stk in
        if top.lowlink < r.lowlink then
          raise Stop_iter;
        scc := NSet.add top !scc;
        ignore (Stack.pop stk)
      done;
      scc_coll := GSet.add !scc !scc_coll
    with
    | Stop_iter -> scc_coll := GSet.add !scc !scc_coll
  )

(** copy from graph.ml and modified
*)
module SSet = Set.Make(String)
let find_node r value =
  let visited = ref SSet.empty in
  let rec find_x curr =
    if SSet.mem curr.value !visited then None
    else begin
      visited := SSet.add curr.value !visited;
      if curr.value = value then Some curr
      else begin
        let rec handle_lst lst =
          match lst with
          | [] -> None
          | x::lst ->
            match find_x x with
            | None -> handle_lst lst
            | Some x as res -> res
        in
          handle_lst curr.succ
      end
    end
  in
    find_x r

let rec find_lst_opt pred lst =
  match lst with
  | [] -> None
  | x::lst ->
    let res = pred x in
    match res with
    | Some x -> res
    | None -> find_lst_opt pred lst

let node0 = {
  lowlink=0;
  no=0;
  succ=[];
  value=""
}

let add_edge g a b =
  let nodeb = {node0 with value=b} in (* this is a copy of b! *)
  let resb = find_lst_opt (fun y -> find_node y b) g.roots in
  let resa = find_lst_opt (fun x -> find_node x a) g.roots in
  match resa with
  | None ->
    (*printf "add edge %s -> %s, empty\n" a b;*)
    let nodea = {node0 with value=a; succ=[nodeb]} in
    g.roots <- nodea :: g.roots;
  | Some x ->
    (*printf "add edge %s -> %s, found x = %s\n" a b x.value;*)
    match resb with
    | None -> x.succ <- nodeb :: x.succ
    | Some rb -> x.succ <- rb :: x.succ
;;

let empty_graph () = {roots=([]: node list)}
let g = empty_graph ()
let (->>) a b =
  add_edge g a b

let start () =
  "a" ->> "b";
  "b" ->> "c";
  "c" ->> "d";
  "d" ->> "a";
  "b" ->> "e";
  "e" ->> "f";
  "f" ->> "g";
  "g" ->> "e";
  "c" ->> "b";
  "g" ->> "h";
  "h" ->> "i";
  List.iter (fun r -> printf "woo\n"; build_scc r) g.roots;
  (* print the result *)
  GSet.iter (fun scc ->
    printf "scc:\n\t";
    NSet.iter (fun r -> printf "%s.%d.%d" r.value r.no r.lowlink) scc;
    printf "\n"
  ) !scc_coll
;;

let _ =
  start ()