;SAVE"Term.Asm"
*--------------------------------
; Terminal v1.3        (07/30/87)
*--------------------------------
DoLine   BSR     FKplot
         BSR     SwapToS1
         TST     tMode(A4)
         SEQ     ANSImode(A5)
         TST     tBcks(A4)
         SNE     DLBSmode(A5)
         TST     tKpad(A4)
         SNE     KPADtype(A5)
         TST     tEcho(A4)
         SNE     ECHOmode(A5)
         TST     tLine(A4)
         SNE     LFNLmode(A5)
         TST     tWrap(A4)
         SNE     WRAPmode(A5)
         CLR.L   D0
         MOVE    xCdly(A4),D0
         MOVE.L  D0,vCdly(A5)
         MOVE    xLdly(A4),D0
         MOVE.L  D0,vLdly(A5)
         MOVE    xChar(A4),D0
         MOVE.B  D0,vChar(A5)
         BSR     SetCom
         CLR.L   EvThresh(A5)
         SF      Recving(A5)
         SF      Sending(A5)
         SF      Exit(A5)
.0       BSR     DoEvnt
         TST.B   Exit(A5)
         BNE     .40
         TST.B   Recving(A5)
         BNE.S   .11
         TST.B   Sending(A5)
         BNE.S   .21
.1       TST     SDvars+InCnt(A5)
         BEQ.S   .2
         BSR     SDget
         BSR     DDput
         BRA.S   .0
.2       BSR     DDidle
         BRA.S   .0
.10      BSR     DoEvnt
         TST.B   Exit(A5)
         BNE     .40
         TST.B   Sending(A5)
         BNE.S   .31
         TST.B   Recving(A5)
         BEQ.S   .1
.11      TST     SDvars+InCnt(A5)
         BEQ.S   .12
         BSR     SDget
         BSR     Capture
         BSR     DDput
         BRA.S   .10
.12      BSR     DDidle
         BRA     .10
.20      BSR     DoEvnt
         TST.B   Exit(A5)
         BNE.S   .40
         TST.B   Recving(A5)
         BNE.S   .31
         TST.B   Sending(A5)
         BEQ.S   .1
         BSR     SetFree
.21      TST     SDvars+InCnt(A5)
         BEQ.S   .23
         BSR     SDget
         CMP.B   Prompt(A5),D0
         BNE.S   .22
         CLR.B   Prompt(A5)
.22      BSR     DDput
         BRA.S   .20
.23      BSR     DDidle
         BRA.S   .20
.30      BSR     DoEvnt
         TST.B   Exit(A5)
         BNE.S   .40
         TST.B   Sending(A5)
         BEQ.S   .11
         TST.B   Recving(A5)
         BEQ.S   .21
         BSR     SetFree
.31      TST     SDvars+InCnt(A5)
         BEQ.S   .33
         BSR     SDget
         CMP.B   Prompt(A5),D0
         BNE.S   .32
         CLR.B   Prompt(A5)
.32      BSR     Capture
         BSR     DDput
         BRA.S   .30
.33      BSR     DDidle
         BRA.S   .30
.40      TST.B   Sending(A5)
         BEQ.S   .41
         BSR     SendAbrt
.41      TST.B   Recving(A5)
         BEQ.S   .42
         BSR     RecvAbrt
.42      BSR     SwapToS0
         RTS
*--------------------------------
DoEvnt   MOVE.L  Ticks,D0
         CMP.L   EvThresh(A5),D0
         BLO.S   .2
         ADDQ.L  #2,D0
         MOVE.L  D0,EvThresh(A5)
         BSR     FKswap
         LEA     EventRecord(A5),A0
         MOVE    #$0FFF,D0
         MOVE.L  JGetOSEvent(A5),A1
         JSR     (A1)
         TST.B   D0
         BNE.S   .2
         MOVE    EventRecord+evtNum(A5),D0
         CMP     #1,D0
         BNE.S   .0
         MOVE.L  EventRecord+evtMouse(A5),D0
         MOVE    EventRecord+evtMeta(A5),D1
         BSR     CKclick
         BRA.S   .2
.0       CMP     #3,D0
         BEQ.S   .1
         CMP     #5,D0
         BNE.S   .2
.1       MOVE.L  EventRecord+evtMessage(A5),D0
         MOVE    EventRecord+evtMeta(A5),D1
         BSR     DDget
.2       RTS
*--------------------------------
SetCom   MOVE    cBaud(A4),D1
         ADD     D1,D1
         MOVE    .10(PC,D1),D0
         SWAP    D0
         MOVE    cData(A4),D1
         ADD     D1,D1
         MOVE    .11(PC,D1),D0
         MOVE    cStop(A4),D1
         ADD     D1,D1
         OR      .12(PC,D1),D0
         MOVE    cPrty(A4),D1
         ADD     D1,D1
         OR      .13(PC,D1),D0
         BSR     SDset
         MOVE    cHshk(A4),D0
         BSR     SDhand
         RTS
.10      HEX     08F4.0411.017C.00FD.00BD.005E.002E.0016.000A.0004
.11      HEX     0000.0020.0010.0030
.12      HEX     0004.0008.000C
.13      HEX     0000.0003.0001
*--------------------------------
RstCom   MOVE    cBaud(A4),D1
         ADD     D1,D1
         MOVE    .10(PC,D1),D0
         SWAP    D0
         MOVE    cStop(A4),D1
         ADD     D1,D1
         MOVE    .12(PC,D1),D0
         OR      #$0030,D0
         BSR     SDset
         MOVE    #0,D0
         BSR     SDhand
         RTS
.10      HEX     08F4.0411.017C.00FD.00BD.005E.002E.0016.000A.0004
.12      HEX     0004.0008.000C
*--------------------------------
CKclick  TST.B   FKflag(A5)
         BEQ     CKtrack
         BRA     FKtrack
*--------------------------------
CKopen   LINK    A6,#-8
         MOVE.L  (A5),A0
         MOVE.L  (A0),A1
         PEA     portRect(A1)
         MOVE.L  #$00100010,-(SP)
         PEA     gray(A0)
         PEA     portRect(A1)
         PEA     black(A0)
         _FillRect
         _FillRoundRect
         MOVE    #monaco,-(SP)
         _TextFont
         MOVE    #9,-(SP)
         _TextSize
         MOVE.L  #$0106000B,-8+topLeft(A6)
         MOVE.L  #$014D0040,-8+botRight(A6)
         PEA     -8(A6)
         _EraseRect
         MOVE    #$0115,-8+bottom(A6)
         LEA     .10(PC),A2
         MOVEQ   #14,D3
         MOVEQ   #5-1,D4
.0       PEA     -8(A6)
         _FrameRect
         CLR     D1
         MOVE.B  (A2),D1
         MULU    #6,D1
         SUBQ    #1,D1
         MOVE    -8+right(A6),D0
         SUB     -8+left(A6),D0
         SUB     D1,D0
         ASR     #1,D0
         ADD     -8+left(A6),D0
         MOVE    D0,-(SP)
         MOVE    -8+top(A6),D0
         ADD     #11,D0
         MOVE    D0,-(SP)
         _MoveTo
         MOVE.L  A2,-(SP)
         _DrawString
         CLR     D0
         MOVE.B  (A2)+,D0
         ADD     D0,A2
         ADD     D3,-8+top(A6)
         ADD     D3,-8+bottom(A6)
         DBRA    D4,.0
         UNLK    A6
         BRA     DDopen
