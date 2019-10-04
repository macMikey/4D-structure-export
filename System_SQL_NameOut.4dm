   // Method: System_SQL_NameOut
  // ----------------------------------------------------
  // User name (OS): Tom Benedict
  // Date and time: 7/19/2019, 04:15:07
  // ----------------------------------------------------
  // Description
  // currently just looks for a space and wraps quotes around the name if found.
  // this is a legal oracle name
  // if spaces are illegal then use $0:=Replace string($0;" ";"")
  // bld277002
  //
  // ----------------------------------------------------
  // Declarations
  // - Input
C_TEXT($1)
  // - Output
C_TEXT($0)

  // - Variables

  // ----------------------------------------------------

$0:=Replace string($1;Char(Double quote);"")  //clear any quote chars we already have   

If (Position(" ";$0)=1)
        $0:=Replace string($0;" ";"";1)  //clear a leading space 
End if

If ((Position(" ";$0)#0) | (Position(".";$0)#0))
        $0:=Char(Double quote)+$0+Char(Double quote)  //if any internal spaces then quote the string
End if