;SAVE"Resrc.Asm"
*--------------------------------
; TSpro Resources 1.3  (11/16/87)
*--------------------------------
         RSRC    MENU,128,resPreLoad
         DATA    /128
         DATA    /0,/0
         DATA    /0
         DATA    /0
         DATA    $FFFFFFFB
         HEX     0114
         STR     "About Telescape…"
         DATA    #0,#0,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    MENU,129,resPreLoad
         DATA    /129
         DATA    /0,/0
         DATA    /0
         DATA    /0
         DATA    $FFFFFE07
         STR     "File"
         STR     "New"
         DATA    #0,#'N,#0,#0
         STR     "Open…"
         DATA    #0,#'O,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Close"
         DATA    #0,#'W,#0,#0
         STR     "Save"
         DATA    #0,#'S,#0,#0
         STR     "Save As…"
         DATA    #0,#0,#0,#0
         STR     "Revert"
         DATA    #0,#0,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Quit"
         DATA    #0,#'Q,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    MENU,130,resPreLoad
         DATA    /130
         DATA    /0,/0
         DATA    /0
         DATA    /0
         DATA    $FFFFFF81
         STR     "Edit"
         STR     "Undo"
         DATA    #0,#'Z,#0,#0
         STR     "-"
         DATA    #0,#0,#0,#0
         STR     "Cut"
         DATA    #0,#'X,#0,#0
         STR     "Copy"
         DATA    #0,#'C,#0,#0
         STR     "Paste"
         DATA    #0,#'V,#0,#0
         STR     "Clear"
         DATA    #0,#0,#0,#0
         STR     ""
         ENDR
*--------------------------------
         RSRC    WIND,128,resPreLoad
         DATA    /000,/000,/075,/168
         DATA    /4
         DATA    #0,#0
         DATA    #1,#0
         DATA    0
         STR     ""
         ENDR
*--------------------------------
         RSRC    ALRT,128,resPreLoad
         DATA    /090,/105,/177,/400
         DATA    /128
         DATA    /$4444
         ENDR
*--------------------------------
         RSRC    DITL,128,resPreLoad
         DATA    /5-1
         DITM    4,60,14,76,78,"OK"
         DICN    32+128,10,30,42,62,128
         DITM    8+128,10,95,26,280,"Telescape Pro v1.3"
         DITM    8+128,35,95,51,280,"written by Yves Lempereur"
         DITM    8+128,60,95,76,280,"Copyright 1987, Mainstay"
         ENDR
*--------------------------------
         RSRC    ALRT,129,resPreLoad
         DATA    /100,/120,/210,/385
         DATA    /129
         DATA    /$5555
         ENDR
*--------------------------------
         RSRC    DITL,129,resPreLoad
         DATA    /4-1
         DITM    4,55,80,71,155,"Yes"
         DITM    4,85,170,101,245,"Cancel"
         DITM    4,85,80,101,155,"No"
         DITM    8+128,10,80,41,220,"Save changes before closing?"
         ENDR
*--------------------------------
         RSRC    ALRT,130,resPreLoad
         DATA    /100,/115,/181,/390
         DATA    /130
         DATA    /$5555
         ENDR
*--------------------------------
         RSRC    DITL,130,resPreLoad
         DATA    /3-1
         DITM    4,055,080,071,155,"OK"
         DITM    4,055,180,071,255,"Cancel"
         DITM    8+128,10,80,41,255,"Revert to the last version saved?"
         ENDR
*--------------------------------
         RSRC    ALRT,131,resPreLoad
         DATA    /100,/120,/185,/390
         DATA    /131
         DATA    /$5555
         ENDR
*--------------------------------
         RSRC    DITL,131,resPreLoad
         DATA    /2-1
         DITM    4,60,190,76,250,"OK"
         DITM    8+128,10,80,41,250,"^0 error."
         ENDR