.10      STR     "Print"
         STR     "Send"
         STR     "Receive"
         STR     "Unlock"
         STR     "Off-Line"
         ADJST
*--------------------------------
CKtrack  LINK    A6,#-8
         MOVE.L  D0,Where(A5)
         MOVE.L  #$0107000C,-8+topLeft(A6)
         MOVE.L  #$014C003F,-8+botRight(A6)
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     -8(A6)
         _PtInRect
         TST.B   (SP)+
         BEQ.S   .1
         CLR     D4
         MOVE    #$0114,-8+bottom(A6)
         MOVEQ   #5-1,D3
.0       CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     -8(A6)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .3
         ADDQ    #1,D4
         ADD     #14,-8+top(A6)
         ADD     #14,-8+bottom(A6)
         DBRA    D3,.0
.1       BSR     DDclick
.2       UNLK    A6
         RTS
.3       SF      D3
.4       PEA     Where(A5)
         _GetMouse
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     -8(A6)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .5
         TST.B   D3
         BNE.S   .6
         BRA.S   .7
.5       TST.B   D3
         BNE.S   .7
.6       PEA     -8(A6)
         _InverRect
         NOT.B   D3
.7       CLR.B   -(SP)
         _WaitMouseUp
         TST.B   (SP)+
         BNE.S   .4
         TST.B   D3
         BEQ     .2
         PEA     -8(A6)
         _InverRect
         TST     D4              ;Print
         BNE.S   .8
         BSR     DoPrint
         BRA     .2
.8       SUBQ    #1,D4           ;Send
         BNE.S   .9
         BSR     SendAbrt
         BRA     .2
.9       SUBQ    #1,D4           ;Receive
         BNE.S   .10
         BSR     RecvAbrt
         BRA     .2
.10      SUBQ    #1,D4           ;Unlock
         BNE.S   .11
         BSR     SDunlock
         BRA     .2
.11      ST      Exit(A5)        ;Off-Line
         BRA     .2
*--------------------------------
FKopen   MOVE.L  (A5),A0
         MOVE.L  (A0),A1
         PEA     portRect(A1)
         PEA     gray(A0)
         _FillRect
         MOVE    #monaco,-(SP)
         _TextFont
         MOVE    #9,-(SP)
         _TextSize
         RTS
*--------------------------------
FKplot   LINK    A6,#-24
         MOVE.L  PrtPtr2(A5),-(SP)
         _SetPort
         PEA     FKbounds(PC)
         _EraseRect
         MOVE.L  #$01060008,-8+topLeft(A6)
         MOVE.L  #$010701F9,-8+botRight(A6)
         MOVEQ   #14,D3
         MOVEQ   #6-1,D4
.0       PEA     -8(A6)
         _PaintRect
         ADD     D3,-8+top(A6)
         ADD     D3,-8+bottom(A6)
         DBRA    D4,.0
         MOVE.L  #$01060008,-8+topLeft(A6)
         MOVE.L  #$014D0009,-8+botRight(A6)
         MOVEQ   #62,D3
         MOVEQ   #9-1,D4
.1       PEA     -8(A6)
         _PaintRect
         ADD     D3,-8+left(A6)
         ADD     D3,-8+right(A6)
         DBRA    D4,.1
         LEA     pKeys(A4),A2
         MOVE    #263,-8+top(A6)
         MOVE    #276,-8+bottom(A6)
         MOVEQ   #5-1,D4
.2       MOVE    #009,-8+left(A6)
         MOVE    #070,-8+right(A6)
         MOVEQ   #8-1,D3
.3       MOVE.L  A2,A0
         LEA     -24(A6),A1
         CLR     D0
         MOVE.B  (A0)+,D0
         CMP     #10,D0
         BLS.S   .4
         MOVEQ   #10,D0
.4       MOVE.B  D0,(A1)+
         BRA.S   .6
.5       MOVE.B  (A0)+,(A1)+
.6       DBRA    D0,.5
         CLR     D1
         MOVE.B  -24(A6),D1
         BEQ.S   .7
         MULU    #6,D1
         SUBQ    #1,D1
         MOVE    -8+right(A6),D0
         SUB     -8+left(A6),D0
         SUB     D1,D0
         ASR     #1,D0
         ADD     -8+left(A6),D0
         MOVE    D0,-(SP)
         MOVE    -8+top(A6),D0
         ADD     #10,D0
         MOVE    D0,-(SP)
         _MoveTo
         PEA     -24(A6)
         _DrawString
.7       ADD     #16,A2
         ADD     #62,-8+left(A6)
         ADD     #62,-8+right(A6)
         DBRA    D3,.3
         ADD     #14,-8+top(A6)
         ADD     #14,-8+bottom(A6)
         DBRA    D4,.2
         SF      FKflag(A5)
         UNLK    A6
         RTS
FKbounds DATA    /262,/008,/333,/505
*--------------------------------
FKtrack  LINK    A6,#-8
         MOVE.L  D0,Where(A5)
         CLR     D4
         MOVE.L  #$01070009,-8+topLeft(A6)
         MOVE.L  #$011401F8,-8+botRight(A6)
         MOVEQ   #5-1,D3
.0       CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     -8(A6)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .1
         ADDQ    #1,D4
         ADD     #14,-8+top(A6)
         ADD     #14,-8+bottom(A6)
         DBRA    D3,.0
         UNLK    A6
         RTS
.1       LSL     #3,D4
         MOVE    #$0046,-8+right(A6)
         MOVEQ   #8-1,D3
.2       CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     -8(A6)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .3
         ADDQ    #1,D4
         ADD     #62,-8+left(A6)
         ADD     #62,-8+right(A6)
         DBRA    D3,.2
         UNLK    A6
         RTS
.3       SF      D3
.4       PEA     Where(A5)
         _GetMouse
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     -8(A6)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .5
         TST.B   D3
         BNE.S   .6
         BRA.S   .7
.5       TST.B   D3
         BNE.S   .7
.6       PEA     -8(A6)
         _InverRect
         NOT.B   D3
.7       CLR.B   -(SP)
         _WaitMouseUp
         TST.B   (SP)+
         BNE.S   .4
         TST.B   D3
         BEQ.S   .8
         PEA     -8(A6)
         _InverRect
         LEA     pText(A4),A0
         LSL     #6,D4
         ADD     D4,A0
         BSR     DoSTR
.8       UNLK    A6
         RTS
*--------------------------------
FKswap   MOVE    HWCfgFlags,D0
         BTST    #hwCbADB,D0
         BNE.S   .10
         BTST    #2,KeyMap+7
         BNE.S   .1
         TST.B   FKflag(A5)
         BEQ.S   .0
         _HideCursor
         BSR     RestK1
         _ShowCursor
         SF      FKflag(A5)
.0       RTS
.1       TST.B   FKflag(A5)
         BNE.S   .2
         _HideCursor
         BSR     RestK2
         _ShowCursor
         ST      FKflag(A5)
.2       RTS
.10      BTST    #7,KeyMap+6
         BNE.S   .12
         TST.B   FKflag(A5)
         BEQ.S   .11
         _HideCursor
         BSR     RestK1
         _ShowCursor
         SF      FKflag(A5)
.11      RTS
.12      TST.B   FKflag(A5)
         BNE.S   .13
         _HideCursor
         BSR     RestK2
         _ShowCursor
         ST      FKflag(A5)
