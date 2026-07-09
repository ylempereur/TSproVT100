;SAVE"VT100.Asm"
*--------------------------------
; VT100 Driver  v1.3   (07/30/87)
*--------------------------------
MyScreen EQU     Screen+13*64+2
Ascent   EQU     8
Descent  EQU     2
Height   EQU     Ascent+Descent
*--------------------------------
DDopen   PEA     wBounds(PC)
         _EraseRect
         PEA     wBounds(PC)
         _FrameRect
         LEA     K0bits(PC),A0
         LEA     Key0(PC),A1
         MOVE.L  A1,(A0)
         MOVE.L  (A5),A0
         MOVE.L  (A0),A0
         PEA     K0bits(PC)
         PEA     portBits(A0)
         PEA     K0src(PC)
         PEA     K0dst(PC)
         MOVE    #srcCopy,-(SP)
         CLR.L   -(SP)
         _CopyBits
         LEA     K1bits(PC),A0
         LEA     Key1(PC),A1
         MOVE.L  A1,(A0)
         MOVE.L  (A5),A0
         MOVE.L  (A0),A0
         PEA     K1bits(PC)
         PEA     portBits(A0)
         PEA     K1src(PC)
         PEA     K1dst(PC)
         MOVE    #srcCopy,-(SP)
         CLR.L   -(SP)
         _CopyBits
         BSR     DoReset
         SF      CrsOn(A5)
         MOVE.L  Ticks,CrsTime(A5)
         RTS
DDclose  MOVE.L  (A5),A0
         PEA     ClosRect(PC)
         PEA     gray(A0)
         _FillRect
         RTS
*--------------------------------
wBounds  DATA    /009,/011,/256,/501
K0bits   DATA    0,/14
K0src    DATA    /000,/000,/071,/097
K0dst    DATA    /262,/404,/333,/501
K1bits   DATA    0,/8
K1src    DATA    /000,/000,/071,/057
K1dst    DATA    /262,/341,/333,/398
ClosRect DATA    /009,/011,/333,/501
*--------------------------------
DDidle   MOVE.L  Ticks,D0
         CMP.L   CrsTime(A5),D0
         BLO.S   .0
         ADD.L   CaretTime,D0
         MOVE.L  D0,CrsTime(A5)
         BSR     InvCrs
         NOT.B   CrsOn(A5)
.0       RTS
*--------------------------------
DDclick  CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     K0dst(PC)
         _PtInRect
         TST.B   (SP)+
         BNE.S   InKey0
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         PEA     K1dst(PC)
         _PtInRect
         TST.B   (SP)+
         BNE.S   InKey1
         RTS
InKey0   LEA     Key0Tbl(PC),A2
         MOVEQ   #18-1,D4
         BSR     TrakPt
         BEQ.S   .0
         LSL     #2,D4
         BSR     KPADclk
.0       RTS
InKey1   LEA     Key1Tbl(PC),A2
         MOVEQ   #8-1,D4
         BSR     TrakPt
         BEQ.S   .0
         CMP     #4,D4
         BLO.S   .1
         ADD     #14,D4
         LSL     #2,D4
         BSR     KPADclk
.0       RTS
.1       TST     D4
         BNE.S   .2
         MOVEQ   #$7F,D0
         BSR     DoCHR
         RTS
.2       SUBQ    #1,D4
         BNE.S   .3
         BSR     SDbreak         ;Break
         RTS
.3       SUBQ    #1,D4
         BNE.S   .4
         MOVEQ   #$0A,D0
         BSR     DoCHR
         RTS
.4       BSR     SDns            ;No Scroll
         RTS
TrakPt   CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         MOVE.L  A2,-(SP)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .0
         ADDQ.L  #8,A2
         DBRA    D4,TrakPt
         MOVEQ   #0,D3
         RTS
.0       SF      D3
.1       PEA     Where(A5)
         _GetMouse
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         MOVE.L  A2,-(SP)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .2
         TST.B   D3
         BNE.S   .3
         BRA.S   .4
.2       TST.B   D3
         BNE.S   .4
.3       MOVE.L  A2,-(SP)
         _InverRect
         NOT.B   D3
.4       CLR.B   -(SP)
         _WaitMouseUp
         TST.B   (SP)+
         BNE.S   .1
         TST.B   D3
         BEQ.S   .5
         MOVE.L  A2,-(SP)
         _InverRect
         MOVEQ   #-1,D3
.5       RTS
*--------------------------------
Key0Tbl  DATA    /263,/477,/276,/500     ;PF4
         DATA    /263,/453,/276,/476     ;PF3
         DATA    /263,/429,/276,/452     ;PF2
         DATA    /263,/405,/276,/428     ;PF1
         DATA    /305,/477,/332,/500     ;Enter
         DATA    /319,/453,/332,/476     ;.
         DATA    /291,/477,/304,/500     ;,
         DATA    /277,/477,/290,/500     ;-
         DATA    /277,/453,/290,/476     ;9
         DATA    /277,/429,/290,/452     ;8
         DATA    /277,/405,/290,/428     ;7
         DATA    /291,/453,/304,/476     ;6
         DATA    /291,/429,/304,/452     ;5
         DATA    /291,/405,/304,/428     ;4
         DATA    /305,/453,/318,/476     ;3
         DATA    /305,/429,/318,/452     ;2
         DATA    /305,/405,/318,/428     ;1
         DATA    /319,/405,/332,/452     ;0
Key1Tbl  DATA    /297,/370,/314,/397     ;Left
         DATA    /315,/370,/332,/397     ;Right
         DATA    /280,/370,/296,/397     ;Down
         DATA    /263,/370,/279,/397     ;Up
         DATA    /315,/342,/332,/369     ;No Scroll
         DATA    /297,/342,/314,/369     ;Line Feed
         DATA    /280,/342,/296,/369     ;Break
         DATA    /263,/342,/279,/369     ;Delete
*--------------------------------
DDget    MOVE    HWCfgFlags,D4
         BTST    #hwCbADB,D4
         BNE.S   .10
         LEA     OldKey(PC),A0
         ROR     #8,D0
         MOVEQ   #0,D4
.0       CMP.B   (A0)+,D0
         BLO.S   .1
         BEQ     DoKPAD
         ADDQ    #1,D4
         CMP     #18,D4
         BLO.S   .0
.1       BTST    #8,D1
         BNE.S   .3
         CMP.B   #$32,D0
         BNE.S   .2
         BTST    #9,D1
         BNE.S   .2
         MOVEQ   #$1B,D0
         BRA     DoCHR
.2       ROR     #8,D0
         CMP.B   #$08,D0
         BNE.S   .7
         TST.B   DLBSmode(A5)
         BEQ.S   DoCHR
         BRA.S   .6
.3       ROR     #8,D0
         CMP.B   #$7F,D0
         BHI.S   DoCHR
         CMP.B   #$60,D0
         BEQ.S   DoCHR
         BLO.S   .4
         AND.B   #$5F,D0
.4       CMP.B   #$40,D0
         BLO.S   .5
         AND.B   #$3F,D0
         BRA.S   DoCHR
.5       CMP.B   #$08,D0
         BNE.S   .7
         TST.B   DLBSmode(A5)
         BNE.S   DoCHR
.6       MOVEQ   #$7F,D0
         BRA.S   DoCHR
.7       CMP.B   #$03,D0
         BNE.S   DoCHR
         MOVEQ   #$0D,D0
         BRA.S   DoCHR
.10      LEA     NewKey(PC),A0
         ROR     #8,D0
         MOVEQ   #0,D4
.11      CMP.B   (A0)+,D0
         BLO.S   .12
         BEQ     DoNKPD
         ADDQ    #1,D4
         CMP     #22,D4
         BLO.S   .11
.12      ROR     #8,D0
         BTST    #12,D1
         BNE.S   DoCHR
         BTST    #8,D1
         BNE.S   .13
         CMP.B   #$08,D0
         BNE.S   DoCHR
         TST.B   DLBSmode(A5)
         BEQ.S   DoCHR
         BRA.S   .14
.13      CMP.B   #$08,D0
         BNE.S   DoCHR
         TST.B   DLBSmode(A5)
         BNE.S   DoCHR
.14      MOVEQ   #$7F,D0
DoCHR    CMP.B   #$0D,D0
         BNE.S   .1
         TST.B   LFNLmode(A5)
         BEQ.S   .1
         BSR     SDput
         TST.B   ECHOmode(A5)
         BEQ.S   .0
         BSR     DDput
.0       MOVEQ   #$0A,D0
.1       BSR     SDput
         TST.B   ECHOmode(A5)
         BEQ.S   .2
         BSR     DDput
.2       RTS
DoKPAD   TST.B   KPADtype(A5)
         BNE.S   .1
         BTST    #9,D1
         BNE.S   .0
         LEA     MapSN(PC),A0
         BRA.S   KPD0
