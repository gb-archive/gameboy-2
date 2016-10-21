include "lapras/header.inc"

section "V-Blank", rom0[$40]
  call LoadPalettes
  reti

section "LCD Status", rom0[$48] ; H-Blank interrupt, for now
  jp    ScanlineLookup

section "Program", rom0[$150]
Main
  call  DisableLCD
  ld    a,%00000011
  ldh   [$ff],a     ; enable V-Blank and LCD STAT interrupt
  ld    a,%00001000
  ldh   [$41],a     ; enable H-Blank interrupt
  call  LoadTiles
  call  LoadMap
  call  LoadPalettes
  call  EnableLCD
  ei
.Update
  halt
  nop
  jr    .Update

LoadTiles
  ld    hl,$ff51    ; $ff51-$ff55: VRAM DMA transfer
  ld    bc,TileData ; Tiledata ROM
  ld    de,$8000    ; Tiledata RAM
  ld    [hl],b
  inc   l;$52
  ld    [hl],c
  inc   l;$53
  ld    [hl],d
  inc   l;$54
  ld    [hl],e
  inc   l;$55
  ld    a,$3f       ; ($3f + 1) * $10 = $400 bytes = $40 tiles
  ld    [hl],a      ; start DMA transfer
  ret

LoadMap;Attributes, then Indices
  ld    hl,$ff4f    ; $ff4f=VRAM Bank
  ld    bc,MapAttributes
  ld    de,$9800
  ld    a,1
  ld    [hl+],a     ; VRAM Bank 1
  inc   l           ; $ff51-$ff54: DMA srcHI, srcLO, dstHI, dstLO
  ld    [hl],b
  inc   l;$52
  ld    [hl],c
  inc   l;$53
  ld    [hl],d
  inc   l;$54
  ld    [hl],e
  inc   l;$55       ; $ff55.7 = mode (0: general purpose, 1: H-Blank)
  ; $19 = $20 * 5 empties + $20 * 8 attributes, ceil($1a0,$10) = $1a0, $1a0 / $10 - 1
  ld    a,$19
  ld    [hl],a      ; $ff55.0-6 = bytes / $10 - 1, write = start DMA transfer
  ld    bc,MapIndices
  xor   a
  ld    [$ff4f],a   ; VRAM Bank 0
  ld    l,$51
  ld    [hl],b
  inc   l;$52
  ld    [hl],c
  inc   l;$53
  ld    [hl],d
  inc   l;$54
  ld    [hl],e
  inc   l;$55
  ld    a,$19
  ld    [hl],a      ; start DMA transfer
  ret

DisableLCD
  ld    bc,$9044
  ld    hl,$ff40    ; LCD control
.wait;while LY < 144 (not in vblank)
  ld    a,[c]       ; a = LY
  cp    b           ; LY < 144?
  jr    c,.wait
  res   7,[hl]
  ret

EnableLCD
  ld    hl,$ff40
  set   7,[hl]
  ret

section "Tile data", romx,bank[1]
TileData
incbin "lapras/lapras.2bpp"

include "lapras/map.asm"
include "lapras/palette.asm"

; vim:syn=rgbasm
