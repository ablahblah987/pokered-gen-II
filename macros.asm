
text   EQUS "db $00," ; Start writing text.
next   EQUS "db $4e," ; Move a line down.
line   EQUS "db $4f," ; Start writing at the bottom line.
para   EQUS "db $51," ; Start a new paragraph.
cont   EQUS "db $55," ; Scroll to the next line.
done   EQUS "db $57"  ; End a text box.
prompt EQUS "db $58"  ; Prompt the player to end a text box (initiating some other event).

page   EQUS "db $49,"     ; Start a new Pokedex page.
dex    EQUS "db $5f, $50" ; End a Pokedex entry.


percent EQUS "* $ff / 100"


; Constant enumeration is useful for monsters, items, moves, etc.
const_def: MACRO
const_value = 0
ENDM

const: MACRO
\1 EQU const_value
const_value = const_value + 1
ENDM


homecall: MACRO
	ld a, [H_LOADEDROMBANK]
	push af
	ld a, BANK(\1)
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	call \1
	pop af
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	ENDM

callba: MACRO
	ld b, BANK(\1)
	ld hl, \1
	call Bankswitch
	ENDM

callab: MACRO
	ld hl, \1
	ld b, BANK(\1)
	call Bankswitch
	ENDM

;\1 = X
;\2 = Y
hlCoord: MACRO
	ld hl, wTileMap + 20 * \2 + \1
	ENDM

;\1 = X
;\2 = Y
deCoord: MACRO
	ld de, wTileMap + 20 * \2 + \1
	ENDM

;\1 = X
;\2 = Y
bcCoord: MACRO
	ld bc, wTileMap + 20 * \2 + \1
	ENDM

;\1 = X
;\2 = Y
aCoord: MACRO
	ld a, [wTileMap + 20 * \2 + \1]
	ENDM

;\1 = X
;\2 = Y
Coorda: MACRO
	ld [wTileMap + 20 * \2 + \1], a
	ENDM

;\1 = X
;\2 = Y
dwCoord: MACRO
	dw wTileMap + 20 * \2 + \1
	ENDM

;\1 = Map Width
;\2 = Rows above (Y-blocks)
;\3 = X movement (X-blocks)
EVENT_DISP: MACRO
	dw (wOverworldMap + 7 + (\1) + ((\1) + 6) * ((\2) >> 1) + ((\3) >> 1)) ; Ev.Disp
	db \2,\3	;Y,X
	ENDM

FLYWARP_DATA: MACRO
	EVENT_DISP \1,\2,\3
	db ((\2) & $01)	;sub-block Y
	db ((\3) & $01)	;sub-block X
	ENDM

; external map entry macro
EMAP: MACRO ; emap x-coordinate,y-coordinate,textpointer
; the appearance of towns and routes in the town map, indexed by map id
	; nybble: y-coordinate
	; nybble: x-coordinate
	; word  : pointer to map name
	db (\1 + (\2 << 4))
	dw \3
	ENDM

; internal map entry macro
IMAP: MACRO ; imap mapid_less_than,x-coordinate,y-coordinate,textpointer
; the appearance of buildings and dungeons in the town map
	; byte  : maximum map id subject to this rule
	; nybble: y-coordinate
	; nybble: x-coordinate
	; word  : pointer to map name
	db \1
	db \2 + \3 << 4
	dw \4
	ENDM

; tilesets' headers macro
tileset: MACRO
	db BANK(\2)   ; BANK(GFX)
	dw \1, \2, \3 ; Block, GFX, Coll
	db \4, \5, \6 ; counter tiles
	db \7         ; grass tile
	db \8         ; permission (indoor, cave, outdoor)
	ENDM

INDOOR  EQU 0
CAVE    EQU 1
OUTDOOR EQU 2

; macro for two nibbles
dn: MACRO
	db (\1 << 4 | \2)
	ENDM

; macro for putting a byte then a word
dbw: MACRO
	db \1
	dw \2
	ENDM

; data format macros
RGB: MACRO
	dw (\3 << 10 | \2 << 5 | \1)
	ENDM

dt: MACRO ; three-byte (big-endian)
	db (\1 >> 16) & $ff
	db (\1 >> 8) & $ff
	db \1 & $ff
	ENDM

bigdw: MACRO ; big-endian word
	dw ((\1)/$100) + (((\1)&$ff)*$100)
	ENDM

lb: MACRO ; r, hi, lo
	ld \1, \2 << 8 + \3
	ENDM