.13      RTS
*--------------------------------
SwapToS1 MOVE.L  portRect+topLeft(A3),ZoomRect+topLeft(A5)
         MOVE.L  portRect+botRight(A3),ZoomRect+botRight(A5)
         MOVEM   portBits+bounds+topLeft(A3),D0-D1
         SUB     D0,ZoomRect+top(A5)
         SUB     D1,ZoomRect+left(A5)
         SUB     D0,ZoomRect+bottom(A5)
         SUB     D1,ZoomRect+right(A5)
BackToS1 MOVE.L  PrtPtr0(A5),-(SP)
         _SetPort
         PEA     ZoomRect(A5)
         PEA     ScrnRect(PC)
         ST      -(SP)
         BSR     DoZoom
         _HideCursor
         BSR     SaveS0
         BSR     RestS1
         _ShowCursor
         RTS
ScrnRect DATA    /020,/000,/342,/512
*--------------------------------
SwapToS0 _HideCursor
         BSR     SaveS1
         BSR     RestS0
         _ShowCursor
         MOVE.L  PrtPtr0(A5),-(SP)
         _SetPort
         PEA     ZoomRect(A5)
         PEA     ScrnRect(PC)
         SF      -(SP)
         BSR     DoZoom
         RTS
*--------------------------------
DoZoom   LINK    A6,#-32
         MOVEM.L D2-D7/A2-A4,-(SP)
         MOVE.L  (A5),A0
         PEA     gray(A0)
         _PenPat
         MOVE    #notPatXor,-(SP)
         _PenMode
         TST.B   8(A6)
         BEQ.S   .0
         SUBQ    #4,A7
         MOVE.L  #$00050007,-(SP)
         _FixRatio
         MOVE.L  (SP),D6
         MOVE.L  #$271000B0,-(SP)
         _FixRatio
         MOVE.L  (SP)+,D7
         MOVE.L  14(A6),A0
         BRA.S   .1
.0       SUBQ    #4,A7
         MOVE.L  #$00070005,-(SP)
         _FixRatio
         MOVE.L  (SP)+,D6
         MOVEQ   #1,D7
         SWAP    D7
         MOVE.L  10(A6),A0
.1       LEA     -32(A6),A1
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         LEA     -32(A6),A0
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         PEA     -32(A6)
         _FrameRect
         MOVEQ   #12-1,D5
.2       LEA     -8(A6),A4
         MOVE.L  10(A6),A3
         MOVE.L  14(A6),A2
         BSR.S   .3
         BSR.S   .3
         BSR.S   .3
         BSR.S   .3
         PEA     -8(A6)
         _FrameRect
         PEA     -32(A6)
         _FrameRect
         LEA     -24(A6),A0
         LEA     -32(A6),A1
         MOVEQ   #24,D0
         _BlockMove
         SUBQ    #4,A7
         MOVE.L  D7,-(SP)
         MOVE.L  D6,-(SP)
         _FixMul
         MOVE.L  (SP)+,D7
         DBRA    D5,.2
         PEA     -32(A6)
         _FrameRect
         PEA     -24(A6)
         _FrameRect
         PEA     -16(A6)
         _FrameRect
         _PenNormal
         MOVEM.L (SP)+,D2-D7/A2-A4
         UNLK    A6
         MOVE.L  (SP)+,A0
         ADD     #10,A7
         JMP     (A0)
.3       SUBQ    #6,A7
         MOVE.L  D7,-(SP)
         CLR     -(SP)
         MOVE    (A3)+,-(SP)
         _FixMul
         SUBQ    #4,A7
         CLR.L   -(SP)
         ADDQ    #1,(SP)
         SUB.L   D7,(SP)
         CLR     -(SP)
         MOVE    (A2)+,-(SP)
         _FixMul
         MOVE.L  (SP)+,D0
         ADD.L   D0,(SP)
         _FixRound
         MOVE    (SP)+,(A4)+
         RTS
*--------------------------------
ScrInit  MOVE.L  #64*342,D0
         _NewPtr
         BNE     .0
         MOVE.L  A0,ScrPtr0(A5)
         MOVE.L  #64*342,D0
         _NewPtr
         BNE     .0
         MOVE.L  A0,ScrPtr1(A5)
         MOVE.L  #64*71,D0
         _NewPtr
         BNE     .0
         MOVE.L  A0,ScrPtr2(A5)
         MOVEQ   #portRec,D0
         _NewPtr
         BNE     .0
         MOVE.L  A0,PrtPtr0(A5)
         MOVE.L  A0,-(SP)
         _OpenPort
         MOVEQ   #portRec,D0
         _NewPtr
         BNE     .0
         MOVE.L  A0,PrtPtr1(A5)
         MOVE.L  A0,-(SP)
         _OpenPort
         MOVE.L  PrtPtr1(A5),A0
         MOVE.L  ScrPtr1(A5),portBits+baseAddr(A0)
         MOVE    #$0040,portBits+rowBytes(A0)
         MOVE.L  #$00000000,portBits+bounds+topLeft(A0)
         MOVE.L  #$01560200,portBits+bounds+botRight(A0)
         MOVE.L  portBits+bounds+topLeft(A0),portRect+topLeft(A0)
         MOVE.L  portBits+bounds+botRight(A0),portRect+botRight(A0)
         MOVE.L  visRgn(A0),-(SP)
         PEA     portRect(A0)
         _RectRgn
         BSR     CKopen
         MOVEQ   #portRec,D0
         _NewPtr
         BNE.S   .0
         MOVE.L  A0,PrtPtr2(A5)
         MOVE.L  A0,-(SP)
         _OpenPort
         MOVE.L  PrtPtr2(A5),A0
         MOVE.L  ScrPtr2(A5),portBits+baseAddr(A0)
         MOVE    #$0040,portBits+rowBytes(A0)
         MOVE.L  #$01060000,portBits+bounds+topLeft(A0)
         MOVE.L  #$014D0200,portBits+bounds+botRight(A0)
         MOVE.L  portBits+bounds+topLeft(A0),portRect+topLeft(A0)
         MOVE.L  portBits+bounds+botRight(A0),portRect+botRight(A0)
         MOVE.L  visRgn(A0),-(SP)
         PEA     portRect(A0)
         _RectRgn
         BSR     FKopen
         MOVE    #$0031,D0
         _GetTrapAddress
         MOVE.L  A0,JGetOSEvent(A5)
         RTS
.0       _ExitToShell
SaveS0   LEA     Screen,A0
         MOVE.L  ScrPtr0(A5),A1
         BSR     MoveScr
         RTS
RestS0   MOVE    CrsrSav(A5),CrsrPin+top
         MOVE.L  ScrPtr0(A5),A0
         LEA     Screen,A1
         BSR     MoveScr
         RTS
SaveS1   LEA     Screen,A0
         MOVE.L  ScrPtr1(A5),A1
         BSR     MoveScr
         RTS
RestS1   MOVE    CrsrPin+top,CrsrSav(A5)
         MOVE    #257,D0
         MOVE    D0,CrsrPin+top
         CMP     MTemp+v,D0
         BLE.S   .0
         ADDQ    #1,MTemp+v
.0       MOVE.B  CrsrCouple,CrsrNew
         MOVE.L  ScrPtr1(A5),A0
         LEA     Screen,A1
         BSR     MoveScr
.1       TST.B   CrsrNew
         BNE.S   .1
         RTS
RestK1   MOVE.L  ScrPtr1(A5),A0
         ADD     #64*262,A0
         LEA     Screen+64*262,A1
         MOVEQ   #71-1,D0
         BSR     MoveBlk
         RTS
