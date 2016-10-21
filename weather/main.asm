section "Code", rom0
Setup:;                    ┌──┬LY
DisableLCD:     ld    hl, $ff44;┌┬Line 144, V-Blank starts
                ld    a,       $90
.ltLY144:       cp    [hl]
                jr    C, @+2
                jr    NZ, .ltLY144
;                          ┌──┬LCD Control
                ld    hl, $ff40;┌LCD Display enabled?
                res             7, [hl]

;                          ┌──┬Prepare Speed Switch, CGB Mode Only
SwitchSpeed:    ld    hl, $ff4d;┌Prepare Speed Switch?
                set             0, [hl]
                stop

Upload:         include "big-endian.inc"
                ld    a, 1
                ld    hl, $ff55
.mapTiles:      ldbe  bc, MapTiles
                ldbe  de, $8000
                ld    sp, hl
                push  de
                push  bc
                ld    [hl], (MapTilesEnd-MapTiles)/$10-$01
.map:           ldbe  bc, Map
                ldbe  de, $9800
                ld    sp, hl
                push  de
                push  bc
                ld    [hl], (MapEnd-Map)/$10-$01
.mapAttributes: ldbe  bc, MapAttributes
                ld    sp, hl
                push  de
                push  bc
                ld    [$ff4f], a
                ld    [hl], (MapAttributesEnd-MapAttributes)/$10-$01
                xor   1
                ld    [$ff4f], a
.mapPalette:    ld    l, $68
                ld    [hl], %10000000
                inc   l
                ld    sp, MapPalette
                rept  $04
                pop   bc
                ld    [hl], c
                ld    [hl], b
                endr
                ld    sp, $fffc;Ready stack pointer for return

EnableLCD:      ld    l, $40
                set   7, [hl]

EnableInterrupts:
                ld    l, $ff
                set   0, [hl];V-Blank

InitializeSine: ld    hl, Sine
                ld    [hl], $00
                inc   hl
                ld    [hl], $01
                inc   hl
                ld    [hl], $00
                inc   hl
                ld    [hl], $00

;The first V-Blank interrupt has different behaviour, so skip it:
SkipVBlank:     ld    l, $44
                ld    a, $8f
.ltLY144:       rept  $29
                cp    [hl]
                jr    C, .return
                endr
                cp    [hl]
                jr    NC, .ltLY144
.return:        reti



VBlank:
.y:             ld    hl, Sine
                ld    b, [hl]
                inc   [hl]
                jr    NZ, .noCarryY
                inc   hl
                inc   [hl]
                dec   hl
.noCarryY:      inc   hl
                ld    a, [hl]
                and   %00000011
                ld    [hl], a
                ld    hl, Sines
                add   h
                ld    h, a
                ld    l, b
                ld    a, [hl]
                ld    hl, $ff42
                ld    [hl], a
.x:             ld    hl, Cosine
                ld    b, [hl]
                inc   [hl]
                jr    NZ, .noCarryX
                inc   hl
                inc   [hl]
                dec   hl
.noCarryX:      inc   hl
                ld    a, [hl]
                and   %00000011
                ld    [hl], a
                ld    hl, Sines
                add   h
                ld    h, a
                ld    l, b
                ld    a, [hl]
                ld    hl, $ff43
                ld    [hl], a
.skip:          reti





section "HRAM", hram
Sine:           ds    2
Cosine:         ds    2





section "V-Blank interrupt vector", rom0[$0040]
                jp    VBlank





section "Data", romx, bank[1]
ANGLE           set   0.0
Sines:          rept  $400
                db    (mul(64.0, sin(ANGLE))+64.0)>>16
ANGLE           set   ANGLE+64.0
                endr

MapTiles:       incbin  "pallet-town.2bpp"
MapTilesEnd:
Map:            incbin  "pallet-town.tilemap"
MapEnd:
MapAttributes:  rept  MapEnd-Map
                db    $00
                endr
MapAttributesEnd:
MapPalette:     incbin  "pallet-town.pal"
MapPaletteEnd:





section "Header", rom0[$0100]
                di
                jp    Main
                db    $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83
                db    $00, $0c, $00, $0d, $00, $08, $11, $1f, $88, $89, $00, $0e
                db    $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99, $bb, $bb, $67, $63
                db    $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e
                db    "WEATHER    EMMA"
                db    $80       ;GBC+DMG
                db    "PD"
                db    $00       ;No SGB
                db    $1b       ;MBC5+RAM+Battery
                db    $00       ; 32 KiB ROM
                db    $04       ;  0     RAM
                db    $01       ;International
                db    $33
                db    %10       ;0.1.0
                db    $00, $00, $00





section "Main", rom0[$0150]
Main:           call Setup
.wait:          halt
                nop
                jr    .wait

; vim:filetype=rgbasm expandtab softtabstop=2