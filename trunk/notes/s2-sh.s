Here is a disassembly of the /bin/sh binary from s2.
Any differences to the jun72 sh.s listing are noted here.
The two programs are nearly identical with just a few changes.
Several of these differences point to defects in the jun72 listing
but some changes appear to just be differences.

40014:  MOV SP,R5
40016:  MOV R5,44574     / save shellarg
40022:  CMPB @2(R5),#55  / look for '-
40030:  BNE 40042
40032:  TRAP 33          / sys intr; 0
40034:  0
40036:  TRAP 32          / sys quit
40040:  0
40042:  TRAP 30          / sys getuid
40044:  TST R0
40046:  BNE 40056
40050:  MOVB #43,41634   / store '#' into "at" (prompt)
40056:  CMP (R5),#1      / just one arg, input from tty
40062:  BLE 40142	/ branch to newline
40064:  CLR R0
40066:  TRAP 6		/ sys close, close 0
40070:  MOV 4(R5),40100 / open argv[1]
40076:  TRAP 5		/ sys open
40100:  ..
40102:  0
40104:  BCC 40136	/ XXX sh.s uses "bec" here, not "bcc"?!
40106:  JSR R5,40600	/ jsr error
40112:  <Input not found\n\0\0>
40134:  TRAP 1		/ sys exit
40136:  CLR 41634	/ clear "at" (the prompt)
newline:
40142:  TST 41634	/ test if there's a prompt
40146:  BEQ 40162	/ branch to newcom
40150:  MOV #1,R0
40154:  TRAP 4		/ sys write; at; 2.
40156:  ..
40160:  2
newcom:
40162:  MOV 44574,SP	/ move shellarg to sp
40166:  MOV #41671,R3	/ move $parbuf to r3
40172:  MOV #43654,R4	/ move $parp to r4
40176:  CLR 43646	/ clear infile
40202:  CLR 43650	/ clear outfile
40206:  CLR 43644	/ clear glflag
newarg:
40212:  JSR PC,41330	/ jsr blank
40216:  JSR R5,41254	/ jsr delim
40222:      BR 40336
40224:  MOV R3,-(SP)
40226:  CMP R0,#74	/ check for '<
40232:  BNE 40244
40234:  MOV (SP),43646	/ save arg pointer to infile
40240:  CLR (SP)
40242:  BR 40302
40244:  CMP R0,#76	/ check for '>
40250:  BNE 40262	/ bne newchar
40252:  MOV (SP),43650	/ save arg to outfile
40256:  CLR (SP)
40260:  BR 40302
newchar:
40262:  CMP #40,R0	/ check for space (' )
40266:  BEQ 40316
40270:  CMP #212,R0	/ check for '\n + 200 (\n preceded by \)
40274:  BEQ 40316
40276:  JSR PC,40666	/ jsr putc
40302:  JSR PC,41352	/ jsr getc
40306:  JSR R5,41254	/ jsr delim
40312:      BR 40316
40314:  BR 40262	/ br newchar
40316:  CLRB (R3)+
40320:  MOV (SP)+,(R4)+
40322:  BNE 40326
40324:  TST -(R4)
40326:  JSR R5,41254	/ jsr delim
40332:      BR 40336
40334:  BR 40212	/ br newarg
40336:  CLR (R4)
40340:  MOV R0,-(SP)
40342:  JSR PC,40400	/ jsr docom
40346:  CMPB (SP),#46	/ check for '&
40352:  BEQ 40162	/ beq newcom
40354:  TST R1
40356:  BEQ 40370
40360:  TRAP 7		/ sys wait
40362:  BCS 40370
40364:  CMP R0,R1
40366:  BNE 40360
40370:  CMP (SP),#12	/ check for '\n
40374:  BEQ 40142	/ beq newline
40376:  BR 40162
docom:
40400:  SUB #43654,R4	/ sub $parp, r4
40404:  BNE 40412
40406:  CLR R1
40410:  RTS PC
40412:  JSR R5,40642	/ jsr chcom
40416:  qchdir
40420:      BR 40516
40422:  CMP R4,#4
40426:  BEQ 40452
40430:  JSR R5,40600	/ jsr error
40434:  <Arg count\n\0\0>
40450:  BR 40512
40452:  MOV 43656,40462	/ move parp+2 to ...
40460:  TRAP 14		/ sys chdir
40462:  ...
40464:  BCC 40512	/ (XXX "bec" in sh.s)
40466:  JSR R5,40600	/ jsr error
40472:  <Bad directory\n\0\0>
40512:  CLR R1
40514:  RTS PC
40516:  JSR R5,40642	/ jsr chcom
40522:  qlogin
40524:      BR 40542
40526:  TRAP 13
40530:  BIC (SP),@43654(R1)
40534:  TRAP 13
40536:  BIC (SP),43654(R4)
40542:  TRAP 2
40544:  BR 40774
40546:  BCC 40574
40550:  JSR R5,40600
40554:  DIV (R4)+,R1
40556:  CMP R1,@63541(R1)
40562:  ADD -(R5),-(R1)
40564:  COM @-(SP)
40566:  HALT
40570:  JMP 40142
40574:  MOV R0,R1
40576:  RTS PC
error:
40600:  MOVB (R5)+,44572
40604:  BEQ 40622
40606:  MOV #1,R0
40612:  TRAP 4
40614:  BIC -(R5),@1(R2)
40620:  BR 40600
40622:  INC R5
40624:  BIC #1,R5
40630:  CLR R0
40632:  TRAP 23		/ sysseek
40634:  0
40636:  2
40640:  RTS R5		/ XXX not in jun72 sh.s!