RestK2   MOVE.L  ScrPtr2(A5),A0
         LEA     Screen+64*262,A1
         MOVEQ   #71-1,D0
         BSR     MoveBlk
         RTS
MoveScr  MOVE    #342-1,D0
MoveBlk  MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         MOVE.L  (A0)+,(A1)+
         DBRA    D0,MoveBlk
         RTS
*--------------------------------
DoPrint  BSR     WatchCur
         BSR     SwapToS0
         BSR     PrDrvrOpen
         TST     PrintErr
         BNE     .2
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrDocOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST     PrintErr
         BNE.S   .1
         MOVE    #20,A0
         _Delay
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST     PrintErr
         BNE.S   .0
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrLFSixth,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST     PrintErr
         BNE.S   .0
         MOVE.L  PrtPtr1(A5),A0
         MOVE    #iPrBitsCtl,-(SP)
         PEA     portBits(A0)
         PEA     .10(PC)
         MOVE.L  #lPaintBits,-(SP)
         BSR     PrCtlCall
.0       MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.1       MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrDocClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.2       BSR     PrDrvrClose
         BSR     Refresh
         BSR     BackToS1
         BSR     ArrowCur
         RTS
.10      DATA    /013,/016,/253,/496
*--------------------------------
RecvAbrt TST.B   Recving(A5)
         BNE     .10
         TST     xMode(A4)
         BNE     DnLoad
         BSR     SwapToS0
         MOVE    #104,-(SP)
         MOVE    #089,-(SP)
         PEA     .30(PC)
         PEA     .31(PC)
         CLR.L   -(SP)
         PEA     SFRw(A5)
         MOVE    #sfPutFile,-(SP)
         _Pack3
         BSR     WatchCur
         BSR     Refresh
         BSR     BackToS1
         TST.B   SFRw+rGood(A5)
         BEQ     .1
         LEA     PBw(A5),A0
         LEA     SFRw+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFRw+rVolume(A5),ioVRefNum(A0)
         MOVE.B  SFRw+rVersion(A5),ioVersNum(A0)
         _Create
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         CMP     #dupFNErr,D0
         BNE     .22
.0       CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .21
         MOVE.L  #$54455854,ioFlFndrInfo+fdType(A0)      ;"TEXT"
         MOVE.L  #$4D414341,ioFlFndrInfo+fdCreator(A0)   ;"MACA"
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .21
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .21
         CLR.L   ioMisc(A0)
         _SetEOF
         MOVE    ioResult(A0),D0
         BNE.S   .20
         LEA     SaveBuf(A5),A1
         MOVE.L  A1,SavePtr(A5)
         MOVE    #512,SaveCnt(A5)
         ST      Recving(A5)
.1       BSR     ArrowCur
         RTS
.10      SF      Recving(A5)
         BSR     WatchCur
         LEA     PBw(A5),A0
         LEA     SaveBuf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #512,D0
         SUB     SaveCnt(A5),D0
         MOVE.L  D0,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE.S   .20
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .20
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE.S   .22
         BSR     ArrowCur
         RTS
.20      MOVE    D0,-(SP)
         _Close
         MOVE    (SP)+,D0
.21      MOVE    D0,-(SP)
         _Delete
         MOVE    (SP)+,D0
.22      MOVE    D0,-(SP)
         BSR     SwapToS0
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
.30      STR     "Save document as:"
.31      STR     "?"
         ADJST
*--------------------------------
Capture  MOVE    D0,-(SP)
         AND     #$007F,D0
         MOVE.L  SavePtr(A5),A0
         MOVE.B  D0,(A0)+
         MOVE.L  A0,SavePtr(A5)
         SUBQ    #1,SaveCnt(A5)
         BNE.S   .0
         LEA     PBw(A5),A0
         LEA     SaveBuf(A5),A1
         MOVE.L  A1,SavePtr(A5)
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #512,D0
         MOVE    D0,SaveCnt(A5)
         MOVE.L  D0,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         MOVE    D0,-(SP)
         _Close
         _Delete
         SF      Recving(A5)
         BSR     SwapToS0
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
.0       MOVE    (SP)+,D0
         RTS
*--------------------------------
DnLoad   TST     xMbin(A4)
         BNE     DnlApp
         BSR     SwapToS0
         MOVE    #104,-(SP)
         MOVE    #089,-(SP)
         PEA     .10(PC)
         PEA     .11(PC)
         CLR.L   -(SP)
         PEA     SFRw(A5)
         MOVE    #sfPutFile,-(SP)
         _Pack3
         BSR     WatchCur
         TST.B   SFRw+rGood(A5)
         BEQ     .3
         BSR     Refresh
         LEA     SFRw(A5),A0
         BSR     BDopen
         BSR     Ropen
         LEA     PBw(A5),A0
         LEA     SFRw+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFRw+rVolume(A5),ioVRefNum(A0)
         MOVE.B  SFRw+rVersion(A5),ioVersNum(A0)
         _Delete
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         CMP     #fnfErr,D0
         BNE     .6
