Sfx_NotVeryEffective: ; f1b33
	dbw $07, Sfx_NotVeryEffective_Ch8
; f1b36

Sfx_NotVeryEffective_Ch8: ; f1b36
	noise $4, $f1, $5f
	noise $1, $a0, $42
	noise $10, $f1, $53
	endchannel
; f1b40

Sfx_Damage: ; f1b40
	dbw $07, Sfx_Damage_Ch8
; f1b43

Sfx_Damage_Ch8: ; f1b43
	noise $4, $f1, $5e
	noise $1, $a0, $12
	noise $4, $f0, $32
	noise $10, $f1, $44
	endchannel
; f1b50

Sfx_SuperEffective: ; f1b50
	dbw $07, Sfx_SuperEffective_Ch8
; f1b53

Sfx_SuperEffective_Ch8: ; f1b53
	noise $3, $f1, $4f
	noise $1, $c8, $22
	noise $2, $f8, $3f
	noise $3, $d0, $15
	noise $20, $f2, $35
	endchannel
; f1b63