.0       LEA     MapSS(PC),A0
         BRA.S   KPD0
.1       BTST    #9,D1
         BNE.S   .2
         LEA     MapPN(PC),A0
         BRA.S   KPD0
.2       LEA     MapPS(PC),A0
         BRA.S   KPD0
DoNKPD   TST.B   KPADtype(A5)
         BNE.S   .0
         LEA     MapSK(PC),A0
         BRA.S   KPD0
.0       LEA     MapEK(PC),A0
KPD0     MOVE.B  0(A0,D4),D4
KPADclk  TST.B   ANSImode(A5)
         BNE.S   .5
         TST.B   KPADmode(A5)
         BNE.S   .4
         LEA     VT52N(PC),A0
         BRA.S   .8
.4       LEA     VT52A(PC),A0
         BRA.S   .8
.5       TST.B   KPADmode(A5)
         BNE.S   .6
         LEA     VT100NN(PC),A0
         BRA.S   .8
.6       TST.B   CRSRmode(A5)
         BNE.S   .7
         LEA     VT100AN(PC),A0
         BRA.S   .8
.7       LEA     VT100AA(PC),A0
.8       ADD     D4,A0
DoSTR    CLR     D1
         MOVE.B  (A0)+,D1
         BRA.S   .1
.0       MOVE.B  (A0)+,D0
         MOVEM.L D1/A0,-(SP)
         BSR     DoCHR
         MOVEM.L (SP)+,D1/A0
.1       DBRA    D1,.0
         RTS
*--------------------------------
OldKey   HEX     41424647484C4D4E52535455565758595B5C
MapSN    HEX     304440382C34283C0004080C1014181C2024
MapSS    HEX     305054384C34483C0004080C1014181C2024
MapPN    HEX     305054384C3448280004080C1014181C2024
MapPS    HEX     30442C383C3440280004080C1014181C2024
NewKey   HEX     414345474B4C4E5152535455565758595B5C7B7C7D7E
MapSK    HEX     3044283840342C3C0004080C1014181C202454504C48
MapEK    HEX     30442C384034283C0004080C1014181C202454504C48
VT52N    HEX     01300000.01310000.01320000.01330000.01340000
         HEX     01350000.01360000.01370000.01380000.01390000
         HEX     012D0000.012C0000.012E0000.010D0000
         HEX     021B5000.021B5100.021B5200.021B5300
         HEX     021B4100.021B4200.021B4300.021B4400
VT52A    HEX     031B3F70.031B3F71.031B3F72.031B3F73.031B3F74
         HEX     031B3F75.031B3F76.031B3F77.031B3F78.031B3F79
         HEX     031B3F6D.031B3F6C.031B3F6E.031B3F4D
         HEX     021B5000.021B5100.021B5200.021B5300
         HEX     021B4100.021B4200.021B4300.021B4400
VT100NN  HEX     01300000.01310000.01320000.01330000.01340000
         HEX     01350000.01360000.01370000.01380000.01390000
         HEX     012D0000.012C0000.012E0000.010D0000
         HEX     031B4F50.031B4F51.031B4F52.031B4F53
         HEX     031B5B41.031B5B42.031B5B43.031B5B44
VT100AN  HEX     031B4F70.031B4F71.031B4F72.031B4F73.031B4F74
         HEX     031B4F75.031B4F76.031B4F77.031B4F78.031B4F79
         HEX     031B4F6D.031B4F6C.031B4F6E.031B4F4D
         HEX     031B4F50.031B4F51.031B4F52.031B4F53
         HEX     031B5B41.031B5B42.031B5B43.031B5B44
VT100AA  HEX     031B4F70.031B4F71.031B4F72.031B4F73.031B4F74
         HEX     031B4F75.031B4F76.031B4F77.031B4F78.031B4F79
         HEX     031B4F6D.031B4F6C.031B4F6E.031B4F4D
         HEX     031B4F50.031B4F51.031B4F52.031B4F53
         HEX     031B4F41.031B4F42.031B4F43.031B4F44
*--------------------------------
DDput    BSR     OffCrs
         AND     #$007F,D0
         CMP.B   #$20,D0
         BLO.S   .0
         CMP.B   #$7F,D0
         BEQ.S   DoNU
         MOVE    Dmode(A5),D1
         ADD     D1,D1
         MOVE    .10(PC,D1),D1
         JMP     .10(PC,D1)
.0       ADD     D0,D0
         MOVE    .20(PC,D0),D0
         JMP     .20(PC,D0)
*--------------------------------
.10      DATA    /OutPlt-.10     ;Text mode
         DATA    /ESC100-.10     ;ESC mode
         DATA    /CSI100-.10     ;CSI mode
         DATA    /SCSG0-.10      ;SCS G0 mode
         DATA    /SCSG1-.10      ;SCS G1 mode
         DATA    /HWL100-.10     ;HWL mode
         DATA    /ESC52-.10      ;ESC mode (VT52)
         DATA    /CAL52-.10      ;DCA Line (VT52)
         DATA    /CAC52-.10      ;DCA column (VT52)
*--------------------------------
.20      DATA    /DoNU-.20       NUL
         DATA    /DoNU-.20       SOH
         DATA    /DoNU-.20       STX
         DATA    /DoNU-.20       ETX
         DATA    /DoNU-.20       EOT
         DATA    /DoNU-.20       ENQ
         DATA    /DoNU-.20       ACK
         DATA    /DoBL-.20       BEL
         DATA    /DoBS-.20       BS
         DATA    /DoHT-.20       HT
         DATA    /DoLF-.20       LF
         DATA    /DoLF-.20       VT
         DATA    /DoFF-.20       FF
         DATA    /DoCR-.20       CR
         DATA    /DoSO-.20       SO
         DATA    /DoSI-.20       SI
         DATA    /DoNU-.20       DLE
         DATA    /DoNU-.20       DC1
         DATA    /DoNU-.20       DC2
         DATA    /DoNU-.20       DC3
         DATA    /DoNU-.20       DC4
         DATA    /DoNU-.20       NAK
         DATA    /DoNU-.20       SYN
         DATA    /DoNU-.20       ETB
         DATA    /DoCAN-.20      CAN
         DATA    /DoNU-.20       EM
         DATA    /DoCAN-.20      SUB
         DATA    /DoESC-.20      ESC
         DATA    /DoNU-.20       FS
         DATA    /DoNU-.20       GS
         DATA    /DoNU-.20       RS
         DATA    /DoNU-.20       US
*--------------------------------
DoBL     MOVE    #4,-(SP)
         _SysBeep
DoNU     RTS
*--------------------------------
DoBS     TST     ColCrs(A5)
         BEQ.S   .0
         SUBQ    #1,ColCrs(A5)
.0       RTS
*--------------------------------
DoHT     LEA     TabFlg(A5),A0
         MOVE    ColCrs(A5),D0
.0       CMP     #79,D0
         BEQ.S   .1
         ADDQ    #1,D0
         TST.B   0(A0,D0)
         BEQ.S   .0
.1       MOVE    D0,ColCrs(A5)
         RTS
*--------------------------------
DoLF     TST.B   LFNLmode(A5)
         BEQ     DoIND
         BRA     DoNEL
*--------------------------------
DoFF     BSR     DoED2
         BRA     DoHO
*--------------------------------
DoCR     CLR     ColCrs(A5)
         RTS
*--------------------------------
DoSO     LEA     G1ptr(A5),A0
         MOVE.L  A0,OFSTptr(A5)
         RTS
*--------------------------------
DoSI     LEA     G0ptr(A5),A0
         MOVE.L  A0,OFSTptr(A5)
         RTS
*--------------------------------
DoCAN    CLR     Dmode(A5)
         MOVEQ   #$7F,D0
         BRA     OutPlt
*--------------------------------
DoESC    TST.B   ANSImode(A5)
         BEQ.S   .0
         MOVE    #1,Dmode(A5)
         RTS
.0       MOVE    #6,Dmode(A5)
ESCrts   RTS
*--------------------------------
ESC52    CLR.L   Prm0(A5)
         CLR     Dmode(A5)
         SUB     #60,D0          ; "<"
         CMP     #30,D0          ; "Z"
         BHI.S   ESCrts
         ADD     D0,D0
         MOVE    .10(PC,D0),D0
         JMP     .10(PC,D0)
