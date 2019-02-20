let
  open PolyML
  val dec = PrettyBlock (4, false, [],
    [
        PrettyString "hello",
        PrettyBreak (1, 8),
        PrettyString "world",
        PrettyBreak (1, 8),
        PrettyString "goodbye"
    ])
in
  prettyPrint (TextIO.print, 12) dec
end
