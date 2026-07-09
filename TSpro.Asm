;SAVE"TSpro.Asm"
*--------------------------------
; Telescape Pro v1.3   (11/16/87)
*--------------------------------
         LIST    OFF
*--------------------------------
         INCLUDE ":Sources:Library.Asm"
         INCLUDE ":Sources:Equates.Asm"
*--------------------------------
SOH      EQU     $01
EOT      EQU     $04
ACK      EQU     $06
CR       EQU     $0D
NAK      EQU     $15
CAN      EQU     $18
DEL      EQU     $7F
;
Screen           EQU  $3FA700
;
srcCopy          EQU  0
srcXor           EQU  2
notPatXor        EQU  14
;
lock             EQU  7
everyEvent       EQU  -1
;
KeyMap           EQU  $174
MTemp            EQU  $828
CrsrPin          EQU  $834
CrsrNew          EQU  $8CE
CrsrCouple       EQU  $8CF
IconBitmap       EQU  $A0E
HWCfgFlags       EQU  $B22
;
hwCbADB          EQU  10
;
eofErr           EQU  -39
fnfErr           EQU  -43
dupFNErr         EQU  -48
;
iPrBitsCtl       EQU  4
iPrDevCtl        EQU  7
lPaintBits       EQU  1
lPrDocOpen       EQU  $00010000
lPrPageClose     EQU  $00020000
lPrLineFeed      EQU  $00030000
lPrLFSixth       EQU  $0003FFFF
lPrPageOpen      EQU  $00040000
lPrDocClose      EQU  $00050000
;
AppleID          EQU  128
AboutItem        EQU  1
;
FileID           EQU  129
NewItem          EQU  1
OpenItem         EQU  2
CloseItem        EQU  4
SaveItem         EQU  5
SaveAsItem       EQU  6
RevertItem       EQU  7
QuitItem         EQU  9
;
EditID           EQU  130
UndoItem         EQU  1
CutItem          EQU  3
CopyItem         EQU  4
PasteItem        EQU  5
ClearItem        EQU  6
*--------------------------------
* Private Storage
*--------------------------------
         ORG     0
;
Saved    DEFS    B
Dirty    DEFS    B
Volume   DEFS    W
Version  DEFS    W
Name     DEFS    64
;
wCoord   DEFS    L
cBaud    DEFS    W
cData    DEFS    W
cStop    DEFS    W
cPrty    DEFS    W
cHshk    DEFS    W
tMode    DEFS    W
tBcks    DEFS    W
tKpad    DEFS    W
tEcho    DEFS    W
tLine    DEFS    W
tWrap    DEFS    W
xMode    DEFS    W
xChar    DEFS    W
xCdly    DEFS    W
xLdly    DEFS    W
xMbin    DEFS    W
xTrbo    DEFS    W
xCRC     DEFS    W
pKeys    DEFS    16*40
pText    DEFS    64*40
;
PrivSize EQU     *
*--------------------------------
         GLOBAL  2694
;
SaveBuf          DEFS 512
LoadBuf          DEFS 512
SavePtr          DEFS L
LoadPtr          DEFS L
SaveCnt          DEFS W
LoadCnt          DEFS W
SDvars           DEFS 576
PBw              DEFS 80
PBr              DEFS 80
SFRw             DEFS 74
SFRr             DEFS 74
Str64            DEFS 64
Str32            DEFS 32
EventRecord      DEFS 16
ZoomRect         DEFS 8
TempRect         DEFS 8
Watch            DEFS L
whichWindow      DEFS L
Where            DEFS L
vCdly            DEFS L
vLdly            DEFS L
Pace             DEFS L
MenuID           DEFS W
MenuItem         DEFS W
wCount           DEFS W
vChar            DEFS B
Prompt           DEFS B
Sending          DEFS B
Recving          DEFS B
Quitting         DEFS B
Finished         DEFS B
;
TheWindow        DEFS L
Type             DEFS L
Creator          DEFS L
Flags            DEFS W
Location         DEFS L
Folder           DEFS W
Locked           DEFS W
DataLen          DEFS L
RsrcLen          DEFS L
FlCrDat          DEFS L
FlMdDat          DEFS L
Hdr2Len          DEFS W
;
Buf              DEFS 128
TimeOut          DEFS L
MaxBlk           DEFS W
Block            DEFS W
ErrCnt           DEFS W
Srch             DEFS W
BPtr             DEFS W
CRC              DEFS W
Blk              DEFS W
F.Abort          DEFS B
F.First          DEFS B
F.Turbo          DEFS B
F.CRC            DEFS B
;
TabFlg           DEFS 80
JGetOSEvent      DEFS L
ScrPtr0          DEFS L
ScrPtr1          DEFS L
ScrPtr2          DEFS L
PrtPtr0          DEFS L
PrtPtr1          DEFS L
PrtPtr2          DEFS L
EvThresh         DEFS L
CrsTime          DEFS L
FONTptr          DEFS L
FONTsav          DEFS L
OFSTptr          DEFS L
OFSTsav          DEFS L
G0ptr            DEFS L
G0sav            DEFS L
G1ptr            DEFS L
G1sav            DEFS L
Dmode            DEFS W
PrmPtr           DEFS W
Prm0             DEFS W          ;
Prm1             DEFS W          ;
PrmS             DEFS 28         ;
TopMrg           DEFS W
BotMrg           DEFS W
RowCrs           DEFS W
ColCrs           DEFS W
RowSav           DEFS W
ColSav           DEFS W
CrsrSav          DEFS W
KPADtype         DEFS B
ECHOmode         DEFS B
DLBSmode         DEFS B
LFNLmode         DEFS B
CRSRmode         DEFS B
ANSImode         DEFS B
ORGNmode         DEFS B
WRAPmode         DEFS B
KPADmode         DEFS B
ORGNsav          DEFS B
Attrib           DEFS B
AttSav           DEFS B
CrsOn            DEFS B
Exit             DEFS B
FKflag           DEFS B
                 DEFS *&1
;
                 DEFS grafSize
;
         ENDG
*--------------------------------
         TFILE   "TSpro.Bin"
*--------------------------------
         RFILE   "VT100",APPL,TS00,$2000
*================================
         SEG     0,resPurgeable!resPreLoad,Var.Len,32
SEG0
SEG_1    JP      Start,1
END_1
END0
         ENDR
*================================
         SEG     1,resLocked!resPreLoad
*--------------------------------
Start    PEA     -4(A5)
         _InitGraf
         _InitFonts
         _InitWindows
         _InitMenus
         _TEInit
         CLR.L   -(SP)
         _InitDialogs
         PACK    diLoad,2
         BSR     ScrInit
         BSR     SetUpMenus
         BSR     SetUpWindows
         BSR     SetUpCursors
         MOVE.L  #$0000FFFF,D0
         _FlushEvents
         BSR     SDopen
         BNE.S   SysErr
         SF      Quitting(A5)
         SF      Finished(A5)
*--------------------------------
MainLoop _SystemTask
         BSR     DoEvent
         TST.B   Finished(A5)
         BEQ.S   MainLoop
*--------------------------------
         BSR     WatchCur
         BSR     SDclose
         _ExitToShell
*--------------------------------
SysErr   BSR     DosErr
         BSR     WatchCur
         _ExitToShell