*--------------------------------
.10      DATA    /DoANSI-.10     ;<
         DATA    /DECKPAM-.10    ;=
         DATA    /DECKPNM-.10    ;>
         DATA    /DoRTS-.10      ;?
         DATA    /DoRTS-.10      ;@
         DATA    /DoCUU-.10      ;A
         DATA    /DoCUD-.10      ;B
         DATA    /DoCUF-.10      ;C
         DATA    /DoCUB-.10      ;D
         DATA    /DoRTS-.10      ;E
         DATA    /DoEGM-.10      ;F
         DATA    /DoXGM-.10      ;G
         DATA    /DoHO-.10       ;H
         DATA    /DoRI-.10       ;I
         DATA    /DoED-.10       ;J
         DATA    /DoEL-.10       ;K
         DATA    /DoRTS-.10      ;L
         DATA    /DoRTS-.10      ;M
         DATA    /DoRTS-.10      ;N
         DATA    /DoRTS-.10      ;O
         DATA    /DoRTS-.10      ;P
         DATA    /DoRTS-.10      ;Q
         DATA    /DoRTS-.10      ;R
         DATA    /DoRTS-.10      ;S
         DATA    /DoRTS-.10      ;T
         DATA    /DoRTS-.10      ;U
         DATA    /DoRTS-.10      ;V
         DATA    /DoRTS-.10      ;W
         DATA    /DoRTS-.10      ;X
         DATA    /DoDCA-.10      ;Y
         DATA    /DoZ52-.10      ;Z
*--------------------------------
ESC100   CMP.B   #'[,D0
         BNE.S   .0
         CLR     PrmPtr(A5)
         CLR.L   Prm0(A5)
         MOVE    #2,Dmode(A5)
         RTS
.0       CMP.B   #'(,D0
         BNE.S   .1
         MOVE    #3,Dmode(A5)
         RTS
.1       CMP.B   #'),D0
         BNE.S   .2
         MOVE    #4,Dmode(A5)
         RTS
.2       CMP.B   #'#,D0
         BNE.S   .3
         MOVE    #5,Dmode(A5)
         RTS
.3       CLR     Dmode(A5)
         CMP.B   #'7,D0
         BEQ     DECSC
         CMP.B   #'8,D0
         BEQ     DECRC
         CMP.B   #'=,D0
         BEQ     DECKPAM
         CMP.B   #'>,D0
         BEQ     DECKPNM
         CMP.B   #'D,D0
         BEQ     DoIND
         CMP.B   #'E,D0
         BEQ     DoNEL
         CMP.B   #'H,D0
         BEQ     DoHTS
         CMP.B   #'M,D0
         BEQ     DoRI
         CMP.B   #'Z,D0
         BEQ     DECID
         CMP.B   #'c,D0
         BEQ     DoRIS
         RTS
*--------------------------------
CSI100   SUB     #48,D0          ; "0"
         CMP     #9,D0           ; "9"
         BHI.S   .1
.0       LEA     Prm0(A5),A0
         ADD     PrmPtr(A5),A0
         MOVE    (A0),D1
         ADD     D1,D1
         MOVE    D1,D2
         LSL     #2,D1
         ADD     D2,D1
         ADD     D0,D1
         MOVE    D1,(A0)
         RTS
.1       SUB     #11,D0          ; ";"
         BNE.S   .3
         CMP     #30,PrmPtr(A5)
         BHS.S   .2
         ADDQ    #2,PrmPtr(A5)
         LEA     Prm0(A5),A0
         ADD     PrmPtr(A5),A0
         CLR     (A0)
.2       RTS
.3       SUBQ    #4,D0           ; "?"
         BNE.S   .4
         MOVEQ   #100,D0
         BRA.S   .0
.4       CLR     Dmode(A5)
         SUBQ    #2,D0           ; "A"
         CMP     #25,D0          ; "Z"
         BHI.S   .5
         ADD     D0,D0
         MOVE    .10(PC,D0),D0
         JMP     .10(PC,D0)
.5       SUB     #32,D0          ; "a"
         CMP     #25,D0          ; "z"
         BHI.S   .2
         ADD     D0,D0
         MOVE    .20(PC,D0),D0
         JMP     .20(PC,D0)
*--------------------------------
.10      DATA    /DoCUU-.10      ;A
         DATA    /DoCUD-.10      ;B
         DATA    /DoCUF-.10      ;C
         DATA    /DoCUB-.10      ;D
         DATA    /DoRTS-.10      ;E
         DATA    /DoRTS-.10      ;F
         DATA    /DoRTS-.10      ;G
         DATA    /DoCUP-.10      ;H
         DATA    /DoRTS-.10      ;I
         DATA    /DoED-.10       ;J
         DATA    /DoEL-.10       ;K
         DATA    /DoRTS-.10      ;L
         DATA    /DoRTS-.10      ;M
         DATA    /DoRTS-.10      ;N
         DATA    /DoRTS-.10      ;O
         DATA    /DoRTS-.10      ;P
         DATA    /DoRTS-.10      ;Q
         DATA    /DoRTS-.10      ;R
         DATA    /DoRTS-.10      ;S
         DATA    /DoRTS-.10      ;T
         DATA    /DoRTS-.10      ;U
         DATA    /DoRTS-.10      ;V
         DATA    /DoRTS-.10      ;W
         DATA    /DoRTS-.10      ;X
         DATA    /DoRTS-.10      ;Y
         DATA    /DoRTS-.10      ;Z
*--------------------------------
.20      DATA    /DoRTS-.20      ;a
         DATA    /DoRTS-.20      ;b
         DATA    /DoDA-.20       ;c
         DATA    /DoRTS-.20      ;d
         DATA    /DoRTS-.20      ;e
         DATA    /DoCUP-.20      ;f
         DATA    /DoTBC-.20      ;g
         DATA    /DoSM-.20       ;h
         DATA    /DoRTS-.20      ;i
         DATA    /DoRTS-.20      ;j
         DATA    /DoRTS-.20      ;k
         DATA    /DoRM-.20       ;l
         DATA    /DoSGR-.20      ;m
         DATA    /DoDSR-.20      ;n
         DATA    /DoRTS-.20      ;o
         DATA    /DoRTS-.20      ;p
         DATA    /DoRTS-.20      ;q
         DATA    /DECSTBM-.20    ;r
         DATA    /DoRTS-.20      ;s
         DATA    /DoRTS-.20      ;t
         DATA    /DoRTS-.20      ;u
         DATA    /DoRTS-.20      ;v
         DATA    /DoRTS-.20      ;w
         DATA    /DoRTS-.20      ;x
         DATA    /DECTST-.20     ;y
         DATA    /DoRTS-.20      ;z
*--------------------------------
SCSG0    LEA     G0ptr(A5),A1
         BRA.S   SCS
SCSG1    LEA     G1ptr(A5),A1
SCS      CLR     Dmode(A5)
         CMP.B   #'A,D0
         BEQ.S   .0
         CMP.B   #'B,D0
         BEQ.S   .1
         CMP.B   #'0,D0
         BEQ.S   .2
         CMP.B   #'1,D0
         BEQ.S   .1
         CMP.B   #'2,D0
         BEQ.S   .2
         RTS
.0       LEA     OFSTuk(PC),A0
         BRA.S   .3
.1       LEA     OFSTasc(PC),A0
         BRA.S   .3
.2       LEA     OFSTspc(PC),A0
.3       MOVE.L  A0,(A1)
         RTS
DoEGM    LEA     OFSTspc(PC),A0
         MOVE.L  A0,G0ptr(A5)
         MOVE.L  A0,G1ptr(A5)
         RTS
DoXGM    LEA     OFSTasc(PC),A0
         MOVE.L  A0,G0ptr(A5)
         MOVE.L  A0,G1ptr(A5)
         RTS
*--------------------------------
HWL100   CLR     Dmode(A5)
DoRTS    RTS
*--------------------------------
DoCUU    MOVE    Prm0(A5),D0
         BNE.S   .0
         ADDQ    #1,D0
.0       MOVE    RowCrs(A5),D1
.1       TST     D1
         BEQ.S   .2
         CMP     TopMrg(A5),D1
         BEQ.S   .2
         SUBQ    #1,D1
         SUBQ    #1,D0
         BNE.S   .1
.2       MOVE    D1,RowCrs(A5)
         RTS
DoCUD    MOVE    Prm0(A5),D0
         BNE.S   .0
         ADDQ    #1,D0
.0       MOVE    RowCrs(A5),D1
.1       CMP     #23,D1
         BEQ.S   .2
         CMP     BotMrg(A5),D1
         BEQ.S   .2
         ADDQ    #1,D1
         SUBQ    #1,D0
         BNE.S   .1
.2       MOVE    D1,RowCrs(A5)
         RTS
DoCUF    MOVE    Prm0(A5),D0
         BNE.S   .0
         ADDQ    #1,D0
.0       MOVE    ColCrs(A5),D1
.1       CMP     #79,D1
         BEQ.S   .2
         ADDQ    #1,D1
         SUBQ    #1,D0
         BNE.S   .1
.2       MOVE    D1,ColCrs(A5)
         RTS
DoCUB    MOVE    Prm0(A5),D0
         BNE.S   .0
         ADDQ    #1,D0
.0       MOVE    ColCrs(A5),D1
.1       TST     D1
         BEQ.S   .2
         SUBQ    #1,D1
         SUBQ    #1,D0
         BNE.S   .1
.2       MOVE    D1,ColCrs(A5)
         RTS