*--------------------------------
         RSRC    DLOG,200,resPreLoad
         DATA    /060,/060,/210,/450
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /200
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,200,resPreLoad
         DATA    /30-1
         DITM    4,130,260,146,320,"OK"
         DITM    4,130,325,146,385,"Cancel"
         DITM    6,030,090,046,150,"50"
         DITM    6,030,150,046,210,"110"
         DITM    6,030,210,046,270,"300"
         DITM    6,030,270,046,330,"450"
         DITM    6,030,330,046,390,"600"
         DITM    6,050,090,066,150,"1200"
         DITM    6,050,150,066,210,"2400"
         DITM    6,050,210,066,270,"4800"
         DITM    6,050,270,066,330,"9600"
         DITM    6,050,330,066,390,"19200"
         DITM    6,070,090,086,150,"5"
         DITM    6,070,150,086,210,"6"
         DITM    6,070,210,086,270,"7"
         DITM    6,070,270,086,330,"8"
         DITM    6,090,090,106,150,"1"
         DITM    6,090,150,106,210,"1.5"
         DITM    6,090,210,106,270,"2"
         DITM    6,110,090,126,150,"None"
         DITM    6,110,150,126,210,"Even"
         DITM    6,110,210,126,270,"Odd"
         DITM    6,130,090,146,150,"None"
         DITM    6,130,150,146,230,"Xon/Xoff"
         DITM    8+128,005,005,021,175,"Communication Settings:"
         DITM    8+128,030,005,046,090,"Baud Rate:"
         DITM    8+128,070,005,086,090,"Data Bits:"
         DITM    8+128,090,005,106,090,"Stop Bits:"
         DITM    8+128,110,005,126,090,"Parity:"
         DITM    8+128,130,005,146,090,"Handshake:"
         ENDR
*--------------------------------
         RSRC    DLOG,201,resPreLoad
         DATA    /060,/115,/195,/395
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /201
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,201,resPreLoad
         DATA    /15-1
         DITM    4,115,150,131,210,"OK"
         DITM    4,115,215,131,275,"Cancel"
         DITM    6,30,95,46,185,"ANSI"
         DITM    6,30,185,46,275,"VT52"
         DITM    6,50,95,66,185,"Backspace"
         DITM    6,50,185,66,275,"Delete"
         DITM    6,70,95,86,185,"Standard"
         DITM    6,70,185,86,275,"Extended"
         DITM    5,90,5,106,95,"Local Echo"
         DITM    5,90,95,106,185,"New Line"
         DITM    5,90,185,106,275,"Auto Wrap"
         DITM    8+128,5,5,21,130,"Terminal Settings:"
         DITM    8+128,30,5,46,95,"Mode:"
         DITM    8+128,50,5,66,95,"BS Key:"
         DITM    8+128,70,5,86,95,"Keypad:"
         ENDR
*--------------------------------
         RSRC    DLOG,202,resPreLoad
         DATA    /060,/080,/203,/426
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /202
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,202,resPreLoad
         DATA    /20-1
         DITM    4,120,210,136,270,"OK"
         DITM    4,120,275,136,335,"Cancel"
         DITM    6,30,70,46,100,"1"
         DITM    6,30,100,46,130,"2"
         DITM    6,30,130,46,160,"3"
         DITM    6,30,160,46,190,"4"
         DITM    6,30,190,46,220,"5"
         DITM    6,30,220,46,250,"6"
         DITM    6,30,250,46,280,"7"
         DITM    6,30,280,46,310,"8"
         DITM    6,50,70,66,100,"1"
         DITM    6,50,100,66,130,"2"
         DITM    6,50,130,66,160,"3"
         DITM    6,50,160,66,190,"4"
         DITM    6,50,190,66,220,"5"
         DITM    16,80,10,96,335,""
         DITM    16,115,10,131,95,""
         DITM    8+128,5,5,21,130,"Soft-key Settings:"
         DITM    8+128,30,5,46,70,"Column:"
         DITM    8+128,50,5,66,70,"Row:"
         ENDR
*--------------------------------
         RSRC    DLOG,203,resPreLoad
         DATA    /060,/120,/225,/385
         DATA    /1
         DATA    #0,#0
         DATA    #0,#0
         DATA    0
         DATA    /203
         STR     ""
         ENDR