*--------------------------------
DoEvent  CLR.B   -(SP)
         MOVE    #everyEvent,-(SP)
         PEA     EventRecord(A5)
         _GetNextEvent
         TST.B   (SP)+
         BEQ.S   .0
         MOVE    EventRecord+evtNum(A5),D0
         ADD     D0,D0
         MOVE    .10(PC,D0),D0
         JSR     .10(PC,D0)
         BRA.S   .2
.0       TST.B   Quitting(A5)
         BEQ.S   .2
         CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,D0
         BEQ.S   .1
         BSR     DoClose
         BRA.S   .2
.1       ST      Finished(A5)
.2       RTS
.10      DATA    /.2-.10         ; null
         DATA    /MseDown-.10    ; mouse-down
         DATA    /.2-.10         ; mouse-up
         DATA    /KeyDown-.10    ; key-down
         DATA    /.2-.10         ; key-up
         DATA    /KeyDown-.10    ; auto-key
         DATA    /DoUpdate-.10   ; update
         DATA    /DoDisk-.10     ; disk-inserted
         DATA    /.2-.10         ; activate
         DATA    /.2-.10         ;
         DATA    /.2-.10         ; network
         DATA    /.2-.10         ; device-driver
         DATA    /.2-.10         ; application-defined
         DATA    /.2-.10         ; application-defined
         DATA    /.2-.10         ; application-defined
         DATA    /.2-.10         ; suspend/resume
*--------------------------------
KeyDown  TST.B   Quitting(A5)
         BNE.S   .0
         MOVE    EventRecord+evtMeta(A5),D0
         BTST    #8,D0
         BEQ.S   .0
         BSR     ArrowCur
         BSR     UpdMenus
         CLR.L   -(SP)
         MOVE.L  EventRecord+evtMessage(A5),D0
         MOVE    D0,-(SP)
         _MenuKey
         MOVE.L  (SP)+,MenuID(A5)
         BSR     DoMenu
.0       RTS
*--------------------------------
MseDown  TST.B   Quitting(A5)
         BNE.S   .0
         CLR     -(SP)
         MOVE.L  EventRecord+evtMouse(A5),-(SP)
         PEA     whichWindow(A5)
         _FindWindow
         MOVE    (SP)+,D0
         ADD     D0,D0
         MOVE    .10(PC,D0),D0
         JSR     .10(PC,D0)
.0       RTS
.10      DATA    /.0-.10         ; inDesk
         DATA    /inMenuB-.10    ; inMenuBar
         DATA    /SysEvnt-.10    ; inSysWindow
         DATA    /DoCntnt-.10    ; inContent
         DATA    /DoDrag-.10     ; inDrag
         DATA    /.0-.10         ; inGrow
         DATA    /DoGoAwy-.10    ; inGoAway
         DATA    /.0-.10         ; inZoomIn
         DATA    /.0-.10         ; inZoomOut
*--------------------------------
inMenuB  BSR     ArrowCur
         BSR     UpdMenus
         CLR.L   -(SP)
         MOVE.L  EventRecord+evtMouse(A5),-(SP)
         _MenuSelect
         MOVE.L  (SP)+,MenuID(A5)
         BSR     DoMenu
         RTS
*--------------------------------
DoMenu   MOVE    MenuID(A5),D0
         SUB     #AppleID,D0
         BCS.S   .0
         ADD     D0,D0
         MOVE    .10(PC,D0),D0
         JSR     .10(PC,D0)
.0       CLR     -(SP)
         _HiliteMenu
         RTS
.10      DATA    /MnApple-.10    ; Apple
         DATA    /MnuFile-.10    ; File
         DATA    /MnuEdit-.10    ; Edit
*--------------------------------
MnApple  MOVE    MenuItem(A5),D0
         CMP     #AboutItem,D0
         BNE.S   .0
         BSR     DoAbout
         RTS
.0       BSR     DoDesk
         RTS
*--------------------------------
DoAbout  MOVE    #-1,ACount
         CLR     -(SP)
         MOVE    #128,-(SP)
         CLR.L   -(SP)
         _Alert
         TST     (SP)+
         RTS
*--------------------------------
DoDesk   LINK    A6,#-256
         CLR.L   -(SP)
         MOVE    MenuID(A5),-(SP)
         _GetMHandle
         MOVE    MenuItem(A5),-(SP)
         PEA     -256(A6)
         _GetItem
         CLR     -(SP)
         PEA     -256(A6)
         _OpenDeskAcc
         TST     (SP)+
         UNLK    A6
         RTS
*--------------------------------
MnuFile  MOVE    MenuItem(A5),D0
         ADD     D0,D0
         MOVE    .10(PC,D0),D0
         JSR     .10(PC,D0)
.0       RTS
.10      DATA    /.0-.10         ; File
         DATA    /DoNew-.10      ; New
         DATA    /DoOpen-.10     ; Open…
         DATA    /.0-.10         ; -
         DATA    /DoClose-.10    ; Close
         DATA    /DoSave-.10     ; Save
         DATA    /DoSaveAs-.10   ; Save As…
         DATA    /DoRevert-.10   ; Revert
         DATA    /.0-.10         ; -
         DATA    /DoQuit-.10     ; Quit
*--------------------------------
SetUpWindows
         CLR     wCount(A5)
         MOVE.L  AppParmHandle,A2
         MOVE.L  (A2),A2
         TST     (A2)
         BNE.S   .5
         MOVE    2(A2),D4
         BEQ.S   .5
.0       LEA     4(A2),A2
.1       CMP.L   #$54533030,2(A2)        ;"TS00"
         BNE.S   .4
         MOVE.L  #PrivSize,D0
         _NewPtr ,CLEAR
         BNE.S   .3
         MOVE.L  A0,A4
         MOVE    0(A2),Volume(A4)
         MOVE    6(A2),Version(A4)
         LEA     8(A2),A0
         BSR     CopyName
         BSR     DoRead
         BNE.S   .2
         BSR     wOpen
         CLR.L   2(A2)
         BRA.S   .4
.2       MOVE    D0,-(SP)
         MOVE.L  A4,A0
         _DisposPtr
         MOVE    (SP)+,D0
.3       BSR     DosErr
.4       MOVEQ   #1,D0
         OR.B    8(A2),D0
         LEA     9(A2,D0),A2
         SUBQ    #1,D4
         BNE.S   .1
.5       TST     wCount(A5)
         BEQ.S   DoNew
         RTS
*--------------------------------
DoNew    MOVE.L  #PrivSize,D0
         _NewPtr ,CLEAR
         BNE.S   .0
         MOVE.L  A0,A4
         LEA     .10(PC),A0
         BSR     CopyName
         BSR     DoInit
         BSR     wOpen
         BRA.S   .1
.0       BSR     DosErr
.1       RTS
.10      STR     "Untitled"
         ADJST
*--------------------------------
DoOpen   LINK    A6,#-74
         MOVE    #82,-(SP)
         MOVE    #81,-(SP)
         PEA     .11(PC)
         CLR.L   -(SP)
         MOVE    #1,-(SP)
         PEA     .10(PC)
         CLR.L   -(SP)
         PEA     -74(A6)
         MOVE    #sfGetFile,-(SP)
         _Pack3
         TST.B   -74+rGood(A6)
         BEQ.S   .2
         BSR     WatchCur
         BSR     Refresh
         MOVE.L  #PrivSize,D0
         _NewPtr ,CLEAR
         BNE.S   .1
         MOVE.L  A0,A4
         MOVE    -74+rVolume(A6),Volume(A4)
         MOVE    -74+rVersion(A6),Version(A4)
         LEA     -74+rName(A6),A0
         BSR     CopyName
         BSR     DoRead
         BNE.S   .0
         BSR     wOpen
         BSR     ArrowCur
         BRA.S   .2