DoDCA    MOVE    #7,Dmode(A5)
         RTS
CAL52    SUB     #31,D0
         MOVE    D0,Prm0(A5)
         MOVE    #8,Dmode(A5)
         RTS
CAC52    SUB     #31,D0
         MOVE    D0,Prm1(A5)
         CLR     Dmode(A5)
DoCUP    MOVE    Prm0(A5),D0
         BEQ.S   .0
         SUBQ    #1,D0
.0       CMP     #24,D0
         BLO.S   .1
         MOVEQ   #23,D0
.1       TST.B   ORGNmode(A5)
         BEQ.S   .2
         ADD     TopMrg(A5),D0
         CMP     BotMrg(A5),D0
         BLS.S   .2
         MOVE    BotMrg(A5),D0
.2       MOVE    D0,RowCrs(A5)
         MOVE    Prm1(A5),D0
         BEQ.S   .3
         SUBQ    #1,D0
.3       CMP     #80,D0
         BLO.S   .4
         MOVEQ   #79,D0
.4       MOVE    D0,ColCrs(A5)
         RTS
DoNEL    CLR     ColCrs(A5)
DoIND    MOVE    RowCrs(A5),D0
         CMP     BotMrg(A5),D0
         BEQ     Uscroll
         CMP     #23,D0
         BEQ.S   .0
         ADDQ    #1,RowCrs(A5)
.0       RTS
DoRI     MOVE    RowCrs(A5),D0
         CMP     TopMrg(A5),D0
         BEQ     Dscroll
         TST     D0
         BEQ.S   .0
         SUBQ    #1,RowCrs(A5)
.0       RTS
DECSC    MOVE    RowCrs(A5),RowSav(A5)
         MOVE    ColCrs(A5),ColSav(A5)
         MOVE.B  Attrib(A5),AttSav(A5)
         MOVE.L  FONTptr(A5),FONTsav(A5)
         MOVE.L  G0ptr(A5),G0sav(A5)
         MOVE.L  G1ptr(A5),G1sav(A5)
         MOVE.L  OFSTptr(A5),OFSTsav(A5)
         MOVE.B  ORGNmode(A5),ORGNsav(A5)
         RTS
DECRC    MOVE    RowSav(A5),RowCrs(A5)
         MOVE    ColSav(A5),ColCrs(A5)
         MOVE.B  AttSav(A5),Attrib(A5)
         MOVE.L  FONTsav(A5),FONTptr(A5)
         MOVE.L  G0sav(A5),G0ptr(A5)
         MOVE.L  G1sav(A5),G1ptr(A5)
         MOVE.L  OFSTsav(A5),OFSTptr(A5)
         MOVE.B  ORGNsav(A5),ORGNmode(A5)
         RTS
DoSGR    LEA     Prm0(A5),A1
         MOVE    PrmPtr(A5),D1
         LSR     #1,D1
.0       MOVE    (A1)+,D0        ;Off
         BNE.S   .1
         LEA     FONTpln(PC),A0
         MOVE.L  A0,FONTptr(A5)
         CLR.B   Attrib(A5)
         BRA.S   .5
.1       SUBQ    #1,D0           ;Bold
         BNE.S   .2
         LEA     FONTbld(PC),A0
         MOVE.L  A0,FONTptr(A5)
         BRA.S   .5
.2       SUBQ    #3,D0           ;Underscore
         BNE.S   .3
         BSET    #1,Attrib(A5)
         BRA.S   .5
.3       SUBQ    #1,D0           ;Blink
         BNE.S   .4
         BSET    #0,Attrib(A5)
         BRA.S   .5
.4       SUBQ    #2,D0           ;Reverse
         BNE.S   .5
         BSET    #0,Attrib(A5)
.5       DBRA    D1,.0
         RTS
DoEL     MOVE    Prm0(A5),D0
         BEQ     DoEL0
         SUBQ    #1,D0
         BEQ     DoEL1
         SUBQ    #1,D0
         BEQ     DoEL2
         RTS
DoED     MOVE    Prm0(A5),D0
         BEQ     DoED0
         SUBQ    #1,D0
         BEQ     DoED1
         SUBQ    #1,D0
         BEQ     DoED2
         RTS
DECSTBM  TST.L   Prm0(A5)
         BNE.S   .0
         MOVE    #00,TopMrg(A5)
         MOVE    #23,BotMrg(A5)
         BRA.S   DoHO
.0       MOVE    Prm0(A5),D0
         BEQ.S   .1
         SUBQ    #1,D0
         CMP     #24,D0
         BHS.S   DoHO
.1       MOVE    Prm1(A5),D1
         BEQ.S   .2
         SUBQ    #1,D1
         CMP     #24,D1
         BHS.S   DoHO
.2       CMP     D0,D1
         BLS.S   DoHO
         MOVE    D0,TopMrg(A5)
         MOVE    D1,BotMrg(A5)
DoHO     CLR     RowCrs(A5)
         CLR     ColCrs(A5)
         TST.B   ORGNmode(A5)
         BEQ.S   .0
         MOVE    TopMrg(A5),RowCrs(A5)
.0       RTS
DoHTS    LEA     TabFlg(A5),A0
         ADD     ColCrs(A5),A0
         ST      (A0)
         RTS
DoTBC    MOVE    Prm0(A5),D0
         BNE.S   .0
         LEA     TabFlg(A5),A0
         ADD     ColCrs(A5),A0
         SF      (A0)
         RTS
.0       CMP     #3,D0
         BNE.S   .2
         LEA     TabFlg(A5),A0
         MOVEQ   #80/4-1,D0
.1       CLR.L   (A0)+
         DBRA    D0,.1
.2       RTS
DoRM     LEA     Prm0(A5),A1
         MOVE    PrmPtr(A5),D1
         LSR     #1,D1
.0       MOVE    (A1)+,D0        ;0
         BEQ.S   .5
         SUB     #20,D0          ;20
         BNE.S   .1
         SF      LFNLmode(A5)
         BRA.S   .5
.1       SUB     #981,D0         ;?1
         BNE.S   .2
         SF      CRSRmode(A5)
         BRA.S   .5
.2       SUBQ    #1,D0           ;?2
         BNE.S   .3
         BSR     DoVT52
         BRA.S   .5
.3       SUBQ    #4,D0           ;?6
         BNE.S   .4
         SF      ORGNmode(A5)
         BSR     DoHO
         BRA.S   .5
.4       SUBQ    #1,D0           ;?7
         BNE.S   .5
         SF      WRAPmode(A5)
.5       DBRA    D1,.0
         RTS
DoSM     LEA     Prm0(A5),A1
         MOVE    PrmPtr(A5),D1
         LSR     #1,D1
.0       MOVE    (A1)+,D0        ;0
         BEQ.S   .5
         SUB     #20,D0          ;20
         BNE.S   .1
         ST      LFNLmode(A5)
         BRA.S   .5
.1       SUB     #981,D0         ;?1
         BNE.S   .2
         ST      CRSRmode(A5)
         BRA.S   .5
.2       SUBQ    #1,D0           ;?2
         BNE.S   .3
         BSR     DoANSI
         BRA.S   .5
.3       SUBQ    #4,D0           ;?6
         BNE.S   .4
         ST      ORGNmode(A5)
         BSR     DoHO
         BRA.S   .5
.4       SUBQ    #1,D0           ;?7
         BNE.S   .5
         ST      WRAPmode(A5)
.5       DBRA    D1,.0
         RTS
DoVT52   SF      ANSImode(A5)
         RTS
DoANSI   ST      ANSImode(A5)
         RTS
DECKPNM  SF      KPADmode(A5)
         RTS
DECKPAM  ST      KPADmode(A5)
         RTS
DECTST   CMP     #2,Prm0(A5)
         BNE.S   RISrts
         TST     Prm1(A5)
         BEQ.S   RISrts
DoRIS    BSR     DoED2
         BSR     DoReset
         MOVEQ   #$11,D0
         BSR     DoCHR
RISrts   RTS
DoDSR    MOVE    Prm0(A5),D0
         CMP     #6,D0
         BEQ.S   DoCPR
         CMP     #5,D0
         BNE.S   .0
         LEA     .10(PC),A0
         BSR     DoSTR
.0       RTS
.10      HEX     041B5B306E00
DoCPR    LEA     Str64(A5),A0
         CLR     D1
         MOVE.B  #$1B,1(A0,D1)
         ADDQ    #1,D1
         MOVE.B  #$5B,1(A0,D1)
         ADDQ    #1,D1
         MOVE    RowCrs(A5),D0
         TST.B   ORGNmode(A5)
         BEQ.S   .0
         SUB     TopMrg(A5),D0
.0       BSR.S   .10
         MOVE.B  #$3B,1(A0,D1)
         ADDQ    #1,D1
         MOVE    ColCrs(A5),D0
         BSR.S   .10
         MOVE.B  #$52,1(A0,D1)
         ADDQ    #1,D1
         MOVE.B  D1,(A0)
         BSR     DoSTR
         RTS