chcom:
40642:  MOV (R5)+,R1
40644:  MOV #41671,R2
40650:  MOVB (R1)+,R0
40652:  CMPB (R2)+,R0
40654:  BNE 40664
40656:  TST R0
40660:  BNE 40650
40662:  TST (R5)+
40664:  RTS R5
40666:  CMP R0,#47
40672:  BEQ 40712
40674:  CMP R0,#42
40700:  BEQ 40712
40702:  BIC #177600,R0
40706:  MOVB R0,(R3)+
40710:  RTS PC
40712:  MOV R0,-(SP)
40714:  JSR PC,41352
40720:  CMP R0,#12
40724:  BNE 40754
40726:  JSR R5,40600		/ jsr error
40732:  <"' imbalance\n\0>
	/ XXX jun72's sh.s builds "40750: 000051" here!  why?
	/ is there a padding error in the as we are using?
	/ the rest of the assembly continues as here.
40750:  JMP 40142		/ jmp newline
40754:  CMP R0,(SP)
40756:  BEQ 40770
40760:  BIC #177600,R0
40764:  MOVB R0,(R3)+
40766:  BR 40714
40770:  TST (SP)+
40772:  RTS PC
40774:  MOV 43646,41020
41002:  BEQ 41050
41004:  TSTB @41020
41010:  BEQ 41026
41012:  CLR R0
41014:  TRAP 6
41016:  TRAP 5
41020:  BIC R0,R0
41022:  HALT
41024:  BCC 41050
41026:  JSR R5,40600
41032:  ADD @72560(R1),(R1)
41036:  CMP R1,64546(R4)
41042:  ADD (R5)+,@-(R4)
41044:  000012
41046:  TRAP 1
41050:  MOV 43650,R2
41054:  BEQ 41172
41056:  CMPB (R2),#76
41062:  BNE 41102
41064:  INC R2
41066:  MOV R2,41074
41072:  TRAP 5
41074:  BIC R0,R0
41076:  WAIT
41100:  BCC 41142
41102:  MOV R2,41110
41106:  TRAP 10
41110:  BIC R0,R0
41112:  000017
41114:  BCC 41142
41114:  BCC 41142
41116:  JSR R5,40600
41122:  ASH (PC),R5
41124:  MUL 72165(R4),R1
41130:  ADD @(R0)+,-(R0)
41132:  ADD 5145(R1),@-(R1)
41136:  HALT
41140:  TRAP 1
41142:  TRAP 6
41144:  MOV R2,41160
41150:  MOV #1,R0
41154:  TRAP 6			/ sysclose
41156:  TRAP 5			/ sysopen
41160:  ..
41162:  1
41164:  TRAP 23			/ sysseek
41166:  0
41170:  2
41172:  TST 43644
41176:  BNE 41236
41200:  TRAP 13			/ sysexec
41202:  41671 			/ parbuf
41204:  43654			/ parp
41206:  TRAP 13			/ sysexec
41210:  41664			/ binpb "/bin/"
41212:  43654			/ parp
	/ XXX jun72 srcs has
	/  sys stat; binpb; inbuf
	/  bes 2f
	/  mov $shell,parp-2
	/  mov $binpb, parp
	/  sys exec; shell; parp-2
	/ here..
        / XXX this is not in the jun72 srcs!
