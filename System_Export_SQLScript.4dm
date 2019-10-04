 // Method: System_Export_SQLScript
  // ----------------------------------------------------
  // User name (OS): Tom Benedict
  // Date and time: 7/19/2019, 04:13:52
  // ----------------------------------------------------
  // Description
  //  Generates a SQL Script which describes the 4D Structure. Can be used to generate a SQL Schema used by any SQL tool
  // bld277002
  //

C_LONGINT($i;$j)
C_TEXT(PrimKey;FirstInd;CRChar)

CRChar:=Char(Carriage return)

ARRAY INTEGER(PKOneFile;0)
ARRAY POINTER(PKOneField;0)
ARRAY INTEGER(PKManyFile;0)
ARRAY POINTER(PKManyField;0)
ARRAY TEXT(MCLNames;0)
ARRAY INTEGER(MCLSize;0)

ARRAY INTEGER(SQL_FNos;Get last table number)
ARRAY TEXT(SQL_FNames;Get last table number)

For ($i;1;Get last table number)
        If (Is table number valid($i))  // 10/6/10 TGB
                SQL_FNos{$i}:=$i
                SQL_FNames{$i}:=Table name($i)
        End if
End for
SORT ARRAY(SQL_FNames;SQL_FNos;>)  // CS Sort so it easier to find tables in DDL output file

  // **************************
  // if you want to select  the files to send implement this dialog
  // Open window(20;50;420;400;2)
  // DIALOG(•[CONFIGURE]•;"SQL_Files")  `****
  // CLOSE WINDOW
  // ***************************

  // If (OK=1)
  // find foreign keys
  // assumes many table's foreign key is one table's primary key

$Size:=Size of array(SQL_FNos)
For ($i;1;$Size)
        If (SQL_FNos{$i}>0)
                For ($j;1;Get last field number(SQL_FNos{$i}))
                                GET RELATION PROPERTIES(SQL_FNos{$i};$j;RelFile;RelField)
                        If (RelFile#0)
                                INSERT IN ARRAY(PKOneFile;1)
                                INSERT IN ARRAY(PKOneField;1)
                                INSERT IN ARRAY(PKManyFile;1)
                                INSERT IN ARRAY(PKManyField;1)
                                PKManyFile{1}:=SQL_FNos{$i}
                                PKManyField{1}:=Field(SQL_FNos{$i};$j)
                                PKOneFile{1}:=RelFile
                                PKOneField{1}:=Field(RelFile;RelField)
                        End if
                End for
        End if
End for

DocRef:=Create document("";"TEXT")

If (Ok=1)
        If (Size of array(MCLNames)#0)
                For ($i;1;Size of array(MCLNames))
                        ScratchStr:=MCLNames{$i}
                        If (Position(" ";ScratchStr)=1)
                                ScratchStr:=Replace string(ScratchStr;" ";"";1)  // just replace number 1 
                        End if

                        ScratchStr:="MCL_"+ScratchStr
                        ScratchStr:=System_SQL_NameOut (ScratchStr)

                        $TableDef:="CREATE TABLE "+System_SQL_NameOut (ScratchStr)+CRChar+"("+CRChar
                        $TableDef:=$TableDef+"VALUE     CHAR("+String(MCLSize{$i})+") PRIMARY KEY"
                        $TableDef:=$TableDef+CRChar+");"+CRChar
                        SEND PACKET(DocRef;$TableDef)
                End for
        End if

        For ($i;1;Size of array(SQL_FNos))
                $MyFile:=SQL_FNos{$i}
                If ($MyFile>0)
                        ARRAY TEXT(FornKeys;0)  // this table's field that refs
                        ARRAY TEXT(FornKeyFile;0)  // the other table's pk

                        PrimKey:=""
                        FirstInd:=""
                        $TableDef:="CREATE TABLE "+System_SQL_NameOut (Table name($MyFile))+CRChar+"("+CRChar
                        If (Get last field number($MyFile)>0)
                                $FldPtr:=Field($MyFile;1)
                                $FldScrpt:=System_SQL_FldScrp ($FldPtr)
                                $FieldName:=Field name($FldPtr)

                                $TableDef:=$TableDef+System_SQL_NameOut ($FieldName)+$FldScrpt
                                For ($j;2;Get last field number($MyFile))
                                        $FldPtr:=Field($MyFile;$j)
                                        $FldScrpt:=System_SQL_FldScrp ($FldPtr)
                                        If ($FldScrpt#"")  // don't send"zzFieldName"
                                                $FieldName:=Field name($FldPtr)
                                                $TableDef:=$TableDef+","+CRChar+System_SQL_NameOut ($FieldName)+$FldScrpt
                                        End if
                                End for
                        End if

                          //Table Constraints?00:00:00?
                        If (PrimKey#"")
                                $TableDef:=$TableDef+","+CRChar+"CONSTRAINT PK_"+PrimKey+" PRIMARY KEY "+"("+System_SQL_NameOut (PrimKey)+")"

                        Else
                                If (FirstInd#"")
                                          // Names any assumed primary keys as PK_FI_KeyName(for First Indexed field found)
                                        $TableDef:=$TableDef+","+CRChar+"CONSTRAINT PK_"+FirstInd+" PRIMARY KEY "+"("+System_SQL_NameOut (FirstInd)+")"
                                End if
                        End if

                        If (Size of array(FornKeys)#0)
                                For ($j;1;Size of array(FornKeys))
                                        $TableDef:=$TableDef+","+CRChar+"CONSTRAINT FK_"+System_SQL_NameOut (FornKeys{$j})+" FOREIGN KEY "+"("+System_SQL_NameOut (FornKeys{$j})+")"+" REFERENCES "+System_SQL_NameOut (FornKeyFile{$j})+"("+FornKeys{$j}+")"
                                End for
                        End if
                        $TableDef:=$TableDef+CRChar+");"+CRChar
                        SEND PACKET(DocRef;$TableDef)
                End if
        End for


        CLOSE DOCUMENT(docRef)
        ALERT("Done with SQL DDL Creation.")
End if