; text macros
TX_NUM: MACRO
; print a big-endian decimal number.
; \1: address to read from
; \2: number of bytes to read
; \3: number of digits to display
	db $09
	dw \1
	db \2 << 4 | \3
	ENDM

TX_FAR: MACRO
	db $17
	dw \1
	db BANK(\1)
	ENDM

; text engine command $1
TX_RAM: MACRO
; prints text to screen
; \1: RAM address to read from
	db $1
	dw \1
	ENDM

TX_BCD: MACRO
	db $2
	dw \1
	db \2
	ENDM

; Predef macro.
add_predef: MACRO
\1Predef::
	db BANK(\1)
	dw \1
	ENDM

predef_id: MACRO
	ld a, (\1Predef - PredefPointers) / 3
	ENDM

predef: MACRO
	predef_id \1
	call Predef
	ENDM

predef_jump: MACRO
	predef_id \1
	jp Predef
	ENDM


add_tx_pre: MACRO
\1_id:: dw \1
ENDM

tx_pre_id: MACRO
	ld a, (\1_id - TextPredefs) / 2
ENDM

tx_pre: MACRO
	tx_pre_id \1
	call PrintPredefTextID
ENDM

tx_pre_jump: MACRO
	tx_pre_id \1
	jp PrintPredefTextID
ENDM


;1_channel	EQU $00
;2_channels	EQU $40
;3_channels	EQU $80
;4_channels	EQU $C0

CH0		EQU 0
CH1		EQU 1
CH2		EQU 2
CH3		EQU 3
CH4		EQU 4
CH5		EQU 5
CH6		EQU 6
CH7		EQU 7

note: MACRO
	db \1 << 4 + (\2 - 1)
	ENDM

; pitch
__ EQU 0
C_ EQU 1
C# EQU 2
D_ EQU 3
D# EQU 4
E_ EQU 5
F_ EQU 6
F# EQU 7
G_ EQU 8
G# EQU 9
A_ EQU 10
A# EQU 11
B_ EQU 12

inc_octave: MACRO
	db $f4
	ENDM

dec_octave: MACRO
	db $f5
	ENDM

notetype0: MACRO
	db $f6, \1
	ENDM

notetype1: MACRO
	db $f7, \1
	ENDM

notetype2: MACRO
	db $f8, \1
	ENDM

unknownsfx0x10: MACRO
	db $dd ; soundinput
	db \1
ENDM

unknownsfx0x20: MACRO
	; noise/sound
	db \1
	;db $20 | \1
	db \2
	db \3
	db \4
ENDM

unknownnoise0x20: MACRO
	db \1 ; | $20
	db \2
	db \3
ENDM

; crystal macros:
octave: MACRO
	db $d8 - (\1)
	ENDM

notetype: MACRO
	db $d8, \1
IF _NARG==2
	db \2
ENDC
	ENDM

forceoctave: MACRO
	db $d9, \1
	ENDM

tempo: MACRO
	db $da
	bigdw \1
	ENDM

dutycycle: MACRO
	db $db, \1
	ENDM

intensity: MACRO
	db $dc, \1
	ENDM

soundinput: MACRO
	db $dd, \1
	ENDM

unknownmusic0xde: MACRO
	db $de, \1
	ENDM

togglesfx: MACRO
	db $df
	ENDM

unknownmusic0xe0: MACRO
	db $e0, \1, \2
	ENDM

vibrato: MACRO
	db $e1, \1, \2
	ENDM

unknownmusic0xe2: MACRO
	db $e2, \1
	ENDM

togglenoise: MACRO
	db $e3, \1
	ENDM

panning: MACRO
	db $e4, \1
	ENDM

volume: MACRO
	db $e5, \1
	ENDM

tone: MACRO
	db $e6
	bigdw \1
	ENDM

unknownmusic0xe7: MACRO
	db $e7, \1
	ENDM

unknownmusic0xe8: MACRO
	db $e8, \1
	ENDM

globaltempo: MACRO
	db $e9
	bigdw \1
	ENDM

restartchannel: MACRO
	dbw $ea, \1
	ENDM

newsong: MACRO
	db $eb
	bigdw \1
	ENDM

sfxpriorityon: MACRO
	db $ec
	ENDM

sfxpriorityoff: MACRO
	db $ed
	ENDM

unknownmusic0xee: MACRO
	dbw $ee, \1
	ENDM

stereopanning: MACRO
	db $ef, \1
	ENDM

sfxtogglenoise: MACRO
	db $f0, \1
	ENDM

