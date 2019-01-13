open List
open Printf

type 'a node = {
  value: 'a;
  mutable succ: 'a node list;
}
type 'a graph = { mutable roots: 'a node list}

module SSet = Set.Make(String)

let empty_graph () = {roots=([]: string node list)}

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

let add_edge g a b =
  let nodeb = {value=b; succ=[]} in
  let res = find_lst_opt (fun x -> find_node x a) g.roots in
  match res with
  | None ->
    printf "add edge %s -> %s, empty\n" a b;
    let nodea = {value=a; succ=[nodeb]} in
    g.roots <- nodea :: g.roots;
  | Some x ->
    printf "add edge %s -> %s, found x = %s\n" a b x.value;
    x.succ <- nodeb :: x.succ

let g = empty_graph ()
let (->>) a b =
  add_edge g a b

let print_graph g =
  iter (fun r ->
    printf "root: %s\n" r.value;
    let visited = ref SSet.empty in
    let rec print_node n =
      printf "%s ->" n.value;
      if SSet.mem n.value !visited then ()
      else begin
        visited := SSet.add n.value !visited;
        iter print_node n.succ;
        printf ".\n"
      end
    in
      print_node r
  ) g.roots

let test () =
  "a" ->> "b";
  "b" ->> "c";
  "c" ->> "d";
  "d" ->> "a";
  "b" ->> "e";
  "e" ->> "f";
  "f" ->> "g";
  "g" ->> "e";
  print_graph g

let _ =
  test ()