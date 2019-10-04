# 4D-structure-export
SQL code for exporting 4D structure

From Tom Benedict, posted to the 4D use list, 10/4/19, thread title "Printing structures"

Here’s the SQL Script Generator code. There are three methods: System_Export_SQL_Script, System_SQL_NameOut and System_SQL_FldScrp. You may have to tweak the destination data types in System_SQL_FldScrp. It was built for Transact-SQL, but there is an Oracle case which I haven’t used/tested. The result SQL Script includes constraints, which you may have to remove depending on your tool since the dependent tables are not always created prior to the parent table, causing errors.

I wish I could remember where I got the original code. It was many years ago.