.10      MOVE.B  .20(PC,D0),D2
         CMP.B   #'0,D2
         BEQ.S   .11
         MOVE.B  D2,1(A0,D1)
         ADDQ    #1,D1
.11      MOVE.B  .21(PC,D0),D2
         MOVE.B  D2,1(A0,D1)
         ADDQ    #1,D1
         RTS
.20      ASC     "0000000001111111111222222222233333333334"
         ASC     "4444444445555555555666666666677777777778"
.21      ASC     "1234567890123456789012345678901234567890"
         ASC     "1234567890123456789012345678901234567890"
DoDA     TST     Prm0(A5)
         BNE.S   DArts
DECID    LEA     DAstr(PC),A0
         BSR     DoSTR
DArts    RTS
DAstr    HEX     071B5B3F313B3263
DoZ52    LEA     .10(PC),A0
         BSR     DoSTR
         RTS
.10      HEX     031B2F5A
DoReset  CLR     Dmode(A5)
         SF      LFNLmode(A5)
         SF      CRSRmode(A5)
         ST      ANSImode(A5)
         SF      ORGNmode(A5)
         SF      WRAPmode(A5)
         SF      KPADmode(A5)
         LEA     OFSTasc(PC),A0
         MOVE.L  A0,G0ptr(A5)
         MOVE.L  A0,G1ptr(A5)
         LEA     G0ptr(A5),A0
         MOVE.L  A0,OFSTptr(A5)
         LEA     FONTpln(PC),A0
         MOVE.L  A0,FONTptr(A5)
         CLR.B   Attrib(A5)
         MOVE    #00,TopMrg(A5)
         MOVE    #23,BotMrg(A5)
         LEA     TabFlg(A5),A0
         MOVE.L  #$FF000000,D0
         MOVEQ   #80/8-1,D1
.0       MOVE.L  D0,(A0)+
         CLR.L   (A0)+
         DBRA    D1,.0
         BSR     DoHO
         BSR     DECSC
         RTS
*--------------------------------
DoED0    BSR     DoEL0
         MOVE    RowCrs(A5),D1
         CMP     #23,D1
         BHS.S   .2
         ADDQ    #1,D1
         LEA     MyScreen,A0
         LEA     RowTbl(PC),A1
         MOVE    D1,D0
         ADD     D0,D0
         ADD     0(A1,D0),A0
.0       MOVEQ   #Height-1,D0
.1       CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         ADDQ.L  #4,A0
         DBRA    D0,.1
         ADDQ    #1,D1
         CMP     #24,D1
         BLO.S   .0
.2       RTS
*--------------------------------
DoED1    MOVE    RowCrs(A5),D1
         BEQ.S   .2
         LEA     MyScreen,A0
.0       MOVEQ   #Height-1,D0
.1       CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         ADDQ.L  #4,A0
         DBRA    D0,.1
         SUBQ    #1,D1
         BNE.S   .0
.2       BSR     DoEL1
         RTS
*--------------------------------
DoED2    LEA     MyScreen,A0
         MOVE    #24*Height-1,D0
.0       CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         ADDQ.L  #4,A0
         DBRA    D0,.0
         RTS
*--------------------------------
DoEL0    LEA     MyScreen,A0
         LEA     RowTbl(PC),A1
         MOVE    RowCrs(A5),D1
         ADD     D1,D1
         ADD     0(A1,D1),A0
         LEA     CblTbl(PC),A1
         MOVE    ColCrs(A5),D1
         LSL     #2,D1
         MOVE    2(A1,D1),D2
         MOVE    0(A1,D1),D1
         ADD     D1,A0
         ADD     D1,A0
         MOVEQ   #$FF,D0
         LSL.L   D2,D0
         LEA     .1(PC,D1),A2
         MOVEQ   #Height-1,D1
.0       MOVE.L  A0,A1
         AND.L   D0,(A1)+
         JMP     (A2)
.1       CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)
         ADD     #64,A0
         DBRA    D1,.0
         RTS
*--------------------------------
DoEL1    LEA     MyScreen,A0
         LEA     RowTbl(PC),A1
         MOVE    RowCrs(A5),D1
         ADD     D1,D1
         ADD     0(A1,D1),A0
         LEA     CelTbl(PC),A1
         MOVE    ColCrs(A5),D1
         LSL     #2,D1
         MOVE    2(A1,D1),D2
         MOVE    0(A1,D1),D1
         MOVEQ   #$FF,D0
         LSR.L   D2,D0
         LEA     .1(PC,D1),A2
         MOVEQ   #Height-1,D1
.0       MOVE.L  A0,A1
         JMP     (A2)
.1       CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         AND.L   D0,(A1)
         ADD     #64,A0
         DBRA    D1,.0
         RTS
*--------------------------------
DoEL2    LEA     MyScreen,A0
         LEA     RowTbl(PC),A1
         MOVE    RowCrs(A5),D1
         ADD     D1,D1
         ADD     0(A1,D1),A0
         MOVEQ   #Height-1,D0
.0       CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         CLR.L   (A0)+
         ADDQ.L  #4,A0
         DBRA    D0,.0
         RTS
*--------------------------------
Uscroll  LEA     MyScreen,A1
         LEA     RowTbl(PC),A0
         MOVE    TopMrg(A5),D0
         ADD     D0,D0
         ADD     0(A0,D0),A1
         LEA     Height*64(A1),A0
         MOVE    BotMrg(A5),D1
         SUB     TopMrg(A5),D1
         SUBQ    #1,D1
.0       MOVEQ   #Height-1,D0
.1       MOVE.L  (A0)+,(A1)+
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
         ADDQ.L  #4,A0
         ADDQ.L  #4,A1
         DBRA    D0,.1
         DBRA    D1,.0
         MOVEQ   #Height-1,D0
.2       CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         CLR.L   (A1)+
         ADDQ.L  #4,A1
         DBRA    D0,.2
         RTS
*--------------------------------
Dscroll  LEA     MyScreen,A0
         LEA     RowTbl(PC),A1
         MOVE    BotMrg(A5),D0
         ADD     D0,D0
         ADD     0(A1,D0),A0
         LEA     Height*64(A0),A1
         MOVE    BotMrg(A5),D1
         SUB     TopMrg(A5),D1
         SUBQ    #1,D1
.0       MOVEQ   #Height-1,D0
.1       SUBQ.L  #4,A0
         SUBQ.L  #4,A1
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         MOVE.L  -(A0),-(A1)
         DBRA    D0,.1
         DBRA    D1,.0
         MOVEQ   #Height-1,D0
.2       SUBQ.L  #4,A1
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         CLR.L   -(A1)
         DBRA    D0,.2
         RTS
*--------------------------------
OutPlt   MOVE.L  FONTptr(A5),A0
         MOVE.L  OFSTptr(A5),A1
         MOVE.L  (A1),A1
         ADD     D0,D0
         ADD     0(A1,D0),A0
         BTST    #1,Attrib(A5)
         BEQ.S   .0
         MOVE.B  Height(A0),D0
         EOR.B   D0,Height-1(A0)
.0       LEA     RowTbl(PC),A1
         MOVE    RowCrs(A5),D1
         ADD     D1,D1
         MOVE    0(A1,D1),D0
         LEA     ColTbl(PC),A1
         MOVE    ColCrs(A5),D1
         LSL     #2,D1
         ADD     0(A1,D1),D0
         MOVE    2(A1,D1),D1
         LEA     MyScreen,A1
         ADD     D0,A1
         MOVEQ   #64,D3
         MOVEQ   #Height-1,D4
         MOVEQ   #$3F,D2
         CMP     #12,D1
         BHS     .9
         CMP     #4,D1
         BHS.S   .6
         TST     D1
         BNE.S   .3
         BTST    #0,Attrib(A5)
         BNE.S   .2
         NOT.B   D2
.1       MOVE.B  (A0)+,D0
         AND.B   D2,(A1)
         EOR.B   D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.1
         BRA     .12
.2       MOVE.B  (A0)+,D0
         OR.B    D2,(A1)
         EOR.B   D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.2
         BRA     .12
.3       LSL.B   D1,D2
         BTST    #0,Attrib(A5)
         BNE.S   .5
         NOT.B   D2
.4       MOVE.B  (A0)+,D0
         LSL.B   D1,D0
         AND.B   D2,(A1)
         EOR.B   D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.4
         BRA.S   .12
.5       MOVE.B  (A0)+,D0
         LSL.B   D1,D0
         OR.B    D2,(A1)
         EOR.B   D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.5
         BRA.S   .12
.6       LSL     D1,D2
         BTST    #0,Attrib(A5)
         BNE.S   .8
         NOT     D2
