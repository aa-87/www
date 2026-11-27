MIOWWWT ; Workbench tests, run in disposable YottaDB database
 NEW R,E,F
 SET F=0
 IF '$$EXEC^MIOWWW("sha256 abc",.R,.E) SET F=F+1
 IF R'="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" SET F=F+1
 IF '$$EXEC^MIOWWW("sha1 abc",.R,.E) SET F=F+1
 IF R'="a9993e364706816aba3e25717850c26c9cd0d89d" SET F=F+1
 IF '$$EXEC^MIOWWW("wsaccept dGhlIHNhbXBsZSBub25jZQ==",.R,.E) SET F=F+1
 IF R'="s3pPLMBiTxaQ9kYGzzhZRbK+xOo=" SET F=F+1
 IF '$$EXEC^MIOWWW("tree",.R,.E) SET F=F+1
 IF R'="alpha ($DATA=10) | beta ($DATA=1)" SET F=F+1
 IF '$$EXEC^MIOWWW("form",.R,.E) SET F=F+1
 IF R'="MUMPS | one | two" SET F=F+1
 IF $$EXEC^MIOWWW("XECUTE ""HALT""",.R,.E) SET F=F+1
 IF $$EXEC^MIOWWW("tree"_$C(10),.R,.E) SET F=F+1
 IF $$EXEC^MIOWWW($J("",257),.R,.E) SET F=F+1
 IF $$EXEC^MIOWWW("sha256 "_$C(27),.R,.E) SET F=F+1
 WRITE "Failures: ",F,!
 IF F ZHALT 1
 QUIT
