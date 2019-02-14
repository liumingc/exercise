
structure Fs = OS.FileSys (* not allowed inside exprs *)

fun testFileIo() =
    let
    val filnam = Fs.tmpName()
    val outStr = TextIO.getOutstream(TextIO.openOut filnam)
    val output = TextIO.StreamIO.output
    val closeOut = TextIO.StreamIO.closeOut
    in
    output(outStr, "hello, world\n");
    output(outStr, "goodbye!^_^\n");
    print("written to " ^ filnam ^ "\n");
    closeOut(outStr);

    (* read it back *)
    let
    val inStr = TextIO.getInstream(TextIO.openIn filnam)
    val (contents, str') = TextIO.StreamIO.inputAll(inStr)
    in
    TextIO.StreamIO.closeIn(inStr);
    print("read back:\n");
    print(contents);

    (* rm temp file *)
    Fs.remove(filnam);

    (* test if rm succ *)
    case Fs.access(filnam, [Fs.A_READ]) of
      true => print("rm failed")
    | false => print("rm " ^ filnam ^ " succeed\n")

    end

    end;

val () = testFileIo();