ftempo: MACRO
	db $f1
	bigdw \1
	ENDM

fdutycycle: MACRO
	db $f2, \1
	ENDM

music0xf3: MACRO
	db $f3
	ENDM

incoctave: MACRO
	db $f4
	ENDM

decoctave: MACRO
	db $f5
	ENDM

music0xf6: MACRO
	db $f6
	ENDM

music0xf7: MACRO
	db $f7
	ENDM

music0xf8: MACRO
	db $f8
	ENDM

unknownmusic0xf9: MACRO
	db $f9, \1
	ENDM

setcondition: MACRO
	db $fa, \1
	ENDM

jumpif: MACRO
	db $fb, \1
	dw \2
	ENDM

jumpchannel: MACRO
	dbw $fc, \1
	ENDM

loopchannel: MACRO
	db $fd, \1
	dw \2
	ENDM

callchannel: MACRO
	dbw $fe, \1
	ENDM

endchannel: MACRO
	db $ff
	ENDM

sound: MACRO
	db \1, \2
	dw \3
	ENDM

noise: MACRO
	db \1, \2, \3
	ENDM

toggleperfectpitch: MACRO ; XXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	ENDM


;\1 (byte) = connected map id
;\2 (byte) = connected map width
;\3 (byte) = connected map height
;\4 (byte) = x movement of connection strip
;\5 (byte) = connection strip offset
;\6 (byte) = width of connection strip
;\7 (word) = connected map blocks pointer
NORTH_MAP_CONNECTION: MACRO
	db \1 ; map id
	dw \7 + (\2 * (\3 - 3)) + \5; "Connection Strip" location
	dw wOverworldMap + 3 + \4 ; current map position
	db \6 ; width of connection strip
	db \2 ; map width
	db (\3 * 2) - 1 ; y alignment (y coordinate of player when entering map)
	db (\4 - \5) * -2 ; x alignment (x coordinate of player when entering map)
	dw wOverworldMap + 1 + (\3 * (\2 + 6)) ; window (position of the upper left block after entering the map)
ENDM

;\1 (byte)  = connected map id
;\2 (byte)  = connected map width
;\3 (byte)  = x movement of connection strip
;\4 (byte)  = connection strip offset
;\5 (byte)  = width of connection strip
;\6 (word)  = connected map blocks pointer
;\7 (byte)  = current map width
;\8 (byte) = current map height
SOUTH_MAP_CONNECTION: MACRO
	db \1 ; map id
	dw \6 + \4 ; "Conection Strip" location
	dw wOverworldMap + 3 + (\8 + 3) * (\7 + 6) + \3 ; current map positoin
	db \5 ; width of connection strip
	db \2 ; map width
	db 0  ; y alignment (y coordinate of player when entering map)
	db (\3 - \4) * -2 ; x alignment (x coordinate of player when entering map)
	dw wOverworldMap + 7 + \2 ; window (position of the upper left block after entering the map)
ENDM

;\1 (byte)  = connected map id
;\2 (byte)  = connected map width
;\3 (byte)  = y movement of connection strip
;\4 (byte)  = connection strip offset
;\5 (byte)  = height of connection strip
;\6 (word)  = connected map blocks pointer
;\7 (byte)  = current map width
EAST_MAP_CONNECTION: MACRO
	db \1 ; map id
	dw \6 + (\2 * \4) ; "Connection Strip" location
	dw wOverworldMap - 3 + (\7 + 6) * (\3 + 4) ; current map position
	db \5 ; height of connection strip
	db \2 ; map width
	db (\3 - \4) * -2 ; y alignment
	db 0 ; x alignment
	dw wOverworldMap + 7 + \2 ; window (position of the upper left block after entering the map)
ENDM

;\1 (byte)  = connected map id
;\2 (byte)  = connected map width
;\3 (byte)  = y movement of connection strip
;\4 (byte)  = connection strip offset
;\5 (byte)  = height of connection strip
;\6 (word)  = connected map blocks pointer
;\7 (byte)  = current map width
WEST_MAP_CONNECTION: MACRO
	db \1 ; map id
	dw \6 + (\2 * \4) + \2 - 3 ; "Connection Strip" location
	dw wOverworldMap + (\7 + 6) * (\3 + 3) ; current map position
	db \5 ; height of connection strip
	db \2 ; map width
	db (\3 - \4) * -2 ; y alignment
	db (\2 * 2) - 1 ; x alignment
	dw wOverworldMap + 6 + (2 * \2) ; window (position of the upper left block after entring the map)
ENDM
