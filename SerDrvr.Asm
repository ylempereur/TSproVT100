;SAVE"SerDrvr.Asm"
*--------------------------------
; Serial Driver v1.1   (04/17/87)
*--------------------------------
PollRtnAddr      EQU  $128
PollStack        EQU  $13A
PollProc         EQU  $13E
PortAVars        EQU  $2D0
sccData          EQU  4
IntMask          EQU  $0300
;
useFree          EQU  0
useATalk         EQU  1
useAsync         EQU  2
useExtClk        EQU  3
;
portInUse        EQU  -97
portNotCf        EQU  -98
;
InBuf    EQU     0    ;(256)
OutBuf   EQU     256  ;(256)
InCnt    EQU     512  ;(2)
InRptr   EQU     514  ;(2)
InWptr   EQU     516  ;(2)
OutCnt   EQU     518  ;(2)
OutRptr  EQU     520  ;(2)
OutWptr  EQU     522  ;(2)
XonChr   EQU     524  ;(1)
XoffChr  EQU     525  ;(1)
Xonoff   EQU     526  ;(1)
Flow     EQU     527  ;(1) |SND|...|...| IU| IF| OF| IE| OE|
sdErr    EQU     528  ;(1) |...|FRA|OR |PAR|...|...|...|...|
sdSta    EQU     529  ;(1) |BRK|...|CTS|...|...|...|...|...|
StopBits EQU     530  ;(1)
WR1AVal  EQU     531  ;(1)
WR3AVal  EQU     532  ;(1)
WR5AVal  EQU     533  ;(1)
BaudLo   EQU     534  ;(1)
BaudHi   EQU     535  ;(1)
RcvrBits EQU     536  ;(1)
XmitBits EQU     537  ;(1)
WReqPin  EQU     538  ;(1)
;Unused  EQU     539  ;(1)
Tsave    EQU     540  ;(4)
Rsave    EQU     544  ;(4)
SCsave   EQU     548  ;(4)
EXTsave  EQU     552  ;(4)
*--------------------------------
SDopen   MOVE.B  SPConfig,D0
         LSR.B   #4,D0
         BEQ.S   .0
         SUBQ.B  #useAsync,D0
         BEQ.S   .0
         MOVEQ   #portNotCf,D0
         BRA.S   .3
.0       MOVE.B  PortAUse,D0
         BMI.S   .1
;        EOR.B   #useAsync,D0
;        BEQ.S   .1
         MOVEQ   #portInUse,D0
         BRA.S   .3
.1       MOVE.B  #useAsync,PortAUse
         LEA     SDvars(A5),A2
         MOVE.L  A2,PortAVars
         LEA     Tint(PC),A0
         MOVE.L  Lvl2DT+16,Tsave(A2)
         MOVE.L  A0,Lvl2DT+16
         LEA     Rint(PC),A0
         MOVE.L  Lvl2DT+24,Rsave(A2)
         MOVE.L  A0,Lvl2DT+24
         LEA     SCint(PC),A0
         MOVE.L  Lvl2DT+28,SCsave(A2)
         MOVE.L  A0,Lvl2DT+28
         LEA     EXTint(PC),A0
         MOVE.L  ExtStsDT+8,EXTsave(A2)
         MOVE.L  A0,ExtStsDT+8
         LEA     PollGet(PC),A0
         MOVE.L  A0,PollProc
         LEA     InitVars(PC),A0
         LEA     InCnt(A2),A1
         MOVEQ   #28/4-1,D0
.2       MOVE.L  (A0)+,(A1)+
         DBRA    D0,.2
         MOVE.L  #$005E0034,D0   ;1200 Baud, 8 data, 1 stop, no parity
         BSR     SDset
         MOVEQ   #0,D0
.3       RTS
SDclose  MOVE.L  PortAVars,A2
         LEA     RstData(PC),A3
         MOVEQ   #RstLth,D1
         BSR     InitSCC
         CLR.L   PollProc
         MOVE.L  EXTsave(A2),ExtStsDT+8
         MOVE.L  SCsave(A2),Lvl2DT+28
         MOVE.L  Rsave(A2),Lvl2DT+24
         MOVE.L  Tsave(A2),Lvl2DT+16
         CLR.L   PortAVars
         ST      PortAUse
         RTS