.7       CLR     D0
         MOVE.B  (A0)+,D0
         LSL     D1,D0
         AND     D2,(A1)
         EOR     D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.7
         BRA.S   .12
.8       CLR     D0
         MOVE.B  (A0)+,D0
         LSL     D1,D0
         OR      D2,(A1)
         EOR     D0,(A1)
         ADD     D3,A1
         DBRA    D4,.8
         BRA.S   .12
.9       LSL.L   D1,D2
         BTST    #0,Attrib(A5)
         BNE.S   .11
         NOT.L   D2
.10      CLR.L   D0
         MOVE.B  (A0)+,D0
         LSL.L   D1,D0
         AND.L   D2,(A1)
         EOR.L   D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.10
         BRA.S   .12
.11      CLR.L   D0
         MOVE.B  (A0)+,D0
         LSL.L   D1,D0
         OR.L    D2,(A1)
         EOR.L   D0,(A1)
         ADD.L   D3,A1
         DBRA    D4,.11
.12      BTST    #1,Attrib(A5)
         BEQ.S   .13
         MOVE.B  (A0),D0
         EOR.B   D0,-1(A0)
.13      CMP     #79,ColCrs(A5)
         BHS.S   .14
         ADDQ    #1,ColCrs(A5)
         RTS
.14      TST.B   WRAPmode(A5)
         BNE     DoNEL
         RTS
*--------------------------------
OnCrs    TST.B   CrsOn(A5)
         BNE.S   .0
         BSR     InvCrs
         ST      CrsOn(A5)
.0       RTS
OffCrs   TST.B   CrsOn(A5)
         BEQ.S   .0
         BSR     InvCrs
         SF      CrsOn(A5)
.0       MOVE.L  Ticks,CrsTime(A5)
         RTS
InvCrs   MOVEM.L D0/A0,-(SP)
         LEA     RowTbl(PC),A1
         MOVE    RowCrs(A5),D1
         ADD     D1,D1
         MOVE    0(A1,D1),D0
         LEA     ColTbl(PC),A1
         MOVE    ColCrs(A5),D1
         LSL     #2,D1
         ADD     0(A1,D1),D0
         MOVE    2(A1,D1),D1
         LEA     MyScreen+Ascent*64,A1
         ADD     D0,A1
         MOVEQ   #$3F,D0
         CMP     #12,D1
         BHS.S   .1
         CMP     #4,D1
         BHS.S   .0
         LSL.B   D1,D0
         EOR.B   D0,(A1)
         BRA.S   .2
.0       LSL     D1,D0
         EOR     D0,(A1)
         BRA.S   .2
.1       LSL.L   D1,D0
         EOR.L   D0,(A1)
.2       MOVEM.L (SP)+,D0/A0
         RTS
*--------------------------------
RowTbl   HEX     0000.0280.0500.0780.0A00.0C80.0F00.1180
         HEX     1400.1680.1900.1B80.1E00.2080.2300.2580
         HEX     2800.2A80.2D00.2F80.3200.3480.3700.3980
*--------------------------------
ColTbl   HEX     00000002.00000004.0000000E.00020000
         HEX     00030002.0002000C.00040006.00050000
         HEX     00060002.00060004.0006000E.00080000
         HEX     00090002.0008000C.000A0006.000B0000
         HEX     000C0002.000C0004.000C000E.000E0000
         HEX     000F0002.000E000C.00100006.00110000
         HEX     00120002.00120004.0012000E.00140000
         HEX     00150002.0014000C.00160006.00170000
         HEX     00180002.00180004.0018000E.001A0000
         HEX     001B0002.001A000C.001C0006.001D0000
         HEX     001E0002.001E0004.001E000E.00200000
         HEX     00210002.0020000C.00220006.00230000
         HEX     00240002.00240004.0024000E.00260000
         HEX     00270002.0026000C.00280006.00290000
         HEX     002A0002.002A0004.002A000E.002C0000
         HEX     002D0002.002C000C.002E0006.002F0000
         HEX     00300002.00300004.0030000E.00320000
         HEX     00330002.0032000C.00340006.00350000
         HEX     00360002.00360004.0036000E.00380000
         HEX     00390002.0038000C.003A0006.003B0000
*--------------------------------
CblTbl   HEX     00000020.0000001A.00000014.0000000E
         HEX     00000008.00000002.0002001C.00020016
         HEX     00020010.0002000A.00020004.0004001E
         HEX     00040018.00040012.0004000C.00040006
         HEX     00060020.0006001A.00060014.0006000E
         HEX     00060008.00060002.0008001C.00080016
         HEX     00080010.0008000A.00080004.000A001E
         HEX     000A0018.000A0012.000A000C.000A0006
         HEX     000C0020.000C001A.000C0014.000C000E
         HEX     000C0008.000C0002.000E001C.000E0016
         HEX     000E0010.000E000A.000E0004.0010001E
         HEX     00100018.00100012.0010000C.00100006
         HEX     00120020.0012001A.00120014.0012000E
         HEX     00120008.00120002.0014001C.00140016
         HEX     00140010.0014000A.00140004.0016001E
         HEX     00160018.00160012.0016000C.00160006
         HEX     00180020.0018001A.00180014.0018000E
         HEX     00180008.00180002.001A001C.001A0016
         HEX     001A0010.001A000A.001A0004.001C001E
         HEX     001C0018.001C0012.001C000C.001C0006
*--------------------------------
CelTbl   HEX     001C0006.001C000C.001C0012.001C0018
         HEX     001C001E.001A0004.001A000A.001A0010
         HEX     001A0016.001A001C.00180002.00180008
         HEX     0018000E.00180014.0018001A.00180020
         HEX     00160006.0016000C.00160012.00160018
         HEX     0016001E.00140004.0014000A.00140010
         HEX     00140016.0014001C.00120002.00120008
         HEX     0012000E.00120014.0012001A.00120020
         HEX     00100006.0010000C.00100012.00100018
         HEX     0010001E.000E0004.000E000A.000E0010
         HEX     000E0016.000E001C.000C0002.000C0008
         HEX     000C000E.000C0014.000C001A.000C0020
         HEX     000A0006.000A000C.000A0012.000A0018
         HEX     000A001E.00080004.0008000A.00080010
         HEX     00080016.0008001C.00060002.00060008
         HEX     0006000E.00060014.0006001A.00060020
         HEX     00040006.0004000C.00040012.00040018
         HEX     0004001E.00020004.0002000A.00020010
         HEX     00020016.0002001C.00000002.00000008
         HEX     0000000E.00000014.0000001A.00000020
*--------------------------------
OFSTuk   HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.018C.0198.015C.01B0.01BC.01C8.01D4
         HEX     01E0.01EC.01F8.0204.0210.021C.0228.0234
         HEX     0240.024C.0258.0264.0270.027C.0288.0294
         HEX     02A0.02AC.02B8.02C4.02D0.02DC.02E8.02F4
         HEX     0300.030C.0318.0324.0330.033C.0348.0354
         HEX     0360.036C.0378.0384.0390.039C.03A8.03B4
         HEX     03C0.03CC.03D8.03E4.03F0.03FC.0408.0414
         HEX     0420.042C.0438.0444.0450.045C.0468.0474
         HEX     0480.048C.0498.04A4.04B0.04BC.04C8.04D4
         HEX     04E0.04EC.04F8.0504.0510.051C.0528.0534
         HEX     0540.054C.0558.0564.0570.057C.0588.0594
         HEX     05A0.05AC.05B8.05C4.05D0.05DC.05E8.000C
*--------------------------------
OFSTasc  HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.018C.0198.01A4.01B0.01BC.01C8.01D4
         HEX     01E0.01EC.01F8.0204.0210.021C.0228.0234
         HEX     0240.024C.0258.0264.0270.027C.0288.0294
         HEX     02A0.02AC.02B8.02C4.02D0.02DC.02E8.02F4
         HEX     0300.030C.0318.0324.0330.033C.0348.0354
         HEX     0360.036C.0378.0384.0390.039C.03A8.03B4
         HEX     03C0.03CC.03D8.03E4.03F0.03FC.0408.0414
         HEX     0420.042C.0438.0444.0450.045C.0468.0474
         HEX     0480.048C.0498.04A4.04B0.04BC.04C8.04D4
         HEX     04E0.04EC.04F8.0504.0510.051C.0528.0534
         HEX     0540.054C.0558.0564.0570.057C.0588.0594
         HEX     05A0.05AC.05B8.05C4.05D0.05DC.05E8.000C