.0       _Create
         MOVE    ioResult(A0),D0
         BNE     .6
         CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .5
         MOVE.L  #$54455854,ioFlFndrInfo+fdType(A0)      ;"TEXT"
         MOVE.L  #$4D414341,ioFlFndrInfo+fdCreator(A0)   ;"MACA"
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE.S   .5
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .5
.1       BSR     Rread
         BNE.S   .2
         LEA     PBw(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #128,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE.S   .4
         BSR     BDdisp
         BRA.S   .1
.2       CMP     #1,D0
         BNE.S   .4
         LEA     PBw(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .4
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE.S   .6
         BSR     Rclose
         BSR     BDclose
.3       BSR     Refresh
         BSR     BackToS1
         BSR     ArrowCur
         RTS
.4       MOVE    D0,-(SP)
         LEA     PBw(A5),A0
         _Close
         MOVE    (SP)+,D0
.5       MOVE    D0,-(SP)
         LEA     PBw(A5),A0
         _Delete
         MOVE    (SP)+,D0
.6       MOVE    D0,-(SP)
         BSR     Rabort
         BSR     BDclose
         BSR     Refresh
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
.10      STR     "Save document as:"
.11      STR     "?"
         ADJST
*--------------------------------
DnlApp   BSR     SwapToS0
         MOVE    #104,-(SP)
         MOVE    #089,-(SP)
         PEA     .50(PC)
         PEA     .51(PC)
         CLR.L   -(SP)
         PEA     SFRw(A5)
         MOVE    #sfPutFile,-(SP)
         _Pack3
         BSR     WatchCur
         TST.B   SFRw+rGood(A5)
         BEQ     .20
         BSR     Refresh
         LEA     SFRw(A5),A0
         BSR     BDopen
         BSR     Ropen
         LEA     PBw(A5),A0
         LEA     SFRw+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFRw+rVolume(A5),ioVRefNum(A0)
         CLR.B   ioVersNum(A0)
         _Delete
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         CMP     #fnfErr,D0
         BNE     .42
.0       BSR     Rread
         BNE     .42
         TST.B   Buf+0(A5)
         BNE     .30
         TST.B   Buf+74(A5)
         BNE     .30
         CLR     D2
         LEA     Buf+0(A5),A0
         MOVEQ   #124-1,D3
.1       MOVE.B  (A0)+,D0
         LSL     #8,D0
         EOR     D0,D2
         MOVEQ   #8-1,D1
.2       ADD     D2,D2
         BCC.S   .3
         EOR     #$1021,D2
.3       DBRA    D1,.2
         DBRA    D3,.1
         CMP     Buf+124(A5),D2
         BNE.S   .4
         CMP.B   #129,Buf+123(A5)
         BHI     .30
         MOVE.B  Buf+101(A5),Buf+74(A5)
         MOVE    Buf+120(A5),Hdr2Len(A5)
         BRA.S   .5
.4       TST.B   Buf+82(A5)
         BNE     .30
         TST.B   Buf+122(A5)
         BNE     .30
         CMP.B   #63,Buf+1(A5)
         BHI     .30
         CLR     Hdr2Len(A5)
.5       LEA     Buf+1(A5),A0
         LEA     Str64(A5),A1
         BSR     CopyStr
         LEA     Buf+65(A5),A0
         LEA     Type(A5),A1
         MOVEQ   #34-1,D0
.6       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.6
         LEA     PBw(A5),A0
         LEA     Str64(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         _Create
         MOVE    ioResult(A0),D0
         BEQ.S   .7
         CMP     #dupFNErr,D0
         BNE     .42
         LEA     PBw(A5),A0
         LEA     SFRw+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         _Create
         MOVE    ioResult(A0),D0
         BNE     .42
.7       BSR     MaxBin2
         ADDQ    #1,MaxBlk(A5)
         BSR     BDname
         TST     Hdr2Len(A5)
         BEQ.S   .10
.8       BSR     Rread
         BNE     .41
         MOVE    #128,D1
         CMP     Hdr2Len(A5),D1
         BLS.S   .9
         MOVE    Hdr2Len(A5),D1
.9       SUB     D1,Hdr2Len(A5)
         BSR     BDdisp
         TST     Hdr2Len(A5)
         BNE.S   .8
.10      TST.L   DataLen(A5)
         BEQ.S   .13
         LEA     PBw(A5),A0
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.L  DataLen(A5),ioReqCount(A0)
         _Allocate
         MOVE    ioResult(A0),D0
         BNE     .40
.11      BSR     Rread
         BNE     .40
         MOVE.L  #128,D1
         CMP.L   DataLen(A5),D1
         BLS.S   .12
         MOVE.L  DataLen(A5),D1
.12      LEA     PBw(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  D1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE     .40
         MOVE.L  ioActCount(A0),D0
         SUB.L   D0,DataLen(A5)
         BSR     BDdisp
         TST.L   DataLen(A5)
         BNE.S   .11
         LEA     PBw(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE     .41
.13      TST.L   RsrcLen(A5)
         BEQ.S   .16
         LEA     PBw(A5),A0
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _OpenRF
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.L  RsrcLen(A5),ioReqCount(A0)
         _Allocate
         MOVE    ioResult(A0),D0
         BNE     .40
.14      BSR     Rread
         BNE     .40
         MOVE.L  #128,D1
         CMP.L   RsrcLen(A5),D1
         BLS.S   .15
         MOVE.L  RsrcLen(A5),D1
.15      LEA     PBw(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  D1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE     .40
         MOVE.L  ioActCount(A0),D0
         SUB.L   D0,RsrcLen(A5)
         BSR     BDdisp
         TST.L   RsrcLen(A5)
         BNE.S   .14
         LEA     PBw(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE     .41
.16      LEA     PBw(A5),A0
         MOVE.L  Type(A5),ioFlFndrInfo+fdType(A0)
         MOVE.L  Creator(A5),ioFlFndrInfo+fdCreator(A0)
         MOVE    Flags(A5),ioFlFndrInfo+fdFlags(A0)
         AND     #$F8FC,ioFlFndrInfo+fdFlags(A0)
         CLR.L   ioFlFndrInfo+fdLocation(A0)
         CLR     ioFlFndrInfo+fdFldr(A0)
         MOVE.L  FlCrDat(A5),ioFlCrDat(A0)
         MOVE.L  FlMdDat(A5),ioFlMdDat(A0)
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.B  Locked(A5),D0
         AND.B   #$01,D0
         BEQ.S   .17
         LEA     PBw(A5),A0
         _SetFilLock
         MOVE    ioResult(A0),D0
         BNE     .41
.17      LEA     PBw(A5),A0
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE     .42
.18      BSR     Rread
         BEQ.S   .18
         CMP     #1,D0
         BEQ.S   .19
         BSR     Rabort
         BSR     BDclose
         BRA.S   .20
.19      BSR     Rclose
         BSR     BDclose
.20      BSR     Refresh
         BSR     BackToS1
         BSR     ArrowCur
         RTS
.30      LEA     PBw(A5),A0
         _Create
         MOVE    ioResult(A0),D0
         BNE     .42
         CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .41
         MOVE.L  #$54455854,ioFlFndrInfo+fdType(A0)      ;"TEXT"
         MOVE.L  #$4D414341,ioFlFndrInfo+fdCreator(A0)   ;"MACA"
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE.S   .41
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .41
         BRA.S   .32
.31      BSR     Rread
         BNE.S   .33
.32      LEA     PBw(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #128,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE.S   .40
         BSR     BDdisp
         BRA.S   .31
.33      CMP     #1,D0
         BNE.S   .40
         LEA     PBw(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .41
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE.S   .42
         BSR     Rclose
         BSR     BDclose
         BSR     Refresh
         BSR     BackToS1
         BSR     ArrowCur
         RTS
.40      MOVE    D0,-(SP)
         LEA     PBw(A5),A0
         _Close
         MOVE    (SP)+,D0
.41      MOVE    D0,-(SP)
         LEA     PBw(A5),A0
         _Delete
         MOVE    (SP)+,D0
.42      MOVE    D0,-(SP)
         BSR     Rabort
         BSR     BDclose
         BSR     Refresh
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
.50      STR     "Save document as:"
.51      STR     "?"
         ADJST
*--------------------------------
SendAbrt TST.B   Sending(A5)
         BNE     .10
         TST     xMode(A4)
         BNE     UpLoad
         BSR     SwapToS0
         MOVE    #82,-(SP)
         MOVE    #81,-(SP)
         PEA     .31(PC)
         CLR.L   -(SP)
         MOVE    #1,-(SP)
         PEA     .30(PC)
         CLR.L   -(SP)
         PEA     SFRr(A5)
         MOVE    #sfGetFile,-(SP)
         _Pack3
         BSR     WatchCur
         BSR     Refresh
         BSR     BackToS1
         TST.B   SFRr+rGood(A5)
         BEQ.S   .1
         LEA     PBr(A5),A0
         LEA     SFRr+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFRr+rVolume(A5),ioVRefNum(A0)
         MOVE.B  SFRr+rVersion(A5),ioVersNum(A0)
         MOVE.B  #fsRdPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .21
         LEA     LoadBuf(A5),A1
         MOVE.L  A1,LoadPtr(A5)
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #512,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         CMP     #eofErr,D0
         BNE.S   .20
.0       MOVE.L  ioActCount(A0),D0
         BEQ.S   .10
         MOVE    D0,LoadCnt(A5)
         CLR.L   Pace(A5)
         CLR.B   Prompt(A5)
         ST      Sending(A5)
.1       BSR     ArrowCur
         RTS
.10      SF      Sending(A5)
         BSR     WatchCur
         LEA     PBr(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .20
         BSR     ArrowCur
         RTS
.20      MOVE    D0,-(SP)
         LEA     PBr(A5),A0
         _Close
         MOVE    (SP)+,D0
.21      MOVE    D0,-(SP)
         BSR     SwapToS0
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
.30      ASC     "TEXT"
.31      STR     ""
         ADJST
*--------------------------------
SetFree  MOVE.L  Ticks,D0
         CMP.L   Pace(A5),D0
         BLO.S   .3
         TST.B   Prompt(A5)
         BNE.S   .3
         MOVE.L  LoadPtr(A5),A0
         MOVE.B  (A0)+,D0
         MOVE.L  A0,LoadPtr(A5)
         CMP.B   #CR,D0
         BNE.S   .0
         MOVE.B  vChar(A5),Prompt(A5)
         MOVE.L  vLdly(A5),D1
         BRA.S   .1
.0       MOVE.L  vCdly(A5),D1
.1       ADD.L   Ticks,D1
         MOVE.L  D1,Pace(A5)
         BSR     SDput
         SUBQ    #1,LoadCnt(A5)
         BNE.S   .3
         LEA     PBr(A5),A0
         LEA     LoadBuf(A5),A1
         MOVE.L  A1,LoadPtr(A5)
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #512,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE    ioResult(A0),D0
         BEQ.S   .2
         CMP     #eofErr,D0
         BNE.S   .5
.2       MOVE.L  ioActCount(A0),D0
         BEQ.S   .4
         MOVE    D0,LoadCnt(A5)
.3       RTS
.4       SF      Sending(A5)
         BSR     WatchCur
         LEA     PBr(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .5
         BSR     ArrowCur
         RTS
.5       MOVE    D0,-(SP)
         LEA     PBr(A5),A0
         _Close
         SF      Sending(A5)
         BSR     SwapToS0
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
*--------------------------------
UpLoad   TST     xMBin(A4)
         BNE     UplApp
         BSR     SwapToS0
         MOVE    #82,-(SP)
         MOVE    #81,-(SP)
         PEA     .11(PC)
         CLR.L   -(SP)
         MOVE    #1,-(SP)
         PEA     .10(PC)
         CLR.L   -(SP)
         PEA     SFRr(A5)
         MOVE    #sfGetFile,-(SP)
         _Pack3
         BSR     WatchCur
         TST.B   SFRr+rGood(A5)
         BEQ     .5
         BSR     Refresh
         LEA     SFRr(A5),A0
         BSR     BDopen
         BSR     Sopen
         BNE     .7
         LEA     PBr(A5),A0
         LEA     SFRr+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFRr+rVolume(A5),ioVRefNum(A0)
         MOVE.B  SFRr+rVersion(A5),ioVersNum(A0)
         CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .7
         MOVE.L  ioFlLgLen(A0),DataLen(A5)
         CLR.L   RsrcLen(A5)
         BSR     MaxBin
         BSR     BDsize
         LEA     PBr(A5),A0
         MOVE.B  #fsRdPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .7
.0       LEA     PBr(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #128,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE    ioResult(A0),D0
         BEQ.S   .1
         CMP     #eofErr,D0
         BNE.S   .6
.1       MOVE.L  ioActCount(A0),D0
         BEQ.S   .4
         LEA     Buf(A5),A0
.2       CMP     #128,D0
         BHS.S   .3
         CLR.B   0(A0,D0)
         ADDQ    #1,D0
         BRA.S   .2
.3       BSR     Swrite
         BNE.S   .6
         BSR     BDdisp
         BRA.S   .0
.4       LEA     PBr(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .6
         BSR     Sclose
         BSR     BDclose
.5       BSR     Refresh
         BSR     BackToS1
         BSR     ArrowCur
         RTS
.6       MOVE    D0,-(SP)
         LEA     PBr(A5),A0
         _Close
         MOVE    (SP)+,D0
.7       MOVE    D0,-(SP)
         BSR     Sabort
         BSR     BDclose
         BSR     Refresh
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
.10      ASC     "TEXT"
.11      STR     ""
         ADJST
*--------------------------------
UplApp   BSR     SwapToS0
         MOVE    #82,-(SP)
         MOVE    #81,-(SP)
         PEA     .50(PC)
         CLR.L   -(SP)
         MOVE    #-1,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     SFRr(A5)
         MOVE    #sfGetFile,-(SP)
         _Pack3
         BSR     WatchCur
         TST.B   SFRr+rGood(A5)
         BEQ     .13
         BSR     Refresh
         LEA     SFRr(A5),A0
         BSR     BDopen
         BSR     Sopen
         BNE     .21
         LEA     PBr(A5),A0
         LEA     SFRr+rName(A5),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    SFRr+rVolume(A5),ioVRefNum(A0)
         CLR.B   ioVersNum(A0)
         CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .21
         MOVE.L  ioFlFndrInfo+fdType(A0),Type(A5)
         MOVE.L  ioFlFndrInfo+fdCreator(A0),Creator(A5)
         MOVE    ioFlFndrInfo+fdFlags(A0),Flags(A5)
         MOVE.L  ioFlFndrInfo+fdLocation(A0),Location(A5)
         MOVE    ioFlFndrInfo+fdFldr(A0),Folder(A5)
         MOVE    ioFlAttrib(A0),Locked(A5)
         AND     #$0100,Locked(A5)
         MOVE.L  ioFlLgLen(A0),DataLen(A5)
         MOVE.L  ioFlRLgLen(A0),RsrcLen(A5)
         MOVE.L  ioFlCrDat(A0),FlCrDat(A5)
         MOVE.L  ioFlMdDat(A0),FlMdDat(A5)
         LEA     Buf(A5),A0
         MOVEQ   #128/4-1,D0
.0       CLR.L   (A0)+
         DBRA    D0,.0
         LEA     SFRr+rName(A5),A0
         LEA     Buf+1(A5),A1
         BSR     CopyStr
         LEA     Type(A5),A0
         LEA     Buf+65(A5),A1
         MOVEQ   #34-1,D0
.1       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.1
         MOVE.B  Buf+74(A5),Buf+101(A5)
         CLR.B   Buf+74(A5)
         MOVE.B  #129,Buf+122(A5)
         MOVE.B  #129,Buf+123(A5)
         CLR     D2
         LEA     Buf+0(A5),A0
         MOVEQ   #124-1,D3
.2       MOVE.B  (A0)+,D0
         LSL     #8,D0
         EOR     D0,D2
         MOVEQ   #8-1,D1
.3       ADD     D2,D2
         BCC.S   .4
         EOR     #$1021,D2
.4       DBRA    D1,.3
         DBRA    D3,.2
         MOVE    D2,Buf+124(A5)
         BSR     Swrite
         BNE     .21
         BSR     MaxBin
         ADDQ    #1,MaxBlk(A5)
         BSR     BDsize
         TST.L   DataLen(A5)
         BEQ.S   .8
         LEA     PBr(A5),A0
         MOVE.B  #fsRdPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE     .21
.5       MOVE.L  #128,D1
         CMP.L   DataLen(A5),D1
         BLS.S   .7
         LEA     Buf(A5),A0
         MOVEQ   #128/4-1,D0
.6       CLR.L   (A0)+
         DBRA    D0,.6
         MOVE.L  DataLen(A5),D1
.7       LEA     PBr(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  D1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE    ioResult(A0),D0
         BNE     .20
         MOVE.L  ioActCount(A0),D0
         SUB.L   D0,DataLen(A5)
         BSR     Swrite
         BNE     .20
         BSR     BDdisp
         TST.L   DataLen(A5)
         BNE.S   .5
         LEA     PBr(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE     .21
.8       TST.L   RsrcLen(A5)
         BEQ.S   .12
         LEA     PBr(A5),A0
         MOVE.B  #fsRdPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _OpenRF
         MOVE    ioResult(A0),D0
         BNE.S   .21
.9       MOVE.L  #128,D1
         CMP.L   RsrcLen(A5),D1
         BLS.S   .11
         LEA     Buf(A5),A0
         MOVEQ   #128/4-1,D0
.10      CLR.L   (A0)+
         DBRA    D0,.10
         MOVE.L  RsrcLen(A5),D1
.11      LEA     PBr(A5),A0
         LEA     Buf(A5),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  D1,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE    ioResult(A0),D0
         BNE.S   .20
         MOVE.L  ioActCount(A0),D0
         SUB.L   D0,RsrcLen(A5)
         BSR     Swrite
         BNE.S   .20
         BSR     BDdisp
         TST.L   RsrcLen(A5)
         BNE.S   .9
         LEA     PBr(A5),A0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .21
.12      BSR     Sclose
         BSR     BDclose
.13      BSR     Refresh
         BSR     BackToS1
         BSR     ArrowCur
         RTS
.20      MOVE    D0,-(SP)
         LEA     PBr(A5),A0
         _Close
         MOVE    (SP)+,D0
.21      MOVE    D0,-(SP)
         BSR     Sabort
         BSR     BDclose
         BSR     Refresh
         MOVE    (SP)+,D0
         BSR     DosErr
         BSR     Refresh
         BSR     BackToS1
         RTS
.50      STR     ""
         ADJST
*--------------------------------
MaxBin2  CLR.L   D0
         MOVE    Hdr2Len(A5),D0
         MOVE.L  DataLen(A5),D1
         MOVE.L  RsrcLen(A5),D2
         ADD.L   #127,D0
         ADD.L   #127,D1
         ADD.L   #127,D2
         LSR.L   #7,D0
         LSR.L   #7,D1
         LSR.L   #7,D2
         ADD     D1,D0
         ADD     D2,D0
         MOVE    D0,MaxBlk(A5)
         RTS
MaxBin   MOVE.L  DataLen(A5),D0
         MOVE.L  RsrcLen(A5),D1
         ADD.L   #127,D0
         ADD.L   #127,D1
         LSR.L   #7,D0
         LSR.L   #7,D1
         ADD     D1,D0
         MOVE    D0,MaxBlk(A5)
         RTS
BDopen   PEA     rName(A0)
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     D.10(PC)
         PEA     D.11(PC)
         ST      -(SP)
         MOVE    #dBoxProc,-(SP)
         MOVE.L  MinusOne,-(SP)
         SF      -(SP)
         CLR.L   -(SP)
         _NewWindow
         MOVE.L  (SP),TheWindow(A5)
         _SetPort
         MOVE    #monaco,-(SP)
         _TextFont
         MOVE    #9,-(SP)
         _TextSize
         MOVE    #srcCopy,-(SP)
         _TextMode
         MOVE    #004+00*06,-(SP)
         MOVE    #011+00*11,-(SP)
         _MoveTo
         PEA     D.20(PC)
         _DrawString
         _DrawString
         MOVE    #004+00*06,-(SP)
         MOVE    #011+01*11,-(SP)
         _MoveTo
         PEA     D.21(PC)
         _DrawString
         PEA     D.22(PC)
         _DrawString
         PEA     D.23(PC)
         _DrawString
         PEA     D.30(PC)
         _FrameRect
         CLR     MaxBlk(A5)
         CLR     Block(A5)
         BRA.S   BDdisp
BDname   PEA     D.40(PC)
         _EraseRect
         MOVE    #004+00*06,-(SP)
         MOVE    #011+00*11,-(SP)
         _MoveTo
         PEA     D.20(PC)
         _DrawString
         PEA     Str64(A5)
         _DrawString
BDsize   MOVE    #004+00*06,-(SP)
         MOVE    #011+01*11,-(SP)
         _MoveTo
         PEA     D.21(PC)
         _DrawString
         MOVE.L  DataLen(A5),D0
         ADD.L   RsrcLen(A5),D0
         LEA     Str32(A5),A0
         MOVE    #numToString,-(SP)
         _Pack7
         MOVE.L  A0,-(SP)
         _DrawString
         PEA     D.23(PC)
         _DrawString
BDdisp   MOVE    #004+27*06,-(SP)
         MOVE    #011+01*11,-(SP)
         _MoveTo
         PEA     D.24(PC)
         _DrawString
         CLR.L   D0
         MOVE    Block(A5),D0
         LEA     Str32(A5),A0
         MOVE    #numToString,-(SP)
         _Pack7
         MOVE.L  A0,-(SP)
         _DrawString
         TST     MaxBlk(A5)
         BEQ.S   .0
         LEA     TempRect(A5),A0
         MOVE.L  D.30+topLeft(PC),topLeft(A0)
         MOVE.L  D.30+botRight(PC),botRight(A0)
         MOVE    Block(A5),D0
         MULU    #226,D0
         DIVU    MaxBlk(A5),D0
         ADD     #005,D0
         MOVE    D0,right(A0)
         MOVE.L  A0,-(SP)
         _FrameRect
         PEA     TempRect(A5)
         MOVE.L  #$00010001,-(SP)
         _InsetRect
         PEA     TempRect(A5)
         MOVE.L  (A5),A0
         PEA     gray(A0)
         _FillRect
.0       RTS
BDclose  MOVE.L  TheWindow(A5),-(SP)
         _DisposWindow
         RTS
D.10     DATA    /152,/138,/189,/373
D.30     DATA    /026,/004,/033,/231
D.40     DATA    /002,/004,/013,/424
D.11     STR     ""
D.20     STR     "File: "
D.21     STR     "Size: "
D.22     STR     "?"
D.23     STR     " bytes"
D.24     STR     "Block: "
         ADJST
*--------------------------------
Ropen    BSR     RstCom
         TST     xTrbo(A4)
         SNE     F.Turbo(A5)
         TST     xCRC(A4)
         SNE     F.CRC(A5)
         ST      F.First(A5)
         SF      F.Abort(A5)
         CLR     Block(A5)
         RTS
Rread    ADDQ    #1,Block(A5)
.0       CLR     ErrCnt(A5)
         TST.B   F.First(A5)
         BNE.S   .1
         MOVEQ   #ACK,D0
         TST.B   F.Turbo(A5)
         BEQ.S   .2
         SF      F.Turbo(A5)
         BSR     Snd
         BSR     Snd
         BRA.S   .2
.1       BSR     WaitQ1
         MOVEQ   #NAK,D0
         TST.B   F.First(A5)
         BEQ.S   .2
         TST.B   F.CRC(A5)
         BEQ.S   .2
         MOVEQ   #'C',D0
.2       BSR     Snd
         MOVE    #160,Srch(A5)
.3       BSR     Recv10
         BEQ.S   .4
         CMP.B   #CAN,D0
         BEQ.S   .6
         CMP.B   #EOT,D0
         BEQ.S   .7
         CMP.B   #SOH,D0
         BEQ.S   .8
         SUBQ    #1,Srch(A5)
         BNE.S   .3
.4       TST.B   F.Abort(A5)
         BNE.S   .6
         TST.B   F.First(A5)
         BEQ.S   .5
         CMP     #2,ErrCnt(A5)
         BNE.S   .5
         SF      F.CRC(A5)
.5       ADDQ    #1,ErrCnt(A5)
         CMP     #10,ErrCnt(A5)
         BLO.S   .1
.6       MOVEQ   #2,D0
         RTS
.7       MOVEQ   #1,D0
         RTS
.8       SF      F.First(A5)
         BSR     Recv10
         BEQ.S   .4
         MOVE.B  D0,Blk(A5)
         BSR     Recv10
         BEQ.S   .4
         NOT.B   D0
         CMP.B   Blk(A5),D0
         BNE.S   .5
         CLR     CRC(A5)
         CLR     BPtr(A5)
.9       BSR     Recv10
         BEQ.S   .4
         LEA     Buf(A5),A0
         ADD     BPtr(A5),A0
         MOVE.B  D0,(A0)
         BSR.S   .20
         ADDQ    #1,BPtr(A5)
         CMP     #128,BPtr(A5)
         BLO.S   .9
         TST.B   F.CRC(A5)
         BEQ.S   .10
         BSR     Recv10
         BEQ.S   .4
         BSR.S   .20
         BSR     Recv10
         BEQ     .4
         BSR.S   .20
         TST     CRC(A5)
         BNE.S   .5
         BRA.S   .11
.10      BSR     Recv10
         BEQ     .4
         CMP.B   CRC+1(A5),D0
         BNE     .5
.11      MOVE.B  Block+1(A5),D0
         CMP.B   Blk(A5),D0
         BEQ.S   .12
         SUBQ.B  #1,D0
         CMP.B   Blk(A5),D0
         BEQ     .0
         BRA     .6
.12      MOVEQ   #0,D0
         RTS
.20      TST.B   F.CRC(A5)
         BEQ.S   .23
         EOR.B   D0,CRC(A5)
         MOVE    CRC(A5),D2
         MOVEQ   #8-1,D1
.21      ADD     D2,D2
         BCC.S   .22
         EOR     #$1021,D2
.22      DBRA    D1,.21
         MOVE    D2,CRC(A5)
         RTS
.23      ADD.B   D0,CRC+1(A5)
         RTS
Rabort   BSR     WaitQ3
         MOVEQ   #CAN,D0
         BSR     Snd
         BRA.S   Rclos
Rclose   BSR     WaitQ1
         MOVEQ   #ACK,D0
         BSR     Snd
Rclos    BSR     WaitQ1
         MOVE    #4,-(SP)
         _SysBeep
         BRA     SetCom
*--------------------------------
Sopen    BSR     RstCom
         ST      F.CRC(A5)
         SF      F.Abort(A5)
         CLR     Block(A5)
.0       TST     SDvars+InCnt(A5)
         BEQ.S   .1
         BSR     SDget
         BRA.S   .0
.1       CLR     ErrCnt(A5)
.2       BSR     Recv1
         BNE.S   .5
         TST.B   F.Abort(A5)
         BNE.S   .4
.3       ADDQ    #1,ErrCnt(A5)
         CMP     #120,ErrCnt(A5)
         BLO.S   .2
.4       MOVEQ   #2,D0
         RTS
.5       CMP.B   #CAN,D0
         BEQ.S   .4
         CMP.B   #'C,D0
         BEQ.S   .6
         CMP.B   #NAK,D0
         BNE.S   .3
         SF      F.CRC(A5)
.6       MOVEQ   #0,D0
         RTS
Swrite   ADDQ    #1,Block(A5)
         CLR     ErrCnt(A5)
.0       MOVEQ   #SOH,D0
         BSR     Snd
         MOVE.B  Block+1(A5),D0
         BSR     Snd
         NOT.B   D0
         BSR     Snd
         CLR     CRC(A5)
         CLR     BPtr(A5)
.1       LEA     Buf(A5),A0
         ADD     BPtr(A5),A0
         MOVE.B  (A0),D0
         BSR     Snd
         BSR.S   .20
         ADDQ    #1,BPtr(A5)
         CMP     #128,BPtr(A5)
         BLO.S   .1
         TST.B   F.CRC(A5)
         BEQ.S   .2
         MOVE.B  CRC(A5),D0
         BSR     Snd
.2       MOVE.B  CRC+1(A5),D0
         BSR     Snd
         MOVE    #192,Srch(A5)
.3       BSR     Recv10
         BEQ.S   .4
         CMP.B   #CAN,D0
         BEQ.S   .6
         CMP.B   #ACK,D0
         BEQ.S   .7
         CMP.B   #NAK,D0
         BEQ.S   .5
         SUBQ    #1,Srch(A5)
         BNE.S   .3
.4       TST.B   F.Abort(A5)
         BNE.S   .6
.5       ADDQ    #1,ErrCnt(A5)
         CMP     #10,ErrCnt(A5)
         BLO     .0
.6       MOVEQ   #2,D0
         RTS
.7       MOVEQ   #0,D0
         RTS
.20      TST.B   F.CRC(A5)
         BEQ.S   .23
         EOR.B   D0,CRC(A5)
         MOVE    CRC(A5),D2
         MOVEQ   #8-1,D1
.21      ADD     D2,D2
         BCC.S   .22
         EOR     #$1021,D2
.22      DBRA    D1,.21
         MOVE    D2,CRC(A5)
         RTS
.23      ADD.B   D0,CRC+1(A5)
         RTS
Sabort   BSR     WaitQ3
         MOVEQ   #CAN,D0
         BSR     Snd
         BRA.S   Sclos
Sclose   CLR     ErrCnt(A5)
.0       MOVEQ   #EOT,D0
         BSR     Snd
         MOVE    #192,Srch(A5)
.1       BSR     Recv10
         BEQ.S   .2
         CMP.B   #ACK,D0
         BEQ.S   Sclos
         SUBQ    #1,Srch(A5)
         BNE.S   .1
.2       TST.B   F.Abort(A5)
         BNE.S   Sclos
         ADDQ    #1,ErrCnt(A5)
         CMP     #10,ErrCnt(A5)
         BLO.S   .0
Sclos    MOVE    #4,-(SP)
         _SysBeep
         BRA     SetCom
*--------------------------------
WaitQ1   BSR     Recv1
         BNE.S   WaitQ1
         RTS
WaitQ3   BSR     Recv3
         BNE.S   WaitQ3
         RTS
Recv10   MOVE    #10*60,A0
         BRA.S   Recv
Recv3    MOVE    #03*60,A0
         BRA.S   Recv
Recv1    MOVE    #01*60,A0
Recv     ADD.L   Ticks,A0
         MOVE.L  A0,TimeOut(A5)
.0       TST     SDvars+InCnt(A5)
         BNE.S   .2
         BSR     Abort
         BNE.S   .1
         MOVE.L  Ticks,A0
         CMP.L   TimeOut(A5),A0
         BLO.S   .0
.1       MOVEQ   #0,D7
         RTS
.2       BSR     SDget
         MOVEQ   #1,D7
         RTS
Snd      CMP     #256,SDvars+OutCnt(A5)
         BHS.S   Snd
         BRA     SDput
Abort    LEA     EventRecord(A5),A0
         MOVE    #$0FFF,D0
         MOVE.L  JGetOSEvent(A5),A1
         JSR     (A1)
         TST.B   D0
         BNE.S   .0
         MOVE    EventRecord+evtNum(A5),D0
         CMP     #3,D0
         BNE.S   .0
         MOVE    EventRecord+evtMeta(A5),D0
         BTST    #8,D0
         BEQ.S   .0
         MOVE.L  EventRecord+evtMessage(A5),D0
         CMP.B   #'.,D0
         BNE.S   .0
         ST      F.Abort(A5)
         MOVEQ   #-1,D0
         RTS
.0       MOVEQ   #0,D0
         RTS
*--------------------------------
         END