*--------------------------------
         RSRC    DITL,203,resPreLoad
         DATA    /15-1
         DITM    4,145,135,161,195,"OK"
         DITM    4,145,200,161,260,"Cancel"
         DITM    6,30,5,46,85,"Text"
         DITM    6,30,170,46,250,"Xmodem"
         DITM    16,60,100,76,135,""
         DITM    16,85,100,101,135,""
         DITM    16,110,100,126,135,""
         DITM    5,60,170,76,260,"MacBinary"
         DITM    5,85,170,101,260,"Turbo"
         DITM    5,110,170,126,260,"CRC"
         DITM    8+128,5,5,21,155,"File Transfer Settings:"
         DITM    8+128,60,5,76,95,"Prompt Char:"
         DITM    8+128,85,5,101,95,"Chars Delay:"
         DITM    8+128,110,5,126,95,"Lines Delay:"
         DITM    0+128,56,155,130,156,""
         ENDR
*--------------------------------
         RSRC    ICON,128,resPreLoad
         HEX     003FF800.00FFFE00.01FFFF00.03FFFF80
         HEX     07FFFFC0.07FFFFC0.0FFFFFE0.0FFFF8E0
         HEX     0FE000E0.1E000070.1C000070.1C000070
         HEX     1C000070.1CFC7E70.0D000160.1C7C7C70
         HEX     14D45650.14383850.14000050.0C028060
         HEX     0C028060.04044040.0406C040.04000040
         HEX     02000080.021FF080.01000100.01038100
         HEX     01800300.01400500.01200900.011FF100
         ENDR
*--------------------------------
         RSRC    ICN#,200,resPreLoad
         HEX     7FFFFFFE.80000001.80000001.80000031
         HEX     80000049.81C00049.82200131.84100081
         HEX     88100641.88080901.90080901.90082601
         HEX     90101001.9060C801.88812001.88812001
         HEX     8484C001.84420001.82210001.82100E01
         HEX     81081181.80842041.80422021.8021C021
         HEX     80100021.800C0041.80030081.8000C301
         HEX     80003C01.80000001.80000001.7FFFFFFE
*
         HEX     00000000.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7E3FFFFE.7C1FFFFE
         HEX     781FFFFE.780FFFFE.700FFFFE.700FFFFE
         HEX     701FFFFE.707FFFFE.78FFFFFE.78FFFFFE
         HEX     7CFFFFFE.7C7FFFFE.7E3FFFFE.7E1FFFFE
         HEX     7F0FF1FE.7F87E07E.7FC3E03E.7FE1C03E
         HEX     7FF0003E.7FFC007E.7FFF00FE.7FFFC3FE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.00000000
         ENDR
*--------------------------------
         RSRC    ICN#,201,resPreLoad
         HEX     00000000.00000000.00000000.7FFFFFFE
         HEX     80000001.80000001.9DF7C001.80000001
         HEX     977C0001.80000001.9BDF7801.80000001
         HEX     9DC00001.80000001.9BEF0001.80000001
         HEX     9EF80001.80000001.80000001.80000001
         HEX     80000001.80000001.80000001.80000001
         HEX     80000001.80000001.80000001.80000001
         HEX     7FFFFFFE.00000000.00000000.00000000
*
         HEX     00000000.00000000.00000000.00000000
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     00000000.00000000.00000000.00000000
         ENDR
*--------------------------------
         RSRC    ICN#,202,resPreLoad
         HEX     00000000.00000000.00000000.7FFFFFFE
         HEX     80000001.80000001.9DF7C001.80000001
         HEX     977C0001.80000001.9BDF7801.80000001
         HEX     9DC00001.80000001.9BEF0001.80000001
         HEX     9EF80001.80000001.80000001.80000001
         HEX     BFFFFFFD.A4924925.BFFFFFFD.A4924925
         HEX     BFFFFFFD.A4924925.BFFFFFFD.80000001
         HEX     7FFFFFFE.00000000.00000000.00000000