SDset    MOVE.L  PortAVars,A2
         LEA     InitDefs(PC),A0
         LEA     StopBits(A2),A1
         MOVEQ   #9-1,D3
         AND     #$003F,D0
         OR      #$F700,D0
.0       MOVE.B  (A0)+,D2
         MOVE.L  D0,D1
         ROL.L   D2,D1
         AND.B   (A0)+,D1
         OR.B    (A0)+,D1
         MOVE.B  D1,(A1)+
         DBRA    D3,.0
         LEA     InitData(PC),A3
         MOVEQ   #InitLth,D1
InitSCC  MOVE    SR,-(SP)
         MOVEM.L A0-A2,-(SP)
         MOVEM.L SCCRd,A0-A1
         OR      #IntMask,SR
         MOVE.B  2(A0),D2
         LEA     StopBits(A2),A2
.0       MOVE    (A3)+,D0
         TST.B   D0
         BPL.S   .1
         MOVE.B  (A2)+,D0
         ROR     #8,D0
.1       MOVE.B  D0,2(A1)
         ROR     #8,D0
         MOVE.L  (SP),(SP)
         MOVE.B  D0,2(A1)
         SUBQ    #2,D1
         BGT.S   .0
         MOVE.B  2(A0),D2
         AND.B   #$A0,D2
         MOVEM.L (SP)+,A0-A2
         MOVE.B  D2,sdSta(A2)
         MOVE    (SP)+,SR
         RTS
SDget    MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         LEA     InBuf(A2),A3
         ADD     InRptr(A2),A3
         MOVE.B  (A3),D0
         ADDQ.B  #1,InRptr+1(A2)
         SUBQ    #1,InCnt(A2)
         CMP     #64,InCnt(A2)
         BNE.S   .0
         BTST    #4,Flow(A2)
         BNE.S   .0
         BSR     Sxon
.0       MOVE    (SP)+,SR
         RTS
SDput    MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         BTST    #1,Flow(A2)
         BEQ.S   .0
         AND.B   #$7F,D0
         CMP.B   XonChr(A2),D0
         BEQ.S   .4
         CMP.B   XoffChr(A2),D0
         BEQ.S   .5
.0       BTST    #7,Flow(A2)
         BNE.S   .1
         BTST    #2,Flow(A2)
         BEQ.S   .2
.1       LEA     OutBuf(A2),A3
         ADD     OutWptr(A2),A3
         MOVE.B  D0,(A3)
         ADDQ.B  #1,OutWptr+1(A2)
         ADDQ    #1,OutCnt(A2)
         BRA.S   .3
.2       MOVE.L  SCCWr,A1
         MOVE.B  D0,sccData+2(A1)
         BSET    #7,Flow(A2)
.3       MOVE    (SP)+,SR
         RTS
.4       BCLR    #4,Flow(A2)
         BEQ.S   .3
         BSR     Sxon
         BRA.S   .3
.5       BSET    #4,Flow(A2)
         BNE.S   .3
         BSR     Sxoff
         BRA.S   .3
SDbreak  BSR     SetBrk
         MOVE.L  Ticks,A0
         ADD     #14,A0
.0       CMP.L   Ticks,A0
         BHI.S   .0
         BSR     ClrBrk
         RTS
SDhand   MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         TST.B   D0
         BNE.S   .2
         BCLR    #0,Flow(A2)
         BEQ.S   .0
         BSR     Rxon
.0       BCLR    #1,Flow(A2)
         BEQ.S   .1
         BCLR    #4,Flow(A2)
         BSR     Sxon
.1       BRA.S   .3
.2       BSET    #0,Flow(A2)
         BSET    #1,Flow(A2)
         BNE.S   .3
         CMP     #192,InCnt(A2)
         BLO.S   .3
         BSR     Sxoff
.3       MOVE    (SP)+,SR
         RTS