.0       MOVE    D0,-(SP)
         MOVE.L  A4,A0
         _DisposPtr
         MOVE    (SP)+,D0
.1       BSR     DosErr
.2       UNLK    A6
         RTS
.10      ASC     "TS00"
.11      STR     ""
         ADJST
*--------------------------------
DoClose  CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,D0
         BEQ.S   .1
         MOVE.L  D0,A0
         MOVE.L  A0,whichWindow(A5)
         TST     windowKind(A0)
         BMI.S   .0
         BSR.S   CloseAppWindow
         RTS
.0       BSR.S   CloseSysWindow
.1       RTS
*--------------------------------
CloseAppWindow
         MOVE.L  whichWindow(A5),A3
         MOVE.L  wRefCon(A3),A4
         TST.B   Dirty(A4)
         BEQ.S   .2
         MOVE    #-1,ACount
         CLR     -(SP)
         MOVE    #129,-(SP)
         CLR.L   -(SP)
         _CautionAlert
         MOVE    (SP)+,D0
         CMP     #1,D0
         BEQ.S   .0
         CMP     #3,D0
         BEQ.S   .2
         SF      Quitting(A5)
         BRA.S   .3
.0       BSR     Refresh
         TST.B   Saved(A4)
         BNE.S   .1
         BSR     SaveAs
         BRA.S   .2
.1       BSR     Save
.2       MOVE.L  A4,A0
         _DisposPtr
         BSR     wClose
.3       RTS
*--------------------------------
CloseSysWindow
         MOVE.L  whichWindow(A5),A0
         MOVE    windowKind(A0),-(SP)
         _CloseDeskAcc
         RTS
*--------------------------------
DoSave   CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,A3
         MOVE.L  wRefCon(A3),A4
Save     BSR     WatchCur
         BSR     DoWrite
         BNE.S   .0
         BSR     ArrowCur
         BRA.S   .1
.0       BSR     DosErr
.1       RTS
*--------------------------------
DoSaveAs CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,A3
         MOVE.L  wRefCon(A3),A4
SaveAs   LINK    A6,#-74
         MOVE    #104,-(SP)
         MOVE    #089,-(SP)
         PEA     .10(PC)
         PEA     Name(A4)
         CLR.L   -(SP)
         PEA     -74(A6)
         MOVE    #sfPutFile,-(SP)
         _Pack3
         TST.B   -74+rGood(A6)
         BEQ.S   .1
         BSR     WatchCur
         BSR     Refresh
         MOVE    -74+rVolume(A6),Volume(A4)
         MOVE    -74+rVersion(A6),Version(A4)
         LEA     -74+rName(A6),A0
         BSR     CopyName
         BSR     DoCreate
         BNE.S   .0
         BSR     wUpdt
         BSR     ArrowCur
         BRA.S   .1
.0       BSR     DosErr
.1       UNLK    A6
         RTS
.10      STR     "Save document as:"
         ADJST
*--------------------------------
DoRevert CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,A3
         MOVE.L  wRefCon(A3),A4
         MOVE    #-1,ACount
         CLR     -(SP)
         MOVE    #130,-(SP)
         CLR.L   -(SP)
         _CautionAlert
         MOVE    (SP)+,D0
         CMP     #1,D0
         BNE.S   .1
         BSR     WatchCur
         BSR     Refresh
         BSR     DoRead
         BNE.S   .0
         BSR     wUpdt
         BSR     ArrowCur
         BRA.S   .1
.0       BSR     DosErr
.1       RTS
*--------------------------------
DoQuit   ST      Quitting(A5)
         RTS
*--------------------------------
MnuEdit  MOVE    MenuItem(A5),D0
         BEQ.S   .0
         SUBQ    #1,D0
         CLR.B   -(SP)
         MOVE    D0,-(SP)
         _SysEdit
         TST.B   (SP)+
.0       RTS
*--------------------------------
SysEvnt  PEA     EventRecord(A5)
         MOVE.L  whichWindow(A5),-(SP)
         _SystemClick
         RTS
*--------------------------------
DoCntnt  CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,A0
         CMP.L   whichWindow(A5),A0
         BEQ.S   .0
         MOVE.L  whichWindow(A5),-(SP)
         _SelectWindow
         RTS
.0       MOVE.L  whichWindow(A5),-(SP)
         _SetPort
         MOVE.L  whichWindow(A5),A3
         MOVE.L  wRefCon(A3),A4
         MOVE.L  EventRecord+evtMouse(A5),Where(A5)
         PEA     Where(A5)
         _GlobalToLocal
         LEA     B0rec(PC),A2
         BSR     TracKey
         BEQ.S   .1
         TST.B   D7
         BNE     DoLine
         RTS
.1       LEA     B1rec(PC),A2
         BSR     TrackIcn
         BEQ.S   .2
         TST.B   D7
         BNE     DoCom
         RTS
.2       LEA     B2rec(PC),A2
         BSR     TrackIcn
         BEQ.S   .3
         TST.B   D7
         BNE     DoTerm
         RTS
.3       LEA     B3rec(PC),A2
         BSR     TrackIcn
         BEQ.S   .4
         TST.B   D7
         BNE     DoPhone
         RTS
.4       LEA     B4rec(PC),A2
         BSR     TrackIcn
         BEQ.S   .5
         TST.B   D7
         BNE     DoTrans
.5       RTS
*--------------------------------
DoDrag   LINK    A6,#-8
         MOVE.L  WMgrPort,A0
         MOVE.L  portBounds+topLeft(A0),-8+topLeft(A6)
         MOVE.L  portBounds+botRight(A0),-8+botRight(A6)
         TST     ROM85
         BMI.S   .0
         MOVE    MBarHeight,D0
         BNE.S   .1
.0       MOVEQ   #20,D0
.1       ADD     D0,-8+top(A6)
         PEA     -8(A6)
         MOVE.L  #$00040004,-(SP)
         _InsetRect
         MOVE.L  whichWindow(A5),-(SP)
         MOVE.L  EventRecord+evtMouse(A5),-(SP)
         PEA     -8(A6)
         _DragWindow
         MOVE.L  whichWindow(A5),A3
         MOVE.L  wRefCon(A3),A4
         ST      Dirty(A4)
         UNLK    A6
         RTS
*--------------------------------
DoGoAwy  CLR.B   -(SP)
         MOVE.L  whichWindow(A5),-(SP)
         MOVE.L  EventRecord+evtMouse(A5),-(SP)
         _TrackGoAway
         TST.B   (SP)+
         BEQ.S   .0
         BSR     CloseAppWindow