41214:  JSR R5,40600		/ error
41220:  <No command\n\0>
41234:  TRAP 1			/ sysexit
41236:  MOV #41652,43652
41244:  TRAP 13			/ sysexec
41246:  41652			/ </etc/glob\0>
41250:  43652			/ parp-2
41252:  BR 41214

delim:
41254:  CMP R0,#12		/ check '\n
41260:  BEQ 41326
41262:  CMP R0,#46		/ check '&
41266:  BEQ 41326
41270:  CMP R0,#73		/ check ';
41274:  BEQ 41326
41276:  CMP R0,#77		/ check '?
41302:  BEQ 41320
	/ XXX not in jun72
41304:  CMP R0,#52		/ check '*
41310:  BEQ 41320
	/ XXX end jun72
41312:  CMP R0,#133		/ check '[
41316:  BNE 41324
41320:  INC 43644
41324:  TST (R5)+
41326:  RTS R5
41330:  JSR PC,41352
41334:  CMP #40,R0
41340:  BEQ 41330
41342:  CMP R0,#212
41346:  BEQ 41330
41350:  RTS PC
41352:  TST 43642
41356:  BNE 41444
41360:  MOV 44566,R1
41364:  CMP R1,44570
41370:  BNE 41400
41372:  JSR PC,41536
41376:  BR 41352
41400:  MOVB (R1)+,R0
41402:  MOV R1,44566
41406:  BIS 44564,R0
41412:  CLR 44564
41416:  CMP R0,#134
41422:  BEQ 41434
41424:  CMP R0,#44
41430:  BEQ 41466
41432:  RTS PC
41434:  MOV #200,44564
41442:  BR 41352
41444:  MOVB @43642,R0
41450:  BEQ 41460
41452:  INC 43642
41456:  RTS PC
41460:  CLR 43642
41464:  BR 41352
41466:  JSR PC,41352
41472:  SUB #60,R0
41476:  CMP R0,#11
41502:  BLOS 41510
41504:  MOV #11,R0
41510:  MOV 44574,R1
41514:  INC R0
41516:  CMP R0,(R1)
41520:  BGE 41352
41522:  ASL R0
41524:  ADD R1,R0
41526:  MOV 2(R0),43642
41534:  BR 41352
41536:  MOV #44164,R0
41542:  MOV R0,44566
41546:  MOV R0,44570
41552:  DEC R0
41554:  MOV R0,41570
41560:  INC 41570
41564:  CLR R0
41566:  TRAP 3
41570:  HALT
41572:  WAIT
41574:  BCS 41630
41576:  TST R0
41600:  BEQ 41630
41602:  INC 44570
41606:  CMP 41570,#44564
41614:  BCC 41630
41616:  CMPB @41570,#12
41624:  BNE 41560
41626:  RTS PC
41630:  TRAP 1				/ sys exit
quest:
41632:  <?\n>
at:
41634:  <@ >
qchdir:
41636:  <chdir\0>
glogin:
41644:  <login\0>
	/ XXX jun72 has shell: </bin/sh\0> here.
glob:
41652:  </etc/glob\0>
binpb:
41664:  </bin/>
parbuf:	/ 41671: 002
41672:  HALT
41674:  HALT
41676:  HALT
41700:  HALT
41702:  HALT
41704:  HALT
41706:  HALT
41710:  HALT
41712:  HALT
41714:  HALT
41716:  HALT
41720:  HALT
41722:  HALT
41724:  HALT
41726:  HALT
41730:  HALT
41732:  HALT
41734:  HALT
41736:  HALT
41740:  HALT
41742:  HALT
41744:  HALT
41746:  HALT
41750:  HALT
41752:  HALT
41754:  HALT
41756:  HALT
41760:  HALT
41762:  HALT
41764:  HALT
41766:  HALT
41770:  HALT
41772:  HALT
41774:  HALT
41776:  HALT
42000:  HALT
42002:  HALT
42004:  HALT
42006:  HALT


