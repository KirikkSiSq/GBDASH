;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.1 #15267 (MINGW64)
;--------------------------------------------------------
	.module collision
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _hUGE_init
	.globl _fill_scroll_bg
	.globl _draw_mt_column
	.globl _load_bkg_tileset
	.globl _set_bkg_tiles
	.globl _set_bkg_data
	.globl _col_at
	.globl _init_music_banked
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
	.area _HRAM
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src/collision.c:8: uint8_t col_at(
;	---------------------------------
; Function col_at
; ---------------------------------
_col_at::
	add	sp, #-7
	ldhl	sp,	#5
	ld	a, e
	ld	(hl+), a
	ld	(hl), d
;src/collision.c:16: if (world_py < 0) return COL_NONE;
	ld	h, b
	bit	7, h
	jr	Z, 00102$
	xor	a, a
	jp	00114$
00102$:
;src/collision.c:17: uint16_t mx = world_px >> 4;
	ldhl	sp,	#5
	ld	a, (hl)
	ldhl	sp,	#0
	ld	(hl), a
	ldhl	sp,	#6
	ld	a, (hl)
	ldhl	sp,	#1
	ld	(hl), a
	srl	(hl)
	dec	hl
	rr	(hl)
	inc	hl
	srl	(hl)
	dec	hl
	rr	(hl)
	inc	hl
	srl	(hl)
	dec	hl
	rr	(hl)
	inc	hl
	srl	(hl)
	dec	hl
	rr	(hl)
;src/collision.c:18: uint16_t my = (uint16_t)world_py >> 4;
	inc	hl
	inc	hl
	ld	a, c
	ld	(hl+), a
	ld	a, b
	ld	(hl-), a
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
;src/collision.c:20: if (mx >= map_w || my >= map_h) return COL_ALL;
	push	de
	ldhl	sp,	#2
	ld	e, l
	ld	d, h
	ldhl	sp,	#13
	ld	a, (de)
	inc	de
	sub	a, (hl)
	inc	hl
	ld	a, (de)
	sbc	a, (hl)
	pop	de
	jr	NC, 00103$
	ldhl	sp,	#13
	ld	a, e
	sub	a, (hl)
	inc	hl
	ld	a, d
	sbc	a, (hl)
	jr	C, 00104$
00103$:
	ld	a, #0x07
	jr	00114$
00104$:
;src/collision.c:23: uint8_t _prev = _current_bank;
	ldh	a, (__current_bank + 0)
	ldhl	sp,	#4
	ld	(hl), a
;src/collision.c:24: SWITCH_ROM(map_bank);
	ldhl	sp,	#15
	ld	a, (hl)
	ldh	(__current_bank + 0), a
	ld	(#_rROMB0),a
;src/collision.c:25: col = famidash_metatile_collision[map[(uint16_t)my * map_w + mx]];
	ldhl	sp,	#11
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	call	__mulint
	pop	hl
	push	hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ldhl	sp,	#9
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	a, (bc)
	ld	l, a
	ld	h, #0x00
	ld	de, #_famidash_metatile_collision
	add	hl, de
	ld	c, (hl)
;src/collision.c:26: SWITCH_ROM(_prev);
	ldhl	sp,	#4
	ld	a, (hl)
	ldh	(__current_bank + 0), a
	ld	a, (hl)
	ld	(#_rROMB0),a
;src/collision.c:29: if (((uint16_t)world_py & 0x0F) < 8) return COL_NONE;
	ldhl	sp,	#2
	ld	a, (hl+)
	ld	b, (hl)
	and	a, #0x0f
	ld	e, a
	ld	d, #0x00
	ld	a, e
	sub	a, #0x08
	ld	a, #0x00
	rla
	ld	b, a
;src/collision.c:28: if (col == COL_DEATH_TOP_HALF) {
	ld	a, c
;src/collision.c:29: if (((uint16_t)world_py & 0x0F) < 8) return COL_NONE;
	sub	a, #0x10
	jr	NZ, 00109$
	or	a, b
	jr	Z, 00107$
	xor	a, a
	jr	00114$
00107$:
;src/collision.c:30: return COL_DEATH;
	ld	a, #0x08
	jr	00114$
00109$:
;src/collision.c:32: if (col == COL_DEATH_BOTTOM_HALF) {
	ld	a, c
	sub	a, #0x11
	jr	NZ, 00113$
;src/collision.c:33: if (((uint16_t)world_py & 0x0F) >= 8) return COL_NONE;
	bit	0, b
	jr	NZ, 00111$
	xor	a, a
	jr	00114$
00111$:
;src/collision.c:34: return COL_DEATH;
	ld	a, #0x08
	jr	00114$
00113$:
;src/collision.c:37: return col;
	ld	a, c
00114$:
;src/collision.c:38: }
	add	sp, #7
	pop	hl
	add	sp, #7
	jp	(hl)
;src/collision.c:42: void load_bkg_tileset(const uint8_t* tiles, uint16_t tile_count, uint8_t bank) {
;	---------------------------------
; Function load_bkg_tileset
; ---------------------------------
_load_bkg_tileset::
	dec	sp
;src/collision.c:43: uint8_t _prev = _current_bank;
	ldh	a, (__current_bank + 0)
	ldhl	sp,	#0
	ld	(hl), a
;src/collision.c:44: SWITCH_ROM(bank);
	ldhl	sp,	#3
	ld	a, (hl)
	ldh	(__current_bank + 0), a
	ld	(#_rROMB0),a
;src/collision.c:45: if (tile_count == 256u) {
	ld	l, c
	ld	h, b
	ld	a, l
	or	a, a
	jr	NZ, 00102$
	dec	h
	jr	NZ, 00102$
;src/collision.c:46: set_bkg_data(0, 128, tiles);
	push	de
	push	de
	ld	hl, #0x8000
	push	hl
	call	_set_bkg_data
	add	sp, #4
	pop	de
;src/collision.c:47: set_bkg_data(128, 128, tiles + (128u * 16u));
	ld	hl, #0x0800
	add	hl, de
	push	hl
	ld	hl, #0x8080
	push	hl
	call	_set_bkg_data
	add	sp, #4
	jr	00103$
00102$:
;src/collision.c:49: set_bkg_data(0, (uint8_t)tile_count, tiles);
	ld	a, c
	push	de
	ld	h, a
	ld	l, #0x00
	push	hl
	call	_set_bkg_data
	add	sp, #4
00103$:
;src/collision.c:51: SWITCH_ROM(_prev);
	ldhl	sp,	#0
	ld	a, (hl)
	ldh	(__current_bank + 0), a
	ld	a, (hl)
	ld	(#_rROMB0),a
;src/collision.c:52: }
	inc	sp
	pop	hl
	inc	sp
	jp	(hl)
;src/collision.c:54: void draw_mt_column(uint8_t ring_col, uint16_t map_col,
;	---------------------------------
; Function draw_mt_column
; ---------------------------------
_draw_mt_column::
	add	sp, #-10
	ldhl	sp,	#7
	ld	(hl), e
	inc	hl
	ld	(hl), d
;src/collision.c:58: uint8_t bx = ring_col << 1;
	add	a, a
	ldhl	sp,	#2
;src/collision.c:60: uint8_t _prev = _current_bank;
	ld	(hl+), a
	ldh	a, (__current_bank + 0)
	ld	(hl), a
;src/collision.c:61: SWITCH_ROM(map_bank);
	ldhl	sp,	#18
	ld	a, (hl)
	ldh	(__current_bank + 0), a
	ld	(#_rROMB0),a
;src/collision.c:63: for (uint8_t r = 0; r < map_h && r < BKG_MT_H; r++) {
	ldhl	sp,	#9
	ld	(hl), #0x00
00104$:
	ldhl	sp,	#9
	ld	a, (hl)
	ldhl	sp,	#5
	ld	(hl+), a
	ld	(hl), #0x00
	ldhl	sp,	#5
	ld	e, l
	ld	d, h
	ldhl	sp,	#16
	ld	a, (de)
	inc	de
	sub	a, (hl)
	inc	hl
	ld	a, (de)
	sbc	a, (hl)
	jp	NC, 00101$
	ldhl	sp,	#9
	ld	a, (hl)
	sub	a, #0x10
	jp	NC, 00101$
;src/collision.c:64: uint8_t mt = map[(uint16_t)r * map_w + map_col];
	ldhl	sp,	#14
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ldhl	sp,	#5
	ld	e, (hl)
	ld	d, #0x00
	call	__mulint
	pop	hl
	push	bc
	pop	de
	push	de
	ldhl	sp,	#7
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	push	hl
	ld	a, l
	ldhl	sp,	#7
	ld	(hl), a
	pop	hl
	ld	a, h
	ldhl	sp,	#6
	ld	(hl-), a
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp,	#12
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	inc	sp
	inc	sp
	ld	e, l
	ld	d, h
	push	de
	ld	a, (de)
	ldhl	sp,	#5
	ld	(hl), a
;src/collision.c:65: uint8_t by = (r & (BKG_MT_H - 1)) << 1;
	ldhl	sp,	#9
	ld	a, (hl)
	and	a, #0x0f
	ldhl	sp,	#6
	ld	(hl), a
	sla	(hl)
;src/collision.c:67: set_bkg_tiles(bx, by, 2, 1, &metatiles[mt][0]);
	dec	hl
	ld	a, (hl-)
	ld	(hl+), a
	ld	(hl), #0x00
	ld	a, #0x02
00130$:
	ldhl	sp,	#4
	sla	(hl)
	inc	hl
	rl	(hl)
	dec	a
	jr	NZ, 00130$
	dec	hl
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #_metatiles
	add	hl, de
	inc	sp
	inc	sp
	push	hl
	ldhl	sp,	#0
	ld	a, (hl)
	ldhl	sp,	#4
	ld	(hl), a
	ldhl	sp,	#1
	ld	a, (hl)
	ldhl	sp,	#5
	ld	(hl-), a
	ld	a, (hl+)
	ld	e, a
	ld	a, (hl+)
	ld	d, a
	push	de
	ld	de, #0x102
	push	de
	ld	a, (hl)
	push	af
	inc	sp
	ldhl	sp,	#7
	ld	a, (hl)
	push	af
	inc	sp
	call	_set_bkg_tiles
	add	sp, #6
;src/collision.c:68: set_bkg_tiles(bx, by + 1, 2, 1, &metatiles[mt][2]);
	pop	de
	push	de
	ld	hl, #0x0002
	add	hl, de
	push	hl
	ld	a, l
	ldhl	sp,	#6
	ld	(hl), a
	pop	hl
	ld	a, h
	ldhl	sp,	#5
	ld	(hl+), a
	ld	a, (hl-)
	dec	hl
	inc	a
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	ld	h, #0x01
	push	hl
	inc	sp
	ld	h, #0x02
	push	hl
	inc	sp
	push	af
	inc	sp
	ldhl	sp,	#7
	ld	a, (hl)
	push	af
	inc	sp
	call	_set_bkg_tiles
	add	sp, #6
;src/collision.c:63: for (uint8_t r = 0; r < map_h && r < BKG_MT_H; r++) {
	ldhl	sp,	#9
	inc	(hl)
	jp	00104$
00101$:
;src/collision.c:71: SWITCH_ROM(_prev);
	ldhl	sp,	#3
	ld	a, (hl)
	ldh	(__current_bank + 0), a
	ld	a, (hl)
	ld	(#_rROMB0),a
;src/collision.c:72: }
	add	sp, #10
	pop	hl
	add	sp, #7
	jp	(hl)
;src/collision.c:74: void fill_scroll_bg(const uint8_t* map, uint16_t map_w, uint16_t map_h, uint8_t map_bank) {
;	---------------------------------
; Function fill_scroll_bg
; ---------------------------------
_fill_scroll_bg::
	add	sp, #-4
	ldhl	sp,	#2
	ld	a, e
	ld	(hl+), a
	ld	(hl), d
;src/collision.c:75: uint16_t cols = (map_w < 16) ? map_w : 16;
	ld	e, c
	ld	d, b
	ld	a, e
	sub	a, #0x10
	ld	a, d
	sbc	a, #0x00
	jr	C, 00108$
	ld	e, #0x10
00108$:
	ldhl	sp,	#0
	ld	a, e
	ld	(hl+), a
;src/collision.c:76: for (uint16_t c = 0; c < cols; c++) {
	ld	de, #0x0000
	ld	(hl), e
00103$:
	ldhl	sp,	#0
	ld	a, e
	sub	a, (hl)
	inc	hl
	ld	a, d
	sbc	a, (hl)
	jr	NC, 00105$
;src/collision.c:77: draw_mt_column((uint8_t)(c % 16), c, map, map_w, map_h, map_bank);
	ld	a, e
	and	a, #0x0f
	push	bc
	push	de
	ldhl	sp,	#12
	ld	h, (hl)
	push	hl
	inc	sp
	push	af
	ldhl	sp,	#13
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	pop	af
	push	hl
	push	bc
	push	af
	ldhl	sp,	#13
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	pop	af
	push	hl
	call	_draw_mt_column
	pop	de
	pop	bc
;src/collision.c:76: for (uint16_t c = 0; c < cols; c++) {
	inc	de
	jr	00103$
00105$:
;src/collision.c:79: }
	add	sp, #4
	pop	hl
	add	sp, #3
	jp	(hl)
;src/collision.c:85: void init_music_banked(const hUGESong_t * song, uint8_t bank, uint8_t divider) {
;	---------------------------------
; Function init_music_banked
; ---------------------------------
_init_music_banked::
	ld	c, a
;src/collision.c:86: uint8_t _prev = _current_bank;
	ldh	a, (__current_bank + 0)
	ld	b, a
;src/collision.c:87: music_ready = 0;
	xor	a, a
	ld	(#_music_ready),a
;src/collision.c:88: current_song_bank = bank;
	ld	hl, #_current_song_bank
	ld	(hl), c
;src/collision.c:89: SWITCH_ROM(bank);
	ld	a, c
	ldh	(__current_bank + 0), a
	ld	hl, #_rROMB0
	ld	(hl), c
;c:\gbdk\include\gb\gb.h:811: __asm__("di");
	di
;src/collision.c:91: hUGE_init(song);
	push	bc
	call	_hUGE_init
	pop	bc
;src/collision.c:92: TMA_REG = divider;
	ldhl	sp,	#2
	ld	a, (hl)
	ldh	(_TMA_REG + 0), a
;c:\gbdk\include\gb\gb.h:795: __asm__("ei");
	ei
;src/collision.c:94: SWITCH_ROM(_prev);
	ld	a, b
	ldh	(__current_bank + 0), a
	ld	hl, #_rROMB0
	ld	(hl), b
;src/collision.c:95: music_ready = 1;
	ld	hl, #_music_ready
	ld	(hl), #0x01
;src/collision.c:96: }
	pop	hl
	inc	sp
	jp	(hl)
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