.0       RTS
*--------------------------------
DoUpdate MOVE.L  EventRecord+evtMessage(A5),whichWindow(A5)
         MOVE.L  whichWindow(A5),-(SP)
         _BeginUpdate
         MOVE.L  whichWindow(A5),-(SP)
         _SetPort
         MOVE.L  whichWindow(A5),A0
         PEA     portRect(A0)
         _EraseRect
         LEA     B1rec(PC),A2
         BSR     PlotIcn
         LEA     B2rec(PC),A2
         BSR     PlotIcn
         LEA     B3rec(PC),A2
         BSR     PlotIcn
         LEA     B4rec(PC),A2
         BSR     PlotIcn
         LEA     B0rec(PC),A2
         BSR     PlotKey
         MOVE.L  whichWindow(A5),-(SP)
         _EndUpdate
         RTS
B1rec    DATA    /008,/008,/040,/040,/200
B2rec    DATA    /008,/048,/040,/080,/201
B3rec    DATA    /008,/088,/040,/120,/202
B4rec    DATA    /008,/128,/040,/160,/203
B0rec    DATA    /048,/008,/067,/160
         STR     "On-Line"
         ADJST
*--------------------------------
DoDisk   TST     EventRecord+evtMessage(A5)
         BEQ.S   .0
         CLR     -(SP)
         MOVE    #100,-(SP)
         MOVE    #100,-(SP)
         MOVE.L  EventRecord+evtMessage(A5),-(SP)
         PACK    diBadMount,2
         TST     (SP)+
.0       RTS
*--------------------------------
DoCom    LINK    A6,#-12
         CLR.L   -(SP)
         MOVE    #200,-(SP)
         CLR.L   -(SP)
         MOVE.L  MinusOne,-(SP)
         _GetNewDialog
         MOVE.L  (SP)+,D7
         LEA     -10(A6),A0
         MOVE    cBaud(A4),(A0)
         ADDQ    #3,(A0)+
         MOVE    cData(A4),(A0)
         ADD     #13,(A0)+
         MOVE    cStop(A4),(A0)
         ADD     #17,(A0)+
         MOVE    cPrty(A4),(A0)
         ADD     #20,(A0)+
         MOVE    cHshk(A4),(A0)
         ADD     #23,(A0)
         MOVE    -10(A6),D6
         BSR     SetCtrl
         MOVE    -8(A6),D6
         BSR     SetCtrl
         MOVE    -6(A6),D6
         BSR     SetCtrl
         MOVE    -4(A6),D6
         BSR     SetCtrl
         MOVE    -2(A6),D6
         BSR     SetCtrl
         MOVE.L  D7,-(SP)
         _ShowWindow
.0       CLR.L   -(SP)
         PEA     -12(A6)
         _ModalDialog
         MOVE    -12(A6),D0
         CMP     #1,D0
         BNE.S   .1
         MOVE.L  D7,-(SP)
         _DisposDialog
         LEA     -10(A6),A0
         SUBQ    #3,(A0)
         MOVE    (A0)+,cBaud(A4)
         SUB     #13,(A0)
         MOVE    (A0)+,cData(A4)
         SUB     #17,(A0)
         MOVE    (A0)+,cStop(A4)
         SUB     #20,(A0)
         MOVE    (A0)+,cPrty(A4)
         SUB     #23,(A0)
         MOVE    (A0),cHshk(A4)
         ST      Dirty(A4)
         UNLK    A6
         RTS
.1       CMP     #2,D0
         BNE.S   .2
         MOVE.L  D7,-(SP)
         _DisposDialog
         UNLK    A6
         RTS
.2       CMP     #12,D0
         BHI.S   .3
         MOVE    -10(A6),D6
         MOVE    D0,-10(A6)
         BRA.S   .7
.3       CMP     #16,D0
         BHI.S   .4
         MOVE    -8(A6),D6
         MOVE    D0,-8(A6)
         BRA.S   .7
.4       CMP     #19,D0
         BHI.S   .5
         MOVE    -6(A6),D6
         MOVE    D0,-6(A6)
         BRA.S   .7
.5       CMP     #22,D0
         BHI.S   .6
         MOVE    -4(A6),D6
         MOVE    D0,-4(A6)
         BRA.S   .7
.6       CMP     #24,D0
         BHI     .0
         MOVE    -2(A6),D6
         MOVE    D0,-2(A6)
.7       BSR     RstCtrl
         MOVE    -12(A6),D6
         BSR     SetCtrl
         BRA     .0
*--------------------------------
DoTerm   LINK    A6,#-14
         CLR.L   -(SP)
         MOVE    #201,-(SP)
         CLR.L   -(SP)
         MOVE.L  MinusOne,-(SP)
         _GetNewDialog
         MOVE.L  (SP)+,D7
         LEA     -12(A6),A0
         MOVE    tMode(A4),(A0)
         ADDQ    #3,(A0)+
         MOVE    tBcks(A4),(A0)
         ADDQ    #5,(A0)+
         MOVE    tKpad(A4),(A0)
         ADDQ    #7,(A0)+
         MOVE    tEcho(A4),(A0)+
         MOVE    tLine(A4),(A0)+
         MOVE    tWrap(A4),(A0)
         MOVE    -12(A6),D6
         BSR     SetCtrl
         MOVE    -10(A6),D6
         BSR     SetCtrl
         MOVE    -8(A6),D6
         BSR     SetCtrl
         MOVEQ   #9,D6
         MOVE    -6(A6),D5
         BSR     ValCtrl
         MOVEQ   #10,D6
         MOVE    -4(A6),D5
         BSR     ValCtrl
         MOVEQ   #11,D6
         MOVE    -2(A6),D5
         BSR     ValCtrl
         MOVE.L  D7,-(SP)
         _ShowWindow
.0       CLR.L   -(SP)
         PEA     -14(A6)
         _ModalDialog
         MOVE    -14(A6),D0
         CMP     #1,D0
         BNE.S   .1
         MOVE.L  D7,-(SP)
         _DisposDialog
         LEA     -12(A6),A0
         SUBQ    #3,(A0)
         MOVE    (A0)+,tMode(A4)
         SUBQ    #5,(A0)
         MOVE    (A0)+,tBcks(A4)
         SUBQ    #7,(A0)
         MOVE    (A0)+,tKpad(A4)
         MOVE    (A0)+,tEcho(A4)
         MOVE    (A0)+,tLine(A4)
         MOVE    (A0),tWrap(A4)
         ST      Dirty(A4)
         UNLK    A6
         RTS
.1       CMP     #2,D0
         BNE.S   .2
         MOVE.L  D7,-(SP)
         _DisposDialog
         UNLK    A6
         RTS
.2       CMP     #4,D0
         BHI.S   .3
         MOVE    -12(A6),D6
         MOVE    D0,-12(A6)
         BRA.S   .5
.3       CMP     #6,D0
         BHI.S   .4
         MOVE    -10(A6),D6
         MOVE    D0,-10(A6)
         BRA.S   .5
.4       CMP     #8,D0
         BHI.S   .6
         MOVE    -8(A6),D6
         MOVE    D0,-8(A6)
.5       BSR     RstCtrl
         MOVE    -14(A6),D6
         BSR     SetCtrl
         BRA     .0
.6       CMP     #9,D0
         BNE.S   .7
         EOR     #1,-6(A6)
         MOVE    -6(A6),D5
         BRA.S   .9
.7       CMP     #10,D0
         BNE.S   .8
         EOR     #1,-4(A6)
         MOVE    -4(A6),D5
         BRA.S   .9
