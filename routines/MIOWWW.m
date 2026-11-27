MIOWWW ; MUMPS.IO public workbench, isolated application entry point
 QUIT
 ;
START(PORT)
 NEW CONF
 SET PORT=+$GET(PORT,9080)
 IF PORT<1024!(PORT>65535) WRITE "Invalid port",! QUIT
 DO LOAD^MIOCONF($$GETCONF^MIOCONF(),.CONF)
 IF $GET(CONF("www","origin"))="" WRITE "Missing www.origin configuration",! QUIT
 SET CONF("server","listen","port")=PORT
 DO INIT(.CONF)
 DO START^MIOD(.CONF,PORT)
 QUIT
 ;
INIT(CONF)
 DO INIT^MIOROUTE
 DO START^MIOTPL(.CONF)
 DO REG(.CONF)
 DO COMPILE^MIOROUTE
 KILL ^MIO("CONF")
 MERGE ^MIO("CONF")=CONF
 QUIT
 ;
REG(CONF)
 NEW META
 SET META("authRequired")=0
 DO ADDM^MIOROUTE("GET","/","HOME^MIOWWW",.META)
 DO ADDM^MIOROUTE("POST","/lab/run","RUN^MIOWWW",.META)
 DO ADDM^MIOROUTE("GET","/public/www/*path","STATIC^MIOWWW",.META)
 DO ADDM^MIOROUTE("HEAD","/public/www/*path","STATIC^MIOWWW",.META)
 QUIT
 ;
HOME(DEV,CONF,REQ,CTX)
 NEW TCTX,OUT,ERR,HEAD
 SET TCTX("version")=$$VERSION^MIOTPL()
 DO RENDERPAGE^MIOTPL("pages/www_home.html","layouts/www_layout.html",.CONF,.TCTX,.OUT,.ERR)
 IF $DATA(ERR) DO ERROR(.DEV,.CONF,.CTX,500,"render_failed") QUIT
 SET HEAD("Content-Type")="text/html; charset=utf-8"
 DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
 QUIT
 ;
STATIC(DEV,CONF,REQ,CTX)
 NEW P
 SET P=$GET(REQ("path"))
 IF (P'="/public/www/site.css"),(P'="/public/www/site.js"),(P'="/public/www/xterm.js"),(P'="/public/www/xterm.css") DO ERROR(.DEV,.CONF,.CTX,404,"not_found") QUIT
 SET CONF("server","static","mount")="/public",CONF("server","static","root")="public"
 SET CONF("server","static","dirListing","enabled")=0
 SET REQ("params","path")=$EXTRACT(P,9,$LENGTH(P))
 DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
 QUIT
 ;
RUN(DEV,CONF,REQ,CTX)
 NEW BODY,OBJ,RESULT,STATUS,ERR
 IF $GET(CONF("www","origin"))="" DO ERROR(.DEV,.CONF,.CTX,403,"origin_denied") QUIT
 IF $GET(REQ("hdr","origin"))'=$GET(CONF("www","origin")) DO ERROR(.DEV,.CONF,.CTX,403,"origin_denied") QUIT
 IF $GET(REQ("hdr","content-type"))'="text/plain;charset=UTF-8" DO ERROR(.DEV,.CONF,.CTX,415,"unsupported_media_type") QUIT
 IF $GET(REQ("body","mode"))'="scalar" DO ERROR(.DEV,.CONF,.CTX,400,"invalid_body") QUIT
 SET BODY=$GET(REQ("body"))
 IF $ZLENGTH(BODY)>256 DO ERROR(.DEV,.CONF,.CTX,413,"input_too_large") QUIT
 IF '$$EXEC(BODY,.RESULT,.ERR) DO ERROR(.DEV,.CONF,.CTX,400,$GET(ERR("error"),"invalid_command")) QUIT
 SET OBJ("ok")=1,OBJ("output")=RESULT
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
 QUIT
 ;
EXEC(BODY,RESULT,ERR) ; Literal dispatch only. No XECUTE, indirection or shell.
 NEW CMD,ARG,I,B,TREE,K
 KILL ERR SET RESULT="",ERR("routine")="MIOWWW"
 IF $ZLENGTH($GET(BODY))>256 SET ERR("error")="input_too_large" QUIT 0
 FOR I=1:1:$ZLENGTH(BODY) SET B=$ZASCII(BODY,I) IF B<32!(B>126) SET ERR("error")="ascii_only"
 IF $DATA(ERR("error")) QUIT 0
 SET CMD=$PIECE(BODY," ",1),ARG=$PIECE(BODY," ",2,999)
 IF CMD="sha256" SET RESULT=$$SHA256^MIOSHA256(ARG) QUIT 1
 IF CMD="sha1" SET RESULT=$$SHA1HEX^MIOSHA1(ARG) QUIT 1
 IF CMD="trim" SET RESULT=$$TRIM^MIOUTIL(ARG) QUIT 1
 IF CMD="wsaccept" SET RESULT=$$WSACCEPT^MIOSHA1(ARG) QUIT 1
 IF BODY="tree" DO  QUIT 1
 . SET TREE("alpha",1)="first",TREE("alpha",2)="second",TREE("beta")="third"
 . SET K="" FOR  SET K=$ORDER(TREE(K)) QUIT:K=""  SET RESULT=RESULT_$SELECT(RESULT="":"",1:" | ")_K_" ($DATA="_$DATA(TREE(K))_")"
 IF BODY="form" DO  QUIT 1
 . NEW F DO DECODEFORM^MIOFNC("name=MUMPS&tag=one&tag=two",.F)
 . SET RESULT=F("name")_" | "_F("tag",1)_" | "_F("tag",2)
 IF BODY="version" SET RESULT="MIOTPL "_$$VERSION^MIOTPL() QUIT 1
 IF BODY="help" SET RESULT="sha256 TEXT | sha1 TEXT | trim TEXT | wsaccept KEY | tree | form | version | help" QUIT 1
 SET ERR("error")="unknown_command"
 QUIT 0
 ;
ERROR(DEV,CONF,CTX,STATUS,CODE)
 NEW OBJ
 SET OBJ("ok")=0,OBJ("error")=CODE
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,STATUS,.OBJ,$GET(CTX("request_id")),.CTX)
 QUIT