SDunlock MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         BTST    #0,Flow(A2)
         BEQ.S   .0
         BSR     Rxon
.0       MOVE    (SP)+,SR
         RTS
SDns     MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         BTST    #1,Flow(A2)
         BEQ.S   .1
         BCHG    #4,Flow(A2)
         BEQ.S   .0
         BSR     Sxon
         BRA.S   .1
.0       BSR     Sxoff
.1       MOVE    (SP)+,SR
         RTS
SetBrk   MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         MOVE.L  SCCWr,A1
         MOVE.B  #5,2(A1)
         MOVE.B  Xmitbits(A2),D0
         BSET    #4,D0
         MOVE.B  D0,2(A1)
         MOVE    (SP)+,SR
         RTS
ClrBrk   MOVE.L  PortAVars,A2
         MOVE    SR,-(SP)
         OR      #IntMask,SR
         MOVE.L  SCCWr,A1
         MOVE.B  #5,2(A1)
         MOVE.B  Xmitbits(A2),D0
         BCLR    #4,D0
         MOVE.B  D0,2(A1)
         MOVE    (SP)+,SR
         RTS
Sxon     BCLR    #3,Flow(A2)
         BEQ.S   .2
         TST.B   Xonoff(A2)
         BNE.S   .1
         BSET    #7,Flow(A2)
         BNE.S   .0
         MOVE.L  SCCWr,A1
         MOVE.B  XonChr(A2),sccData+2(A1)
         RTS
.0       MOVE.B  XonChr(A2),Xonoff(A2)
         RTS
.1       CLR.B   Xonoff(A2)
.2       RTS
Sxoff    BSET    #3,Flow(A2)
         BNE.S   .2
         TST.B   Xonoff(A2)
         BNE.S   .1
         BSET    #7,Flow(A2)
         BNE.S   .0
         MOVE.L  SCCWr,A1
         MOVE.B  XoffChr(A2),sccData+2(A1)
         RTS
.0       MOVE.B  XoffChr(A2),Xonoff(A2)
         RTS
.1       CLR.B   Xonoff(A2)
.2       RTS
Rxon     BCLR    #2,Flow(A2)
         BEQ.S   .0
         TST     OutCnt(A2)
         BEQ.S   .0
         BSET    #7,Flow(A2)
         BNE.S   .0
         MOVE.L  SCCWr,A1
         LEA     OutBuf(A2),A3
         ADD     OutRptr(A2),A3
         MOVE.B  (A3),sccData+2(A1)
         ADDQ.B  #1,OutRptr+1(A2)
         SUBQ    #1,OutCnt(A2)
.0       RTS
Rxoff    BSET    #2,Flow(A2)
         RTS
PollGet  MOVE.L  (SP)+,PollRtnAddr
         MOVE.L  PollStack,A4
         MOVE.L  PortAVars,A2
.0       TST.B   (A5)
         BMI.S   .1
         MOVE.B  (A6),-(SP)
         BRA.S   .0
.1       CMP.L   A4,A7
         BEQ.S   .2
         SUBQ.L  #2,A4
         MOVE.B  (A4),D0
         BSR.S   PollPut
         BRA.S   .0
.2       MOVE.L  PollStack,A7
         MOVE.L  PollRtnAddr,-(SP)
         RTS
Rint     MOVE.L  PortAVars,A2
         MOVE.B  sccData(A0),D0
PollPut  BTST    #0,Flow(A2)
         BEQ.S   .0
         AND.B   #$7F,D0
         CMP.B   XonChr(A2),D0
         BEQ     Rxon
         CMP.B   XoffChr(A2),D0
         BEQ.S   Rxoff
.0       CMP     #256,InCnt(A2)
         BHS.S   .1
         LEA     InBuf(A2),A3
         ADD     InWptr(A2),A3
         MOVE.B  D0,(A3)
         ADDQ.B  #1,InWptr+1(A2)
         ADDQ    #1,InCnt(A2)
         CMP     #192,InCnt(A2)
         BNE.S   .1
         BTST    #1,Flow(A2)
         BEQ.S   .1
         BSR     Sxoff