*--------------------------------
OFSTspc  HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.0180.0180.0180.0180.0180.0180.0180
         HEX     0180.018C.0198.01A4.01B0.01BC.01C8.01D4
         HEX     01E0.01EC.01F8.0204.0210.021C.0228.0234
         HEX     0240.024C.0258.0264.0270.027C.0288.0294
         HEX     02A0.02AC.02B8.02C4.02D0.02DC.02E8.02F4
         HEX     0300.030C.0318.0324.0330.033C.0348.0354
         HEX     0360.036C.0378.0384.0390.039C.03A8.03B4
         HEX     03C0.03CC.03D8.03E4.03F0.03FC.0408.0414
         HEX     0420.042C.0438.0444.0450.045C.0468.0174
         HEX     0000.000C.0018.0024.0030.003C.0048.0054
         HEX     0060.006C.0078.0084.0090.009C.00A8.00B4
         HEX     00C0.00CC.00D8.00E4.00F0.00FC.0108.0114
         HEX     0120.012C.0138.0144.0150.015C.0168.000C
*--------------------------------
FONTpln  HEX     0000081C3E1C080000003F00 Diamond
         HEX     002A142A142A142A00003F00 Checkerboard
         HEX     282838282E04040404003100 Horizontal tab
         HEX     382030202E080C0808002300 Form feed
         HEX     382020380E0A0C0A0A002000 Carriage return
         HEX     202020380E080C0808002300 Line feed
         HEX     0C12120C0000000000003F00 Degree symbol
         HEX     0008083E0808003E00003F00 Plus/minus
         HEX     30282828000808080E002000 New line
         HEX     28282810000E040404003100 Vertical tab
         HEX     080808083800000000003F00 Lower-right corner
         HEX     000000003808080808082300 Upper-right corner
         HEX     000000000F08080808082300 Upper-left corner
         HEX     080808080F00000000003F00 Lower-left corner
         HEX     080808083F08080808082300 Crossing lines
         HEX     3F0000000000000000003F00 Horizontal line - Scan 1
         HEX     00003F000000000000003F00 Horizontal line - Scan 3
         HEX     000000003F00000000003F00 Horizontal line - Scan 5
         HEX     0000000000003F0000003F00 Horizontal line - Scan 7
         HEX     00000000000000003F000000 Horizontal line - Scan 9
         HEX     080808080F08080808082300 Left "T"
         HEX     080808083808080808082300 Right "T"
         HEX     080808083F00000000003F00 Bottom "T"
         HEX     000000003F08080808082300 Top "T"
         HEX     080808080808080808082300 Vertical bar
         HEX     000408100804001C00003F00 Less than or equal to
         HEX     001008040810001C00003F00 Greater than or equal to
         HEX     0000003E1414141400003F00 Pi
         HEX     0000043E083E100000003F00 Not equal to
         HEX     001824203820223C00003F00 UK pound sign
         HEX     000000000800000000003F00 Centered dot
         HEX     000000000000000000003F00 Blank
         HEX     000000000000000000003F00
         HEX     000808080808000800003F00 !
         HEX     001414140000000000003F00 "
         HEX     00143E143E14000000003F00 #
         HEX     00081E281C0A3C0800003F00 $
         HEX     003E32040810262600003F00 %
         HEX     00102828102A241A00003F00 &
         HEX     000810000000000000003F00 '
         HEX     000408101010080400003F00 (
         HEX     000804020202040800003F00 )
         HEX     00082A1C081C2A0800003F00 *
         HEX     000008083E08080000003F00 +
         HEX     000000000000000808100300 ,
         HEX     000000003E00000000003F00 -
         HEX     000000000000001000003F00 .
         HEX     000002040810200000003F00 /
         HEX     001C22262A32221C00003F00 0
         HEX     000818080808081C00003F00 1
         HEX     001C22020408103E00003F00 2
         HEX     001C22020C02221C00003F00 3
         HEX     00202024243E040400003F00 4
         HEX     003E203C0202221C00003F00 5
         HEX     000C10203C22221C00003F00 6
         HEX     003E02020408080800003F00 7
         HEX     001C22221C22221C00003F00 8
         HEX     001C22221E02041800003F00 9
         HEX     000000080000080000003F00 :
         HEX     000000000800000808100300 ;
         HEX     000408102010080400003F00 <
         HEX     0000003E003E000000003F00 =
         HEX     001008040204081000003F00 >
         HEX     001C22020408000800003F00 ?
         HEX     001C223A2A3E201C00003F00 @
         HEX     001C22223E22222200003F00 A
         HEX     003C22223C22223C00003F00 B
         HEX     001C22202020221C00003F00 C
         HEX     003824222222243800003F00 D
         HEX     003E20203C20203E00003F00 E
         HEX     003E20203C20202000003F00 F
         HEX     001C22202622221C00003F00 G
         HEX     002222223E22222200003F00 H
         HEX     001C08080808081C00003F00 I
         HEX     000202020222221C00003F00 J
         HEX     002224283028242200003F00 K
         HEX     002020202020203E00003F00 L
         HEX     0022362A2222222200003F00 M
         HEX     0022322A2622222200003F00 N
         HEX     001C22222222221C00003F00 O
         HEX     003C22223C20202000003F00 P
         HEX     001C22222222221C02003800 Q
         HEX     003C22223C22222200003F00 R
         HEX     001C22201C02221C00003F00 S
         HEX     003E08080808080800003F00 T
         HEX     002222222222221C00003F00 U
         HEX     002222222222140800003F00 V
         HEX     00222222222A362200003F00 W
         HEX     002222140814222200003F00 X
         HEX     002222221408080800003F00 Y
         HEX     003E02040810203E00003F00 Z
         HEX     001C10101010101C00003F00 [
         HEX     000020100804020000003F00 \
         HEX     001C04040404041C00003F00 ]
         HEX     000814000000000000003F00 ^
         HEX     000000000000003F00003F00 _
         HEX     001008000000000000003F00 `
         HEX     0000001E2222261A00003F00 a
         HEX     0020203C2222223C00003F00 b
         HEX     0000001C2220201E00003F00 c
         HEX     0002021E2222221E00003F00 d
         HEX     0000001C223E201E00003F00 e
         HEX     0006081C0808080800003F00 f
         HEX     0000001E2222221E021C0000 g
         HEX     0020203C2222222200003F00 h
         HEX     000800180808081C00003F00 i
         HEX     000800080808080808300300 j
         HEX     002020242838242200003F00 k
         HEX     001808080808081C00003F00 l
         HEX     0000003C2A2A2A2A00003F00 m
         HEX     0000002C3222222200003F00 n
         HEX     0000001C2222221C00003F00 o
         HEX     0000003C2222223C20200F00 p
         HEX     0000001E2222221E02023800 q
         HEX     0000002C3220202000003F00 r
         HEX     0000001E201C023C00003F00 s
         HEX     0008081C0808080600003F00 t
         HEX     000000222222261A00003F00 u
         HEX     000000222222140800003F00 v
         HEX     000000222A2A2A1400003F00 w
         HEX     000000221408142200003F00 x
         HEX     000000222222221E021C0000 y
         HEX     0000003E0408103E00003F00 z
         HEX     040808081008080804003100 {
         HEX     080808080008080808002300 |
         HEX     100808080408080810000700 }
         HEX     001A2C000000000000003F00 ~
*--------------------------------
FONTbld  HEX     0000081C3E1C080000003F00 Diamond
         HEX     002A142A142A142A00003F00 Checkerboard
         HEX     282838282E04040404003100 Horizontal tab
         HEX     382030202E080C0808002300 Form feed
         HEX     382020380E0A0C0A0A002000 Carriage return
         HEX     202020380E080C0808002300 Line feed
         HEX     0C1A1A0C0000000000003F00 Degree symbol
         HEX     0008083E0808003E00003F00 Plus/minus
         HEX     30282828000808080E002000 New line
         HEX     28282810000E040404003100 Vertical tab
         HEX     0C0C0C0C3C00000000003F00 Lower-right corner
         HEX     000000003C0C0C0C0C0C2100 Upper-right corner
         HEX     000000000F0C0C0C0C0C2100 Upper-left corner
         HEX     0C0C0C0C0F00000000003F00 Lower-left corner
         HEX     0C0C0C0C3F0C0C0C0C0C2100 Crossing lines
         HEX     3F0000000000000000003F00 Horizontal line - Scan 1
         HEX     00003F000000000000003F00 Horizontal line - Scan 3
         HEX     000000003F00000000003F00 Horizontal line - Scan 5
         HEX     0000000000003F0000003F00 Horizontal line - Scan 7
         HEX     00000000000000003F000000 Horizontal line - Scan 9
         HEX     0C0C0C0C0F0C0C0C0C0C2100 Left "T"
         HEX     0C0C0C0C3C0C0C0C0C0C2100 Right "T"
         HEX     0C0C0C0C3F00000000003F00 Bottom "T"
         HEX     000000003F0C0C0C0C0C2100 Top "T"
         HEX     0C0C0C0C0C0C0C0C0C0C2100 Vertical bar
         HEX     000408100804001C00003F00 Less than or equal to
         HEX     001008040810001C00003F00 Greater than or equal to
         HEX     0000003E1414141400003F00 Pi
         HEX     0000043E083E100000003F00 Not equal to
         HEX     001834303830323C00003F00 UK pound sign
         HEX     000000000C00000000003F00 Centered dot
         HEX     000000000000000000003F00 Blank
         HEX     000000000000000000003F00
         HEX     000C0C0C0C0C000C00003F00 !
         HEX     001414140000000000003F00 "
         HEX     0014143E143E141400003F00 #
         HEX     00081E281C0A3C0800003F00 $
         HEX     003E32340816262600003F00 %
         HEX     00102828102A241A00003F00 &
         HEX     001818102000000000003F00 '
         HEX     000408181818080400003F00 (
         HEX     000804060606040800003F00 )
         HEX     00082A1C3E1C2A0800003F00 *
         HEX     000008083E08080000003F00 +
         HEX     0000000000000C0C08100300 ,
         HEX     000000003E00000000003F00 -
         HEX     000000000000181800003F00 .
         HEX     000002060C18302000003F00 /
         HEX     001C3232363A321C00003F00 0
         HEX     000C1C0C0C0C0C1E00003F00 1
         HEX     001C26060C18303E00003F00 2
         HEX     001C26060C06261C00003F00 3
         HEX     000C1C2C2C3E0C0C00003F00 4
         HEX     003E303C0606261C00003F00 5
         HEX     001C32303C32321C00003F00 6
         HEX     003E06060C18181800003F00 7
         HEX     001C32321C32321C00003F00 8
         HEX     001C26261E06261C00003F00 9
         HEX     000018180018180000003F00 :
         HEX     0000000C0C000C0C08100300 ;
         HEX     000408102010080400003F00 <
         HEX     0000003E003E000000003F00 =
         HEX     001008040204081000003F00 >
         HEX     001C26060408000800003F00 ?
         HEX     001C222E2E2E201C00003F00 @
         HEX     001C32323E32323200003F00 A
         HEX     003C32323C32323C00003F00 B
         HEX     001C32303030321C00003F00 C
         HEX     003834323232343800003F00 D
         HEX     003E30303C30303E00003F00 E
         HEX     003E30303C30303000003F00 F
         HEX     001C32303632321C00003F00 G
         HEX     003232323E32323200003F00 H
         HEX     001E0C0C0C0C0C1E00003F00 I
         HEX     000606060626261C00003F00 J
         HEX     003234383038343200003F00 K
         HEX     003030303030303E00003F00 L
         HEX     00323E323232323200003F00 M
         HEX     003C32323232323200003F00 N
         HEX     001C32323232321C00003F00 O
         HEX     003C32323C30303000003F00 P
         HEX     001C32323232321C02003800 Q
         HEX     003C32323C32323200003F00 R
         HEX     001C32301C06261C00003F00 S
         HEX     003C18181818181800003F00 T
         HEX     003232323232321C00003F00 U
         HEX     003232323232140800003F00 V
         HEX     0032323232323E3200003F00 W
         HEX     003232321C32323200003F00 X
         HEX     003232321C0C0C0C00003F00 Y
         HEX     003E06061C30303E00003F00 Z
         HEX     001C18181818181C00003F00 [
         HEX     00002030180C060200003F00 \
         HEX     001C0C0C0C0C0C1C00003F00 ]
         HEX     000814000000000000003F00 ^
         HEX     000000000000003F00003F00 _
         HEX     001818080400000000003F00 `
         HEX     0000001E2626261E00003F00 a
         HEX     0030303C3232323C00003F00 b
         HEX     0000001C3230301E00003F00 c
         HEX     0006061E2626261E00003F00 d
         HEX     0000001C323E301E00003F00 e
         HEX     000E183C1818181800003F00 f
         HEX     0000001E2626261E061C0000 g
         HEX     0030303C3232323200003F00 h
         HEX     000C001C0C0C0C1E00003F00 i
         HEX     000C000C0C0C0C0C0C380100 j
         HEX     003030343838343200003F00 k
         HEX     001C0C0C0C0C0C1E00003F00 l
         HEX     000000323E32323200003F00 m
         HEX     0000003C3232323200003F00 n
         HEX     0000001C3232321C00003F00 o
         HEX     0000003C3232323C30300700 p
         HEX     0000001E2626261E06063000 q
         HEX     0000003C3230303000003F00 r
         HEX     0000001E303E063C00003F00 s
         HEX     0018183E1818180E00003F00 t
         HEX     000000262626261E00003F00 u
         HEX     0000003232321C0800003F00 v
         HEX     0000003232323E3200003F00 w
         HEX     00000032321C323200003F00 x
         HEX     000000262626261E061C0000 y
         HEX     0000003E061C303E00003F00 z
         HEX     0C181818301818180C002100 {
         HEX     181818180018181818000300 |
         HEX     180C0C0C060C0C0C18000300 }
         HEX     001A2C000000000000003F00 ~