.8       CMP     #11,D0
         BNE     .0
         EOR     #1,-2(A6)
         MOVE    -2(A6),D5
.9       MOVE    -14(A6),D6
         BSR     ValCtrl
         BRA     .0
*--------------------------------
DoPhone  LINK    A6,#-276
         CLR.L   -(SP)
         MOVE    #202,-(SP)
         CLR.L   -(SP)
         MOVE.L  MinusOne,-(SP)
         _GetNewDialog
         MOVE.L  (SP)+,D7
         LEA     -260(A6),A0
         MOVE    #3,(A0)+
         MOVE    #11,(A0)
         MOVE    -260(A6),D6
         BSR     SetCtrl
         MOVE    -258(A6),D6
         BSR     SetCtrl
         BSR.S   .10
         MOVE.L  D7,-(SP)
         _ShowWindow
.0       CLR.L   -(SP)
         PEA     -276(A6)
         _ModalDialog
         MOVE    -276(A6),D0
         CMP     #1,D0
         BNE.S   .1
         BSR     .20
         MOVE.L  D7,-(SP)
         _DisposDialog
         UNLK    A6
         RTS
.1       CMP     #2,D0
         BNE.S   .2
         MOVE.L  D7,-(SP)
         _DisposDialog
         UNLK    A6
         RTS
.2       CMP     #10,D0
         BHI.S   .3
         BSR     .20
         MOVE    -260(A6),D6
         MOVE    -276(A6),-260(A6)
         BRA.S   .4
.3       CMP     #15,D0
         BHI.S   .0
         BSR     .20
         MOVE    -258(A6),D6
         MOVE    -276(A6),-258(A6)
.4       BSR     RstCtrl
         MOVE    -276(A6),D6
         BSR     SetCtrl
         BSR.S   .10
         BRA.S   .0
.10      MOVE    -260(A6),D0
         SUBQ    #3,D0
         MOVE    -258(A6),D4
         SUB     #11,D4
         LSL     #3,D4
         OR      D0,D4
         MOVE.L  D7,-(SP)
         MOVE    #16,-(SP)
         CLR.L   -(SP)
         _SelIText
         MOVE.L  D7,-(SP)
         MOVE    #17,-(SP)
         PEA     -274(A6)
         PEA     -272(A6)
         PEA     -268(A6)
         _GetDItem
         LEA     pKeys(A4),A0
         LSL     #4,D4
         MOVE.L  -272(A6),-(SP)
         PEA     0(A0,D4)
         _SetIText
         LEA     pText(A4),A0
         LSL     #2,D4
         ADD     D4,A0
         LEA     -256(A6),A1
         BSR     .30
         MOVE.L  D7,-(SP)
         MOVE    #16,-(SP)
         PEA     -274(A6)
         PEA     -272(A6)
         PEA     -268(A6)
         _GetDItem
         MOVE.L  -272(A6),-(SP)
         PEA     -256(A6)
         _SetIText
         RTS
.20      MOVE    -260(A6),D0
         SUBQ    #3,D0
         MOVE    -258(A6),D4
         SUB     #11,D4
         LSL     #3,D4
         OR      D0,D4
         MOVE.L  D7,-(SP)
         MOVE    #17,-(SP)
         PEA     -274(A6)
         PEA     -272(A6)
         PEA     -268(A6)
         _GetDItem
         MOVE.L  -272(A6),-(SP)
         PEA     -256(A6)
         _GetIText
         LEA     -256(A6),A0
         CMP.B   #15,(A0)
         BLS.S   .21
         MOVE.B  #15,(A0)
.21      LEA     pKeys(A4),A1
         LSL     #4,D4
         ADD     D4,A1
         BSR     CopyStr
         MOVE.L  D7,-(SP)
         MOVE    #16,-(SP)
         PEA     -274(A6)
         PEA     -272(A6)
         PEA     -268(A6)
         _GetDItem
         MOVE.L  -272(A6),-(SP)
         PEA     -256(A6)
         _GetIText
         LEA     -256(A6),A0
         LEA     pText(A4),A1
         LSL     #2,D4
         ADD     D4,A1
         BSR     .40
         ST      Dirty(A4)
         RTS
.30      CLR     D0
         MOVE.B  (A0)+,D0
         CLR     D1
         BRA.S   .35
.31      MOVE.B  (A0)+,D2
         CMP.B   #$20,D2
         BHS.S   .32
         OR.B    #$40,D2
         BRA.S   .33
.32      CMP.B   #$7F,D2
         BNE.S   .34
         MOVEQ   #'?,D2
.33      MOVE.B  #'^,1(A1,D1)
         ADDQ    #1,D1
.34      MOVE.B  D2,1(A1,D1)
         ADDQ    #1,D1
.35      DBRA    D0,.31
         MOVE.B  D1,(A1)
         RTS
.40      CLR     D0
         MOVE.B  (A0)+,D0
         CLR     D1
         BRA.S   .46
.41      MOVE.B  (A0)+,D2
         CMP.B   #'^,D2
         BNE.S   .45
         TST     D0
         BEQ.S   .45
         MOVE.B  (A0),D3
         CMP.B   #$7F,D3
         BHI.S   .45
         CMP.B   #$60,D3
         BLO.S   .42
         AND.B   #$5F,D3
.42      CMP.B   #$3F,D3
         BLO.S   .45
         BNE.S   .43
         MOVEQ   #$7F,D3
         BRA.S   .44
.43      AND.B   #$3F,D3
.44      MOVE.B  D3,D2
         ADDQ.L  #1,A0
         SUBQ    #1,D0
.45      MOVE.B  D2,1(A1,D1)
         ADDQ    #1,D1
         CMP     #63,D1
         BHS.S   .47
.46      DBRA    D0,.41
.47      MOVE.B  D1,(A1)
         RTS
*--------------------------------
DoTrans  LINK    A6,#-286
         CLR.L   -(SP)
         MOVE    #203,-(SP)
         CLR.L   -(SP)
         MOVE.L  MinusOne,-(SP)
         _GetNewDialog
         MOVE.L  (SP)+,D7
         LEA     -270(A6),A0
         MOVE    xMode(A4),(A0)
         ADDQ    #3,(A0)+
         MOVE    xChar(A4),(A0)+
         MOVE    xCdly(A4),(A0)+
         MOVE    xLdly(A4),(A0)+
         MOVE    xMbin(A4),(A0)+
         MOVE    xTrbo(A4),(A0)+
         MOVE    xCRC(A4),(A0)
         MOVE    -270(A6),D6
         BSR     SetCtrl
         MOVEQ   #5,D6
         MOVE    -268(A6),D5
         BSR     .20
         MOVEQ   #6,D6
         MOVE    -266(A6),D5
         BSR     .40
         MOVEQ   #7,D6
         MOVE    -264(A6),D5
         BSR     .40
         MOVEQ   #8,D6
         MOVE    -262(A6),D5
         BSR     ValCtrl
         MOVEQ   #9,D6
         MOVE    -260(A6),D5
         BSR     ValCtrl
         MOVEQ   #10,D6
         MOVE    -258(A6),D5
         BSR     ValCtrl
         MOVEQ   #15,D6
         BSR     UserItem
         MOVE.L  D7,-(SP)
         _ShowWindow