.1       RTS
Tint     MOVE.L  PortAVars,A2
         MOVE.B  Xonoff(A2),D0
         BEQ.S   .0
         CLR.B   Xonoff(A2)
         BRA.S   .1
.0       BTST    #2,Flow(A2)
         BNE.S   .2
         TST     OutCnt(A2)
         BEQ.S   .2
         LEA     OutBuf(A2),A3
         ADD     OutRptr(A2),A3
         MOVE.B  (A3),D0
         ADDQ.B  #1,OutRptr+1(A2)
         SUBQ    #1,OutCnt(A2)
.1       MOVE.B  D0,sccData(A1)
         RTS
.2       MOVE.B  #$28,(A1)
         BCLR    #7,Flow(A2)
         RTS
SCint    MOVE.L  PortAVars,A2
         MOVE.B  #1,(A1)
         MOVE.L  (SP),(SP)
         MOVE.B  (A0),D1
         MOVEQ   #$70,D3
         AND.B   D3,D1
         OR.B    D1,sdErr(A2)
         MOVE.B  sccData(A0),D0
         MOVE.L  (SP),(SP)
         MOVE.B  #$30,(A1)
         RTS
EXTint   MOVE.L  PortAVars,A2
         AND.B   #$A0,D0
         MOVE.B  D0,sdSta(A2)
         TST.B   D1
         BPL.S   .0
         TST.B   D0
         BMI.S   .0
         MOVE.B  sccData(A0),D0
.0       RTS
InitVars HEX     0000.0000.0000.0000.0000.0000
         HEX     11.13.00.03.00.00.00.00.00.00.00.00.00.00.00.00
InitDefs DATA    #00,#$0F,#$40   ;(WR4)
         DATA    #24,#$64,#$00   ;(WR1)
         DATA    #02,#$C0,#$00   ;(WR3)
         DATA    #01,#$60,#$02   ;(WR5)
         DATA    #16,#$FF,#$00   ;(WR12)
         DATA    #08,#$FF,#$00   ;(WR13)
         DATA    #02,#$C0,#$01   ;(WR3)
         DATA    #01,#$60,#$8A   ;(WR5)
         DATA    #24,#$FF,#$00   ;(WR1)
         ADJST
InitData DATA    #$02,#9  ; status in low bits, MIE disabled
         DATA    #4,#$FF  ; x16 clk, stop bits, parity options
         DATA    #1,#$FF  ; WR1 reg, first write
         DATA    #3,#$FF  ; bits/chr option rcvr
         DATA    #5,#$FF  ; bits/chr option xmtr
         DATA    #$00,#2  ; zero interrupt vector
         DATA    #$00,#10 ; NRZ encoding
         DATA    #$50,#11 ; br gen clk to rcvr, xmtr
         DATA    #12,#$FF ; set baud rate low byte
         DATA    #13,#$FF ; set baud rate high byte
         DATA    #3,#$FF  ; enable rcvr
         DATA    #5,#$FF  ; enable xmtr
         DATA    #$01,#14 ; enb baud rate generator from RTxC pin
         DATA    #$A8,#15 ; Break, DCD, CTS external interrupt
         DATA    #$10,#0  ; reset ext/status twice
         DATA    #$10,#0
         DATA    #1,#$FF  ; w/req pin configuration
         DATA    #$0A,#9  ; enable interrupts, status in low bits
InitLth  EQU     *-InitData
RstData  DATA    #$02,#9  ; status in low bits, MIE disabled
         DATA    #4,#$FF  ; x16 clk, stop bits, parity options
         DATA    #1,#$FF  ; WR1 reg, first write
         DATA    #3,#$FF  ; bits/chr option rcvr - disabled receiver
         DATA    #5,#$FF  ; bits/chr option xmtr - disabled transmitter
         DATA    #$08,#15 ; only DCD (mouse) ext/sts interrupts
         DATA    #$01,#1  ; only external/status interrupts
         DATA    #$0A,#9  ; enable interrupts, status in low bits
RstLth   EQU     *-RstData
*--------------------------------
         END