*--------------------------------
Key0     HEX     FFFFFFFFFFFFFFFFFFFFFFFF8000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     81DC8081DDC081DDC081DD008000
         HEX     8151808150408150408151408000
         HEX     81D88081D84081D84081D9408000
         HEX     8110808111C08111C08111C08000
         HEX     8110808111008110408110408000
         HEX     8111C08111C08111C08110408000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     FFFFFFFFFFFFFFFFFFFFFFFF8000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8F80008700008700008000008000
         HEX     8080008880008880008000008000
         HEX     8080008880008880008000008000
         HEX     8100008700008780008F80008000
         HEX     8200008880008080008000008000
         HEX     8200008880008100008000008000
         HEX     8200008700008600008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     FFFFFFFFFFFFFFFFFFFFFFFF8000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8800008F80008300008000008000
         HEX     8800008800008400008000008000
         HEX     8900008F00008800008600008000
         HEX     8900008080008F00008600008000
         HEX     8F80008080008880008200008000
         HEX     8100008880008880008400008000
         HEX     8100008700008700008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     FFFFFFFFFFFFFFFFFFFFFFFF8000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8000008000008000008000008000
         HEX     8200008700008700008000008000
         HEX     8600008880008880008000008000
         HEX     8200008080008080008000008000
         HEX     8200008100008300008000008000
         HEX     8200008200008080008000008000
         HEX     8200008400008880008000008000
         HEX     8700008F80008700008000008000
         HEX     8000008000008000009D9DD88000
         HEX     8000008000008000009149148000
         HEX     8000008000008000009949948000
         HEX     FFFFFFFFFFFFFFFFFF9149188000
         HEX     8000000000008000009149148000
         HEX     8000000000008000009D49D48000
         HEX     8000000000008000008000008000
         HEX     8700000000008000008000008000
         HEX     8880000000008000008000008000
         HEX     8980000000008000008000008000
         HEX     8A80000000008300008000008000
         HEX     8C80000000008300008000008000
         HEX     8880000000008000008000008000
         HEX     8700000000008000008000008000
         HEX     8000000000008000008000008000
         HEX     8000000000008000008000008000
         HEX     8000000000008000008000008000
         HEX     FFFFFFFFFFFFFFFFFFFFFFFF8000
*--------------------------------
Key1     HEX     FFFFFFFFFFFFFF80.8000000800000080
         HEX     8000000800000080.8000000800000080
         HEX     8000000800000080.8000000800200080
         HEX     99D1DDC800700080.9511090800F80080
         HEX     9591898801FC0080.9511090800200080
         HEX     9511090800200080.99DDC9C800200080
         HEX     8000000800200080.8000000800000080
         HEX     8000000800000080.8000000800000080
         HEX     8000000800000080.FFFFFFFFFFFFFF80
         HEX     8000000800000080.8000000800000080
         HEX     8000000800000080.8000000800000080
         HEX     8000000800200080.8667750800200080
         HEX     8554550800200080.8656560800200080
         HEX     8564750801FC0080.8554550800F80080
         HEX     8657550800700080.8000000800200080
         HEX     8000000800000080.8000000800000080
         HEX     8000000800000080.8000000800000080
         HEX     FFFFFFFFFFFFFF80.8000000800000080
         HEX     8000000800000080.811D9C0800000080
         HEX     8109500800000080.8109580800000080
         HEX     8109500800400080.8109500800C00080
         HEX     81DD5C0801C00080.8000000803FC0080
         HEX     81DDD80801C00080.8111140800C00080
         HEX     8199940800400080.8111140800000080
         HEX     8111140800000080.811DD80800000080
         HEX     8000000800000080.8000000800000080
         HEX     FFFFFFFFFFFFFF80.8000000800000080
         HEX     8000000800000080.9880000800000080
         HEX     9540000800000080.9540000800000080
         HEX     9540000800200080.9540000800300080
         HEX     9480000800380080.8000000803FC0080
         HEX     8CD8910800380080.9115510800300080
         HEX     8915510800200080.8519510800000080
         HEX     8515510800000080.98D49DC800000080
         HEX     8000000800000080.8000000800000080
         HEX     FFFFFFFFFFFFFF80
*--------------------------------
         END