.0       CLR.L   -(SP)
         PEA     -286(A6)
         _ModalDialog
         MOVE    -286(A6),D0
         CMP     #1,D0
         BNE.S   .1
         MOVEQ   #5,D6
         BSR     .30
         MOVE    D5,-268(A6)
         MOVEQ   #6,D6
         BSR     .50
         MOVE    D5,-266(A6)
         MOVEQ   #7,D6
         BSR     .50
         MOVE    D5,-264(A6)
         MOVE.L  D7,-(SP)
         _DisposDialog
         LEA     -270(A6),A0
         SUBQ    #3,(A0)
         MOVE    (A0)+,xMode(A4)
         MOVE    (A0)+,xChar(A4)
         MOVE    (A0)+,xCdly(A4)
         MOVE    (A0)+,xLdly(A4)
         MOVE    (A0)+,xMbin(A4)
         MOVE    (A0)+,xTrbo(A4)
         MOVE    (A0),xCRC(A4)
         ST      Dirty(A4)
         UNLK    A6
         RTS
.1       CMP     #2,D0
         BNE.S   .2
         MOVE.L  D7,-(SP)
         _DisposDialog
         UNLK    A6
         RTS
.2       CMP     #4,D0
         BHI.S   .3
         MOVE    -270(A6),D6
         MOVE    D0,-270(A6)
         BSR     RstCtrl
         MOVE    -286(A6),D6
         BSR     SetCtrl
         BRA     .0
.3       CMP     #8,D0
         BNE.S   .4
         EOR     #1,-262(A6)
         MOVE    -262(A6),D5
         BRA.S   .6
.4       CMP     #9,D0
         BNE.S   .5
         EOR     #1,-260(A6)
         MOVE    -260(A6),D5
         BRA.S   .6
.5       CMP     #10,D0
         BNE     .0
         EOR     #1,-258(A6)
         MOVE    -258(A6),D5
.6       MOVE    -286(A6),D6
         BSR     ValCtrl
         BRA     .0
.20      LEA     -256(A6),A0
         BSR     .60
         MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         PEA     -284(A6)
         PEA     -282(A6)
         PEA     -278(A6)
         _GetDItem
         MOVE.L  -282(A6),-(SP)
         PEA     -256(A6)
         _SetIText
         RTS
.30      MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         PEA     -284(A6)
         PEA     -282(A6)
         PEA     -278(A6)
         _GetDItem
         MOVE.L  -282(A6),-(SP)
         PEA     -256(A6)
         _GetIText
         LEA     -256(A6),A0
         BSR     .70
         RTS
.40      CLR.L   D0
         LEA     -256(A6),A0
         MOVE    D5,D0
         MOVE    #numToString,-(SP)
         _Pack7
         MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         PEA     -284(A6)
         PEA     -282(A6)
         PEA     -278(A6)
         _GetDItem
         MOVE.L  -282(A6),-(SP)
         PEA     -256(A6)
         _SetIText
         RTS
.50      MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         PEA     -284(A6)
         PEA     -282(A6)
         PEA     -278(A6)
         _GetDItem
         MOVE.L  -282(A6),-(SP)
         PEA     -256(A6)
         _GetIText
         LEA     -256(A6),A0
         MOVE    #stringToNum,-(SP)
         _Pack7
         MOVE    D0,D5
         RTS
.60      CLR     D0
         TST     D5
         BEQ.S   .63
         CMP.B   #$20,D5
         BLO.S   .61
         CMP.B   #$7F,D5
         BNE.S   .62
         MOVEQ   #'?-$40,D5
.61      ADD.B   #$40,D5
         MOVE.B  #'^,1(A0,D0)
         ADDQ    #1,D0
.62      MOVE.B  D5,1(A0,D0)
         ADDQ    #1,D0
.63      MOVE.B  D0,(A0)
         RTS
.70      CLR     D5
         MOVE.B  (A0)+,D0
         BEQ.S   .73
         MOVE.B  (A0)+,D5
         CMP.B   #'^,D5
         BNE.S   .73
         SUBQ.B  #1,D0
         BEQ.S   .73
         MOVE.B  (A0),D0
         CMP.B   #$7F,D0
         BHI.S   .73
         CMP.B   #$60,D0
         BLO.S   .71
         SUB.B   #$20,D0
.71      CMP.B   #$3F,D0
         BLO.S   .73
         BNE.S   .72
         MOVEQ   #$7F+$40,D0
.72      SUB.B   #$40,D0
         MOVE.B  D0,D5
.73      RTS
*--------------------------------
RstCtrl  MOVEQ   #0,D5
         BRA.S   ValCtrl
SetCtrl  MOVEQ   #1,D5
ValCtrl  LINK    A6,#-14
         MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         PEA     -14(A6)
         PEA     -12(A6)
         PEA     -8(A6)
         _GetDItem
         MOVE.L  -12(A6),-(SP)
         MOVE    D5,-(SP)
         _SetCtlValue
         UNLK    A6
         RTS
*--------------------------------
UserItem LINK    A6,#-14
         MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         PEA     -14(A6)
         PEA     -12(A6)
         PEA     -8(A6)
         _GetDItem
         MOVE.L  D7,-(SP)
         MOVE    D6,-(SP)
         MOVE    -14(A6),-(SP)
         PEA     MyItem(PC)
         PEA     -8(A6)
         _SetDItem
         UNLK    A6
         RTS
*--------------------------------
MyItem   LINK    A6,#-14
         MOVE.L  10(A6),-(SP)
         MOVE    8(A6),-(SP)
         PEA     -14(A6)
         PEA     -12(A6)
         PEA     -8(A6)
         _GetDItem
         MOVE.L  (A5),A0
         PEA     -8(A6)
         PEA     gray(A0)
         _FillRect
         UNLK    A6
         MOVE.L  (SP)+,A0
         ADDQ.L  #6,A7
         JMP     (A0)
*--------------------------------
TrackIcn CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         MOVE.L  A2,-(SP)
         _PtInRect
         TST.B   (SP)+
         BEQ.S   .5
         SF      D7
.0       PEA     Where(A5)
         _GetMouse
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         MOVE.L  A2,-(SP)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .1
         TST.B   D7
         BNE.S   .2
         BRA.S   .3
.1       TST.B   D7
         BNE.S   .3
.2       BSR     InverIcn
         NOT.B   D7
.3       CLR.B   -(SP)
         _WaitMouseUp
         TST.B   (SP)+
         BNE.S   .0
         TST.B   D7
         BEQ.S   .4
         BSR     InverIcn
.4       MOVEQ   #-1,D0
.5       RTS
*--------------------------------
PlotIcn  CLR.L   -(SP)
         MOVE.L  #$49434E23,-(SP)        ;"ICN#"
         MOVE    8(A2),-(SP)
         _GetResource
         MOVE.L  (SP)+,D0
         BEQ.S   .0
         MOVE.L  D0,A0
         LEA     IconBitmap,A1
         MOVE.L  (A0),(A1)+
         MOVE    #4,(A1)+
         CLR.L   (A1)+
         MOVE.L  #$00200020,(A1)
         LEA     IconBitmap,A1
         MOVE.L  A1,-(SP)
         MOVE.L  (A5),A0
         MOVE.L  (A0),A0
         PEA     portBits(A0)
         PEA     bounds(A1)
         MOVE.L  A2,-(SP)
         CLR     -(SP)
         CLR.L   -(SP)
         _CopyBits