*
         HEX     00000000.00000000.00000000.00000000
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     00000000.00000000.00000000.00000000
         ENDR
*--------------------------------
         RSRC    ICN#,203,resPreLoad
         HEX     7FFFFFF8.81000104.81007102.81008901
         HEX     81008901.81008901.81008901.81008901
         HEX     81007101.81000101.80FFFE01.80000001
         HEX     80000001.80000001.80000001.80000001
         HEX     80000001.80000001.87FFFFE1.88000011
         HEX     88000011.88000011.88000011.88000011
         HEX     88000011.88000011.88000011.88000011
         HEX     88000011.88000011.88000011.7FFFFFFE
*
         HEX     00000000.7FFFFFF8.7FFFFFFC.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.7FFFFFFE
         HEX     7FFFFFFE.7FFFFFFE.7FFFFFFE.00000000
         ENDR
*--------------------------------
         RSRC    TS00,0,resPurgeable
         STR     "Telescape Pro v1.3 -- 11/16/87"
         ENDR
*--------------------------------
         RSRC    ICN#,128,resPurgeable
         HEX     1FFFFFE0.10000050.13FFFE48.14000144
         HEX     14000142.15DF8141.14000141.15760141
         HEX     14000141.15BDE141.14000141.15DC0141
         HEX     14000141.15BEE141.14000141.14000141
         HEX     14000141.14000141.13FFFE41.10000041
         HEX     1FFFFFE2.08000024.08000028.0FFFFFF0
         HEX     00000000.07FFFF80.08000180.12AA5280
         HEX     2554A500.40000A00.FFFFF400.FFFFF800
*
         HEX     00000000.0FFFFFE0.0FFFFFF0.0FFFFFF8
         HEX     0FFFFFFC.0FFFFFFE.0FFFFFFE.0FFFFFFE
         HEX     0FFFFFFE.0FFFFFFE.0FFFFFFE.0FFFFFFE
         HEX     0FFFFFFE.0FFFFFFE.0FFFFFFE.0FFFFFFE
         HEX     0FFFFFFE.0FFFFFFE.0FFFFFFE.0FFFFFFE
         HEX     0FFFFFFC.07FFFFF8.07FFFFF0.00000000
         HEX     00000000.00000000.07FFFF00.0FFFFF00
         HEX     1FFFFE00.3FFFFC00.00000000.00000000
         ENDR
*--------------------------------
         RSRC    ICN#,129,resPurgeable
         HEX     0FFFFE00.08000300.08000280.08000240
         HEX     08000220.08000210.080003F8.08000008
         HEX     08000008.08000008.08000008.087FFC08
         HEX     08400608.084FE508.08501488.08501488
         HEX     08501488.08501488.08501488.084FE508
         HEX     08400608.087FFC08.08000008.083FF808
         HEX     08400808.08801008.08FFE008.08000008
         HEX     08000008.08000008.08000008.0FFFFFF8
*
         HEX     0FFFFE00.0FFFFF00.0FFFFF80.0FFFFFC0
         HEX     0FFFFFE0.0FFFFFF0.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         HEX     0FFFFFF8.0FFFFFF8.0FFFFFF8.0FFFFFF8
         ENDR
*--------------------------------
         RSRC    FREF,128,resPurgeable
         ASC     "APPL"
         DATA    /0
         STR     ""
         ENDR
*--------------------------------
         RSRC    FREF,129,resPurgeable
         ASC     "TS00"
         DATA    /1
         STR     ""
         ENDR
*--------------------------------
         RSRC    BNDL,128,resPurgeable
         ASC     "TS00"
         DATA    /0
         DATA    /2-1
         ASC     "ICN#"
         DATA    /2-1
         DATA    /0,/128
         DATA    /1,/129
         ASC     "FREF"
         DATA    /2-1
         DATA    /0,/128
         DATA    /1,/129
         ENDR
*--------------------------------
         RSRC    SIZE,-1,resPurgeable
         DATA    /$4000          ; flags
         DATA    $28000          ; pref_size
         DATA    $20000          ; min_size
         ENDR
*--------------------------------
         END
