  // Method: System_SQL_FldScrp
  // ----------------------------------------------------
  // User name (OS): tgbpbp
  // Date and time: 7/19/2019, 04:16:25
  // ----------------------------------------------------
  // Description
  // bld277002
  //
  // ----------------------------------------------------
  // Declarations
  // - Input
C_POINTER($1)  //Field Pointer
  // - Output
C_TEXT($0)
  // - Variables
C_LONGINT($Len)
C_BOOLEAN($Index)
  // ----------------------------------------------------

$0:=""
GET FIELD PROPERTIES($1;$Type;$Len;$Index)
  //Oracle specific data types
Case of
        : (Position("zz";Field name($1))=1)
                $0:=""
        : ($Type=7)  //SubFile
                $0:=""
        Else
                If (False)  //true for SQL anywhere; False for ORACLE
                        Case of
                                : ($Type=0)  //Alpha
                                        $0:="CHAR("+String($Len)+")"
                                : ($Type=1)  //Real
                                        $0:="DOUBLE"
                                : ($Type=2)  //Text
                                        $0:="CHAR(32767)"
                                : ($Type=3)  //Picture
                                        $0:="LONG BINARY"
                                : ($Type=4)  //DATE; Dates for last modified or created are better as TIMESTAMPs
                                        $0:="TIMESTAMP"
                                : ($Type=11)  //Time
                                        $0:="TIME"
                                : ($Type=6)  //Boolean
                                        $0:="SMALLINT"
                                : ($Type=7)  //SubFile
                                        $0:="error"
                                : ($Type=8)  //Integer
                                        $0:="SMALLINT"
                                : ($Type=9)  //Longint
                                        $0:="INTEGER"

                                : ($Type=30)  //Blob
                                        $0:="CHAR(32767)"
                                : ($Type=38)  //Object
                                        $0:="CHAR(32767)"

                        End case
                Else   //False for Oracle
                        Case of
                                : ($Type=0)  //Alpha
                                        $0:="VARCHAR("+String($Len)+")"
                                : ($Type=1)  //Real
                                        $0:="REAL"
                                : ($Type=2)  //Text
                                        $0:="VARCHAR(8000)"
                                : (($Type=3) | ($Type=30))  //Picture or BLOB
                                        $0:="IMAGE"
                                : (($Type=4) | ($Type=11))  //Date or Time
                                        $0:="SMALLDATETIME"
                                : ($Type=6)  //Boolean
                                        $0:="BIT NOT NULL DEFAULT 0"
                                : ($Type=8)  //Integer
                                        $0:="SMALLINT"
                                : ($Type=9)  //Longint
                                        $0:="INT"  //"BIGINT"

                                : ($Type=30)  //Blob
                                        $0:="CHAR(32767)"
                                : ($Type=38)  //Object
                                        $0:="CHAR(32767)"
                        End case
                End if
                $0:="    "+$0

                If ($Index)
                        $Posn:=Find in array(PKOneField;$1)
                        If ($Posn#-1)  // Is This Field Used as a Primary Key
                                PrimKey:=Field name($1)
                                $0:=$0+" NOT NULL"  //PK_ThisFile
                        Else
                                If (FirstInd="")
                                        FirstInd:=Field name($1)
                                End if
                        End if
                End if

                $Posn:=Find in array(PKManyField;$1)
                If ($Posn#-1)  // Is This Field Used as a Foreign Key
                        If (Find in array(SQL_FNos;PkOneFile{$posn})#-1)
                                $0:=$0+" NOT NULL"
                                INSERT IN ARRAY(FornKeys;1)
                                INSERT IN ARRAY(FornKeyFile;1)
                                FornKeys{1}:=Field name($1)
                                FornKeyFile{1}:=Table name(PkOneFile{$posn})
                        Else
                                $0:=$0+" NULL"
                        End if
                Else   // CS Added to always default NULL
                        If (Position("NULL";$0)=0)  //01/03/12 13:04 Lee, Terry  Remove Unicode Correction
                                $0:=$0+" NULL"
                        End if
                End if

End case