.0       RTS
*--------------------------------
InverIcn CLR.L   -(SP)
         MOVE.L  #$49434E23,-(SP)        ;"ICN#"
         MOVE    8(A2),-(SP)
         _GetResource
         MOVE.L  (SP)+,D0
         BEQ.S   .0
         MOVE.L  D0,A0
         MOVE.L  (A0),A0
         ADD     #128,A0
         LEA     IconBitmap,A1
         MOVE.L  A0,(A1)+
         MOVE    #4,(A1)+
         CLR.L   (A1)+
         MOVE.L  #$00200020,(A1)
         LEA     IconBitmap,A1
         MOVE.L  A1,-(SP)
         MOVE.L  (A5),A0
         MOVE.L  (A0),A0
         PEA     portBits(A0)
         PEA     bounds(A1)
         MOVE.L  A2,-(SP)
         MOVE    #srcXor,-(SP)
         CLR.L   -(SP)
         _CopyBits
.0       RTS
*--------------------------------
TracKey  CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         MOVE.L  A2,-(SP)
         _PtInRect
         TST.B   (SP)+
         BEQ.S   .5
         SF      D7
.0       PEA     Where(A5)
         _GetMouse
         CLR.B   -(SP)
         MOVE.L  Where(A5),-(SP)
         MOVE.L  A2,-(SP)
         _PtInRect
         TST.B   (SP)+
         BNE.S   .1
         TST.B   D7
         BNE.S   .2
         BRA.S   .3
.1       TST.B   D7
         BNE.S   .3
.2       BSR     InverKey
         NOT.B   D7
.3       CLR.B   -(SP)
         _WaitMouseUp
         TST.B   (SP)+
         BNE.S   .0
         TST.B   D7
         BEQ.S   .4
         BSR     InverKey
.4       MOVEQ   #-1,D0
.5       RTS
*--------------------------------
PlotKey  MOVE.L  A2,-(SP)
         MOVE.L  #$00040004,-(SP)
         _FrameRoundRect
         CLR     -(SP)
         PEA     8(A2)
         _StringWidth
         MOVE    6(A2),D0
         SUB     2(A2),D0
         SUB     (SP)+,D0
         ASR     #1,D0
         ADD     2(A2),D0
         MOVE    D0,-(SP)
         MOVE    (A2),D0
         ADD     #14,D0
         MOVE    D0,-(SP)
         _MoveTo
         PEA     8(A2)
         _DrawString
         RTS
*--------------------------------
InverKey LINK    A6,#-8
         MOVE.L  (A2),-8(A6)
         MOVE.L  4(A2),-4(A6)
         PEA     -8(A6)
         MOVE.L  #$00010001,-(SP)
         _InsetRect
         PEA     -8(A6)
         _InverRect
         UNLK    A6
         RTS
*--------------------------------
DoInit   MOVE    wCount(A5),D0
         MULU    #20,D0
         ADD     #16,D0
         MOVE    D0,wCoord+h(A4)
         ADD     #39,D0
         MOVE    D0,wCoord+v(A4)
         MOVE    #5,cBaud(A4)
         MOVE    #3,cData(A4)
         MOVE    #0,cStop(A4)
         MOVE    #0,cPrty(A4)
         MOVE    #1,cHshk(A4)
         MOVE    #0,tMode(A4)
         MOVE    #0,tBcks(A4)
         MOVE    #0,tKpad(A4)
         MOVE    #0,tEcho(A4)
         MOVE    #0,tLine(A4)
         MOVE    #0,tWrap(A4)
         MOVE    #0,xMode(A4)
         MOVE    #13,xChar(A4)
         MOVE    #0,xCdly(A4)
         MOVE    #0,xLdly(A4)
         MOVE    #1,xMbin(A4)
         MOVE    #0,xTrbo(A4)
         MOVE    #1,xCRC(A4)
         SF      Saved(A4)
         SF      Dirty(A4)
         RTS
*--------------------------------
DoCreate LINK    A6,#-80
         MOVE.L  portBits+bounds+topLeft(A3),wCoord(A4)
         NEG     wCoord+v(A4)
         NEG     wCoord+h(A4)
         LEA     -80(A6),A0
         LEA     Name(A4),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    Volume(A4),ioVRefNum(A0)
         MOVE.B  Version(A4),ioVersNum(A0)
         _Create
         MOVE    ioResult(A0),D0
         BEQ.S   .0
         CMP     #dupFNErr,D0
         BNE     .3
.0       MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .2
         LEA     wCoord(A4),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #PrivSize-wCoord,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE.S   .1
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .1
         CLR     ioFDirIndex(A0)
         _GetFileInfo
         MOVE    ioResult(A0),D0
         BNE.S   .2
         MOVE.L  #$54533030,ioFlFndrInfo+fdType(A0)      ;"TS00"
         MOVE.L  #$54533030,ioFlFndrInfo+fdCreator(A0)   ;"TS00"
         _SetFileInfo
         MOVE    ioResult(A0),D0
         BNE.S   .2
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE.S   .3
         ST      Saved(A4)
         SF      Dirty(A4)
         BRA.S   .3
.1       MOVE    D0,-(SP)
         _Close
         MOVE    (SP)+,D0
.2       MOVE    D0,-(SP)
         _Delete
         MOVE    (SP)+,D0
.3       UNLK    A6
         TST     D0
         RTS
*--------------------------------
DoWrite  LINK    A6,#-80
         MOVE.L  portBits+bounds+topLeft(A3),wCoord(A4)
         NEG     wCoord+v(A4)
         NEG     wCoord+h(A4)
         LEA     -80(A6),A0
         LEA     Name(A4),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    Volume(A4),ioVRefNum(A0)
         MOVE.B  Version(A4),ioVersNum(A0)
         MOVE.B  #fsWrPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .1
         LEA     wCoord(A4),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #PrivSize-wCoord,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Write
         MOVE    ioResult(A0),D0
         BNE.S   .0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .0
         _FlushVol
         MOVE    ioResult(A0),D0
         BNE.S   .1
         ST      Saved(A4)
         SF      Dirty(A4)
         BRA.S   .1
.0       MOVE    D0,-(SP)
         _Close
         MOVE    (SP)+,D0
.1       UNLK    A6
         TST     D0
         RTS
*--------------------------------
DoRead   LINK    A6,#-80
         LEA     -80(A6),A0
         LEA     Name(A4),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    Volume(A4),ioVRefNum(A0)
         MOVE.B  Version(A4),ioVersNum(A0)
         MOVE.B  #fsRdPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         _Open
         MOVE    ioResult(A0),D0
         BNE.S   .1
         LEA     wCoord(A4),A1
         MOVE.L  A1,ioBuffer(A0)
         MOVE.L  #PrivSize-wCoord,ioReqCount(A0)
         CLR     ioPosMode(A0)
         _Read
         MOVE    ioResult(A0),D0
         BNE.S   .0
         _Close
         MOVE    ioResult(A0),D0
         BNE.S   .0
         ST      Saved(A4)
         SF      Dirty(A4)
         BRA.S   .1
.0       MOVE    D0,-(SP)
         _Close
         MOVE    (SP)+,D0
.1       UNLK    A6
         TST     D0
         RTS
*--------------------------------
wOpen    CLR.L   -(SP)
         MOVE    #128,-(SP)
         CLR.L   -(SP)
         MOVE.L  MinusOne,-(SP)
         _GetNewWindow
         MOVE.L  (SP)+,A3
         MOVE    #0,txFont(A3)
         MOVE    #12,txSize(A3)
         MOVE.L  A4,wRefCon(A3)
         ADDQ    #1,wCount(A5)
wUpdt    MOVE.L  A3,-(SP)
         PEA     Name(A4)
         _SetWTitle
         MOVE.L  A3,-(SP)
         MOVE.L  wCoord(A4),-(SP)
         SF      -(SP)
         _MoveWindow
         MOVE.L  A3,-(SP)
         _ShowWindow
         RTS
wClose   MOVE.L  A3,-(SP)
         _DisposWindow
         SUBQ    #1,wCount(A5)
         RTS
*--------------------------------
Refresh  CLR.B   -(SP)
         MOVE    #$0140,-(SP)
         PEA     EventRecord(A5)
         _GetNextEvent
         TST.B   (SP)+
         BEQ.S   .0
         MOVE    EventRecord+evtNum(A5),D0
         CMP     #6,D0
         BNE.S   Refresh
         BSR     DoUpdate
         BRA.S   Refresh
.0       RTS
*--------------------------------
CopyName LEA     Name(A4),A1
CopyStr  CLR     D0
         MOVE.B  (A0),D0
.0       MOVE.B  (A0)+,(A1)+
         DBRA    D0,.0
         RTS
*--------------------------------
DosErr   LEA     TErr(PC),A0
.0       MOVE    (A0)+,D1
         BEQ.S   .1
         CMP     D0,D1
         BEQ.S   .1
         ADD     (A0)+,A0
         BRA.S   .0
.1       PEA     2(A0)
         CLR.L   -(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         _ParamText
         BSR     ArrowCur
         MOVE    #-1,ACount
         CLR     -(SP)
         MOVE    #131,-(SP)
         CLR.L   -(SP)
         _StopAlert
         TST     (SP)+
         RTS
*--------------------------------
ESTR     MACRO
         DATA    /]1,/:1-:0
:0       STR     "]2"
         ADJST
:1
         ENDM
*--------------------------------
TErr     ESTR    -33,"Directory full"
         ESTR    -34,"Disk full"
         ESTR    -35,"No such volume"
         ESTR    -36,"Disk I/O"
         ESTR    -39,"End of file"
         ESTR    -43,"File not found"
         ESTR    -44,"Write protected diskette"
         ESTR    -45,"File locked"
         ESTR    -46,"Volume locked"
         ESTR    -47,"File busy"
         ESTR    -97,"Port already in use"
         ESTR    -98,"Port not configured"
         ESTR   -108,"Not enough room in heap zone"
         ESTR      3,"Bad name"
         ESTR      2,"Cancel"
         ESTR      1,"End Of Text"
         ESTR      0,"Unknown"
*--------------------------------
SetUpMenus
         CLR.L   -(SP)
         MOVE    #AppleID,-(SP)
         _GetRMenu
         MOVE.L  (SP),-(SP)
         MOVE.L  #$44525652,-(SP)        ;"DRVR"
         _AddResMenu
         CLR     -(SP)
         _InsertMenu
         CLR.L   -(SP)
         MOVE    #FileID,-(SP)
         _GetRMenu
         CLR     -(SP)
         _InsertMenu
         CLR.L   -(SP)
         MOVE    #EditID,-(SP)
         _GetRMenu
         CLR     -(SP)
         _InsertMenu
         _DrawMenuBar
         RTS
*--------------------------------
UpdMenus CLR.L   -(SP)
         _FrontWindow
         MOVE.L  (SP)+,D0
         BNE.S   .0
         CLR.L   -(SP)
         MOVE    #FileID,-(SP)
         _GetMHandle
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE    #CloseItem,-(SP)
         _DisableItem
         MOVE    #SaveItem,-(SP)
         _DisableItem
         MOVE    #SaveAsItem,-(SP)
         _DisableItem
         MOVE    #RevertItem,-(SP)
         _DisableItem
         BRA     .4
.0       MOVE.L  D0,A0
         TST     windowKind(A0)
         BPL.S   .1
         CLR.L   -(SP)
         MOVE    #FileID,-(SP)
         _GetMHandle
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE    #CloseItem,-(SP)
         _EnableItem
         MOVE    #SaveItem,-(SP)
         _DisableItem
         MOVE    #SaveAsItem,-(SP)
         _DisableItem
         MOVE    #RevertItem,-(SP)
         _DisableItem
         BRA     .5
.1       MOVE.L  wRefCon(A0),A0
         TST.B   Saved(A0)
         BEQ.S   .2
         TST.B   Dirty(A0)
         BNE.S   .3
.2       CLR.L   -(SP)
         MOVE    #FileID,-(SP)
         _GetMHandle
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE    #CloseItem,-(SP)
         _EnableItem
         MOVE    #SaveItem,-(SP)
         _DisableItem
         MOVE    #SaveAsItem,-(SP)
         _EnableItem
         MOVE    #RevertItem,-(SP)
         _DisableItem
         BRA.S   .4
.3       CLR.L   -(SP)
         MOVE    #FileID,-(SP)
         _GetMHandle
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE    #CloseItem,-(SP)
         _EnableItem
         MOVE    #SaveItem,-(SP)
         _EnableItem
         MOVE    #SaveAsItem,-(SP)
         _EnableItem
         MOVE    #RevertItem,-(SP)
         _EnableItem
.4       CLR.L   -(SP)
         MOVE    #EditID,-(SP)
         _GetMHandle
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE    #UndoItem,-(SP)
         _DisableItem
         MOVE    #CutItem,-(SP)
         _DisableItem
         MOVE    #CopyItem,-(SP)
         _DisableItem
         MOVE    #PasteItem,-(SP)
         _DisableItem
         MOVE    #ClearItem,-(SP)
         _DisableItem
         RTS
.5       CLR.L   -(SP)
         MOVE    #EditID,-(SP)
         _GetMHandle
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE.L  (SP),-(SP)
         MOVE    #UndoItem,-(SP)
         _EnableItem
         MOVE    #CutItem,-(SP)
         _EnableItem
         MOVE    #CopyItem,-(SP)
         _EnableItem
         MOVE    #PasteItem,-(SP)
         _EnableItem
         MOVE    #ClearItem,-(SP)
         _EnableItem
         RTS
*--------------------------------
SetUpCursors
         CLR.L   -(SP)
         MOVE    #WatchCursor,-(SP)
         _GetCursor
         MOVE.L  (SP)+,Watch(A5)
         _InitCursor
         RTS
ArrowCur MOVE.L  (A5),A0
         PEA     arrow(A0)
         _SetCursor
         RTS
WatchCur MOVE.L  Watch(A5),D0
         BEQ.S   .0
         MOVE.L  D0,A0
         MOVE.L  (A0),-(SP)
         _SetCursor
.0       RTS
*--------------------------------
         INCLUDE "Term.Asm"
         INCLUDE ":Sources:PrintCalls.Asm"
         INCLUDE "SerDrvr.Asm"
         INCLUDE "VT100.Asm"
*--------------------------------
         ENDR
*================================
         INCLUDE "Resrc.Asm"
*================================
         END
