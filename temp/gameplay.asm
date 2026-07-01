;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.1 #15267 (MINGW64)
;--------------------------------------------------------
	.module gameplay
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl b_player_screen_y
	.globl _player_screen_y
	.globl b_player_update
	.globl _player_update
	.globl b_player_init
	.globl _player_init
	.globl _init_music_banked
	.globl _fill_scroll_bg
	.globl _draw_mt_column
	.globl _load_bkg_tileset
	.globl _puts
	.globl _printf
	.globl _gotoxy
	.globl _font_set
	.globl _font_load
	.globl _font_init
	.globl _fill_bkg_rect
	.globl _set_sprite_data
	.globl _display_off
	.globl _wait_vbl_done
	.globl _waitpadup
	.globl _joypad
	.globl b_setup_menu_font
	.globl _setup_menu_font
	.globl b_draw_menu
	.globl _draw_menu
	.globl b_play_level
	.globl _play_level
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
	.area _CODE_1
;src/gameplay.c:30: void setup_menu_font(void) BANKED {
;	---------------------------------
; Function setup_menu_font
; ---------------------------------
	b_setup_menu_font	= 1
_setup_menu_font::
;src/gameplay.c:31: font_init();
	call	_font_init
;src/gameplay.c:32: font_set(font_load(font_min));
	ld	de, #_font_min
	push	de
	call	_font_load
	pop	hl
	push	de
	call	_font_set
	pop	hl
;src/gameplay.c:33: }
	ret
;src/gameplay.c:35: void draw_menu(void) BANKED {
;	---------------------------------
; Function draw_menu
; ---------------------------------
	b_draw_menu	= 1
_draw_menu::
;src/gameplay.c:36: fill_bkg_rect(0, 0, 20, 18, 0x00);
	xor	a, a
	ld	h, a
	ld	l, #0x12
	push	hl
	ld	a, #0x14
	push	af
	inc	sp
	xor	a, a
	rrca
	push	af
	call	_fill_bkg_rect
	add	sp, #5
;src/gameplay.c:37: gotoxy(0, 0);
	xor	a, a
	rrca
	push	af
	call	_gotoxy
	pop	hl
;src/gameplay.c:38: printf("GBDASH DEMO 01\n\n");
	ld	de, #___str_1
	call	_puts
;src/gameplay.c:39: for (uint8_t i = 0; i < MAX_LEVELS; i++) {
	ld	c, #0x00
00106$:
	ld	a, (_MAX_LEVELS)
	ld	b, a
;src/gameplay.c:40: gotoxy(1, 2 + i);
	ld	a,c
	cp	a,b
	jr	NC, 00104$
	add	a, #0x02
	push	bc
	ld	h, a
	ld	l, #0x01
	push	hl
	call	_gotoxy
	pop	hl
	pop	bc
;src/gameplay.c:41: if (i == selected) printf("0 %s", game_levels[i]->name);
	ld	l, c
	ld	h, #0x00
	add	hl, hl
	ld	b, l
	ld	e, h
	ld	a, (#_selected)
	sub	a, c
	jr	NZ, 00102$
	ld	l, b
	ld	h, e
	ld	de, #_game_levels
	add	hl, de
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	push	bc
	push	hl
	ld	de, #___str_2
	push	de
	call	_printf
	add	sp, #4
	pop	bc
	jr	00107$
00102$:
;src/gameplay.c:42: else printf(" %s", game_levels[i]->name);
	ld	a, #<(_game_levels)
	add	a, b
	ld	l, a
	ld	a, #>(_game_levels)
	adc	a, e
	ld	h, a
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	push	bc
	push	hl
	ld	de, #___str_3
	push	de
	call	_printf
	add	sp, #4
	pop	bc
00107$:
;src/gameplay.c:39: for (uint8_t i = 0; i < MAX_LEVELS; i++) {
	inc	c
	jr	00106$
00104$:
;src/gameplay.c:44: SHOW_BKG;
	ldh	a, (_LCDC_REG + 0)
	or	a, #0x01
	ldh	(_LCDC_REG + 0), a
;src/gameplay.c:45: redraw = 0;
	xor	a, a
	ld	(#_redraw),a
;src/gameplay.c:46: }
	ret
___str_1:
	.ascii "GBDASH DEMO 01"
	.db 0x0a
	.db 0x00
___str_2:
	.ascii "0 %s"
	.db 0x00
___str_3:
	.ascii " %s"
	.db 0x00
;src/gameplay.c:48: void play_level(uint8_t idx) BANKED {
;	---------------------------------
; Function play_level
; ---------------------------------
	b_play_level	= 1
_play_level::
	add	sp, #-48
;src/gameplay.c:59: l = game_levels[idx];
	ld	bc, #_game_levels+0
	ldhl	sp,	#54
	ld	e, (hl)
	xor	a, a
	sla	e
	adc	a, a
	ldhl	sp,	#46
	ld	(hl), e
	inc	hl
	ld	(hl-), a
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	ld	a, (de)
	ldhl	sp,	#44
	ld	(hl+), a
	inc	de
	ld	a, (de)
;src/gameplay.c:60: level_tiles = l->tiles;
	ld	(hl-), a
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	inc	bc
	inc	bc
	ld	e, c
	ld	d, b
	ld	a, (de)
	ldhl	sp,	#39
	ld	(hl+), a
	inc	de
	ld	a, (de)
	ld	(hl), a
;src/gameplay.c:61: level_map = l->map;
	ldhl	sp,#44
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x0004
	add	hl, de
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	ld	a, (de)
	ldhl	sp,	#17
	ld	(hl+), a
	inc	de
	ld	a, (de)
	ld	(hl), a
;src/gameplay.c:62: level_tile_count = l->tile_count;
	ldhl	sp,#44
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x0006
	add	hl, de
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	ld	a, (de)
	ldhl	sp,	#41
	ld	(hl+), a
	inc	de
	ld	a, (de)
	ld	(hl), a
;src/gameplay.c:63: level_map_w = l->map_width;
	ldhl	sp,#44
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x0008
	add	hl, de
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	ld	a, (de)
	ldhl	sp,	#19
	ld	(hl+), a
	inc	de
	ld	a, (de)
	ld	(hl), a
;src/gameplay.c:64: level_map_h = l->map_height;
	ldhl	sp,#44
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x000a
	add	hl, de
	ld	c, l
	ld	b, h
	ld	e, c
	ld	d, b
	ld	a, (de)
	ldhl	sp,	#21
	ld	(hl+), a
	inc	de
	ld	a, (de)
	ld	(hl), a
;src/gameplay.c:65: level_tiles_bank = BANK(chr_gb);
	ldhl	sp,	#43
;src/gameplay.c:66: level_map_bank = l->map_bank;
	ld	a, #<(___bank_chr_gb)
	ld	(hl+), a
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x000e
	add	hl, de
	ld	c, l
	ld	b, h
	ld	a, (bc)
	ldhl	sp,	#23
	ld	(hl), a
;src/gameplay.c:69: NR52_REG = 0x80;
	ld	a, #0x80
	ldh	(_NR52_REG + 0), a
;src/gameplay.c:70: NR51_REG = 0xFF;
	ld	a, #0xff
	ldh	(_NR51_REG + 0), a
;src/gameplay.c:71: NR50_REG = 0x77;
	ld	a, #0x77
	ldh	(_NR50_REG + 0), a
;src/gameplay.c:74: if (level_songs[idx]) {
	ld	de, #_level_songs
	ldhl	sp,	#46
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	push	hl
	ld	a, l
	ldhl	sp,	#26
	ld	(hl), a
	pop	hl
	ld	a, h
	ldhl	sp,	#25
	ld	(hl-), a
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	a, (de)
	ld	c, a
	inc	de
	ld	a, (de)
	ld	b, a
	or	a, c
	jr	Z, 00102$
;src/gameplay.c:75: init_music_banked(level_songs[idx], song_bank[idx], l->timer_divider);
	ldhl	sp,#44
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x000f
	add	hl, de
	ld	e, l
	ld	d, h
	ld	a, (de)
	ldhl	sp,	#47
	ld	(hl), a
	ld	de, #_song_bank+0
	ldhl	sp,	#54
	ld	l, (hl)
	ld	h, #0x00
	add	hl, de
	ld	e, l
	ld	d, h
	ld	a, (de)
	push	de
	ldhl	sp,	#49
	ld	h, (hl)
	push	hl
	inc	sp
	ld	e, c
	ld	d, b
	call	_init_music_banked
	pop	de
;src/gameplay.c:76: current_song_bank = song_bank[idx];
	ld	a, (de)
	ld	(#_current_song_bank),a
;src/gameplay.c:77: music_ready = 1;
	ld	hl, #_music_ready
	ld	(hl), #0x01
00102$:
;src/gameplay.c:80: uint16_t cam_px = 0;
	xor	a, a
	ldhl	sp,	#46
	ld	(hl+), a
	ld	(hl), a
;src/gameplay.c:81: uint16_t cam_py = 112;
	ldhl	sp,	#26
	ld	a, #0x70
	ld	(hl+), a
	xor	a, a
	ld	(hl), a
;src/gameplay.c:82: uint16_t cam_py_max = (level_map_h << 4);
	ldhl	sp,	#21
	ld	a, (hl+)
	ld	c, (hl)
	add	a, a
	rl	c
	add	a, a
	rl	c
	add	a, a
	rl	c
	add	a, a
	rl	c
;src/gameplay.c:83: if (cam_py_max > 144u) cam_py_max -= 144u;
	ldhl	sp,	#37
	ld	(hl+), a
	ld	a, c
	ld	(hl-), a
	ld	a, #0x90
	sub	a, (hl)
	inc	hl
	ld	a, #0x00
	sbc	a, (hl)
	jr	NC, 00104$
	ldhl	sp,#37
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x0090
	ld	a, e
	sub	a, l
	ld	e, a
	ld	a, d
	sbc	a, h
	ld	c, e
	ldhl	sp,	#28
	ld	(hl), c
	inc	hl
	ld	(hl), a
	jr	00105$
00104$:
;src/gameplay.c:84: else cam_py_max = 0;
	xor	a, a
	ldhl	sp,	#28
	ld	(hl+), a
	ld	(hl), a
00105$:
;src/gameplay.c:85: uint16_t loaded_r = BKG_MT_W - 1;
	ldhl	sp,	#30
	ld	a, #0x0f
	ld	(hl+), a
	xor	a, a
	ld	(hl), a
;src/gameplay.c:91: player_init(&player, 0, 240);
	ld	hl, #4
	add	hl, sp
	ld	de, #0x00f0
	push	de
	ld	de, #0x0000
	push	de
	push	hl
	ld	e, #b_player_init
	ld	hl, #_player_init
	call	___sdcc_bcall_ehl
	add	sp, #6
;c:\gbdk\include\gb\gb.h:811: __asm__("di");
	di
;src/gameplay.c:95: DISPLAY_OFF;
	call	_display_off
;src/gameplay.c:96: load_bkg_tileset(level_tiles, level_tile_count, level_tiles_bank);
	ldhl	sp,	#43
	ld	a, (hl-)
	dec	hl
	push	af
	inc	sp
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ldhl	sp,	#40
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	call	_load_bkg_tileset
;src/gameplay.c:98: set_sprite_data(0, 8, icon1_tiles);
	ld	de, #_icon1_tiles
	push	de
	ld	hl, #0x800
	push	hl
	call	_set_sprite_data
	add	sp, #4
;src/gameplay.c:99: set_sprite_data(8, 4, ship_tiles);
	ld	de, #_ship_tiles
	push	de
	ld	hl, #0x408
	push	hl
	call	_set_sprite_data
	add	sp, #4
;c:\gbdk\include\gb\gb.h:1461: SCX_REG=x, SCY_REG=y;
	xor	a, a
	ldh	(_SCX_REG + 0), a
	ld	a, #0x70
	ldh	(_SCY_REG + 0), a
;src/gameplay.c:102: fill_scroll_bg(level_map, level_map_w, level_map_h, level_map_bank);
	ldhl	sp,	#23
	ld	a, (hl-)
	dec	hl
	push	af
	inc	sp
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	push	de
	ldhl	sp,	#22
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ldhl	sp,	#20
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	call	_fill_scroll_bg
;src/gameplay.c:104: BGP_REG = 0xE4;
	ld	a, #0xe4
	ldh	(_BGP_REG + 0), a
;src/gameplay.c:105: OBP0_REG = 0xE4;
	ld	a, #0xe4
	ldh	(_OBP0_REG + 0), a
;src/gameplay.c:106: SPRITES_8x16;
	ldh	a, (_LCDC_REG + 0)
	or	a, #0x04
	ldh	(_LCDC_REG + 0), a
;src/gameplay.c:108: SHOW_BKG;
	ldh	a, (_LCDC_REG + 0)
	or	a, #0x01
	ldh	(_LCDC_REG + 0), a
;src/gameplay.c:109: SHOW_SPRITES;
	ldh	a, (_LCDC_REG + 0)
	or	a, #0x02
	ldh	(_LCDC_REG + 0), a
;src/gameplay.c:110: DISPLAY_ON;
	ldh	a, (_LCDC_REG + 0)
	or	a, #0x80
	ldh	(_LCDC_REG + 0), a
;src/gameplay.c:112: TAC_REG = 0x04; // Start the timer metronome
	ld	a, #0x04
	ldh	(_TAC_REG + 0), a
;c:\gbdk\include\gb\gb.h:795: __asm__("ei");
	ei
;src/gameplay.c:117: uint16_t scroll_acc = 0;
	ldhl	sp,	#32
;src/gameplay.c:118: uint8_t prev_joy = 0;
	xor	a, a
	ld	(hl+), a
	ld	(hl), a
;src/gameplay.c:119: while (1) {
	ldhl	sp,	#54
	ld	a, (hl)
	dec	a
	ld	a, #0x01
	jr	Z, 00501$
	xor	a, a
00501$:
	ldhl	sp,	#34
	ld	(hl), a
	ldhl	sp,	#54
	ld	a, (hl)
	sub	a, #0x02
	ld	a, #0x01
	jr	Z, 00503$
	xor	a, a
00503$:
	ldhl	sp,	#35
	ld	(hl), a
	ldhl	sp,	#54
	ld	a, (hl)
	sub	a, #0x03
	ld	a, #0x01
	jr	Z, 00505$
	xor	a, a
00505$:
	ldhl	sp,	#36
	ld	(hl), a
	ldhl	sp,#44
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	hl, #0x000f
	add	hl, de
	push	hl
	ld	a, l
	ldhl	sp,	#39
	ld	(hl), a
	pop	hl
	ld	a, h
	ldhl	sp,	#38
	ld	(hl), a
	ld	de, #_song_bank
	ldhl	sp,	#54
	ld	l, (hl)
	ld	h, #0x00
	add	hl, de
	push	hl
	ld	a, l
	ldhl	sp,	#41
	ld	(hl), a
	pop	hl
	ld	a, h
	ldhl	sp,	#40
	ld	(hl), a
00185$:
;src/gameplay.c:120: uint8_t joy = joypad();
	call	_joypad
	ldhl	sp,	#45
	ld	(hl), a
;src/gameplay.c:121: if (joy & J_START) break;
	push	hl
	ldhl	sp,	#47
	bit	7, (hl)
	pop	hl
	jp	NZ, 00186$
;src/gameplay.c:124: if ((joy & J_B) && !(prev_joy & J_B)) {
	push	hl
	ldhl	sp,	#47
	bit	5, (hl)
	pop	hl
	jr	Z, 00109$
	push	hl
	ldhl	sp,	#35
	bit	5, (hl)
	pop	hl
	jr	NZ, 00109$
;src/gameplay.c:125: player_noclip = !player_noclip;
	ld	hl, #_player_noclip
	ld	a, (hl)
	sub	a, #0x01
	ld	a, #0x00
	rla
	ld	(hl), a
00109$:
;src/gameplay.c:127: prev_joy = joy;
	ldhl	sp,	#45
	ld	a, (hl)
	ldhl	sp,	#33
	ld	(hl), a
;src/gameplay.c:130: uint16_t px_prev = cam_px >> 4;
	ldhl	sp,#46
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
;src/gameplay.c:131: uint8_t needs_render = 0;
	ldhl	sp,	#42
;src/gameplay.c:132: uint16_t need_col = 0;
	xor	a, a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl), a
;src/gameplay.c:134: if (cam_px < ((level_map_w - VIEW_MT_W) << 4)) {
	ldhl	sp,	#19
	ld	a, (hl+)
	ld	e, (hl)
	add	a, #0xf6
	ld	l, a
	ld	a, e
	adc	a, #0xff
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, l
	ld	d, h
	ldhl	sp,	#46
	ld	a, (hl)
	ldhl	sp,	#2
	ld	(hl), a
	ldhl	sp,	#47
	ld	a, (hl)
	ldhl	sp,	#3
	ld	(hl-), a
	ld	a, (hl+)
	sub	a, e
	ld	a, (hl)
	sbc	a, d
	jr	NC, 00117$
;src/gameplay.c:135: scroll_acc += SCROLL_SPEED_FP;
	ldhl	sp,	#32
	ld	e, (hl)
	ld	d, #0x00
	ld	hl, #0x035c
	add	hl, de
	ld	e, l
	ld	d, h
;src/gameplay.c:136: cam_px += scroll_acc >> 8;
	ldhl	sp,	#2
	ld	a, d
	ld	(hl+), a
	xor	a, a
	ld	(hl-), a
	push	de
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp,	#48
	ld	a,	(hl+)
	ld	h, (hl)
	ld	l, a
	add	hl, de
	pop	de
	push	hl
	ld	a, l
	ldhl	sp,	#48
	ld	(hl), a
	pop	hl
	ld	a, h
	ldhl	sp,	#47
	ld	(hl), a
;src/gameplay.c:137: scroll_acc &= 0xFF;
	ldhl	sp,	#32
	ld	(hl), e
;src/gameplay.c:138: uint16_t px_curr = cam_px >> 4;
	ldhl	sp,#46
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
;src/gameplay.c:139: if (px_curr != px_prev) {
	ld	a, e
	sub	a, c
	jr	NZ, 00511$
	ld	a, d
	sub	a, b
	jr	Z, 00117$
00511$:
;src/gameplay.c:140: uint16_t need = px_curr + VIEW_MT_W;
	ld	hl, #0x000a
	add	hl, de
	ld	c, l
	ld	b, h
;src/gameplay.c:141: if (need > loaded_r && need < level_map_w) {
	ldhl	sp,	#30
	ld	a, (hl+)
	sub	a, c
	ld	a, (hl)
	sbc	a, b
	jr	NC, 00117$
	ldhl	sp,	#19
	ld	a, c
	sub	a, (hl)
	inc	hl
	ld	a, b
	sbc	a, (hl)
	jr	NC, 00117$
;src/gameplay.c:142: needs_render = 1;
	ldhl	sp,	#42
;src/gameplay.c:143: need_col = need;
	ld	a, #0x01
	ld	(hl+), a
	ld	a, c
	ld	(hl+), a
	ld	(hl), b
00117$:
;src/gameplay.c:148: player.world_x = cam_px;
	ldhl	sp,	#46
	ld	a, (hl)
	ldhl	sp,	#4
	ld	(hl), a
	ldhl	sp,	#47
	ld	a, (hl)
	ldhl	sp,	#5
	ld	(hl), a
;src/gameplay.c:151: if (idx == 0) {
	ldhl	sp,	#54
	ld	a, (hl)
	or	a, a
	jr	NZ, 00127$
;src/gameplay.c:152: uint16_t col = (player.world_x + 8) >> 4;
	ldhl	sp,	#4
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ld	hl, #0x0008
	add	hl, bc
	xor	a, a
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	ld	b, a
;src/gameplay.c:153: if (col == 266) player.mode = MODE_SHIP; // 266
	ld	c, h
	ld	a, c
	sub	a, #0x0a
	jr	NZ, 00124$
	ld	a, b
	dec	a
	jr	NZ, 00124$
	ldhl	sp,	#13
	ld	(hl), #0x01
	jr	00127$
00124$:
;src/gameplay.c:154: else if (col == 418) player.mode = MODE_CUBE;
	ld	a, c
	sub	a, #0xa2
	jr	NZ, 00121$
	ld	a, b
	dec	a
	jr	NZ, 00121$
	ldhl	sp,	#13
	ld	(hl), #0x00
	jr	00127$
00121$:
;src/gameplay.c:155: else if (col == 763) player.mode = MODE_SHIP;
	ld	a, c
	sub	a, #0xfb
	jr	NZ, 00127$
	ld	a, b
	sub	a, #0x02
	jr	NZ, 00127$
	ldhl	sp,	#13
	ld	(hl), #0x01
00127$:
;src/gameplay.c:158: if (idx == 1) {
	ldhl	sp,	#34
	ld	a, (hl)
	or	a, a
	jr	Z, 00134$
;src/gameplay.c:159: uint16_t col = (player.world_x + 8) >> 4;
	ldhl	sp,	#4
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ld	hl, #0x0008
	add	hl, bc
	xor	a, a
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	ld	b, a
;src/gameplay.c:160: if (col == 421) player.mode = MODE_SHIP;
	ld	c, h
	ld	a, c
	sub	a, #0xa5
	jr	NZ, 00131$
	ld	a, b
	dec	a
	jr	NZ, 00131$
	ldhl	sp,	#13
	ld	(hl), #0x01
	jr	00134$
00131$:
;src/gameplay.c:161: else if (col == 559) player.mode = MODE_CUBE;
	ld	a, c
	sub	a, #0x2f
	jr	NZ, 00134$
	ld	a, b
	sub	a, #0x02
	jr	NZ, 00134$
	ldhl	sp,	#13
	ld	(hl), #0x00
00134$:
;src/gameplay.c:164: if (idx == 2) {
	ldhl	sp,	#35
	ld	a, (hl)
	or	a, a
	jr	Z, 00141$
;src/gameplay.c:165: uint16_t col = (player.world_x + 8) >> 4;
	ldhl	sp,	#4
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ld	hl, #0x0008
	add	hl, bc
	xor	a, a
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	ld	b, a
;src/gameplay.c:166: if (col == 321) player.mode = MODE_SHIP;
	ld	c, h
	ld	a, c
	sub	a, #0x41
	jr	NZ, 00138$
	ld	a, b
	dec	a
	jr	NZ, 00138$
	ldhl	sp,	#13
	ld	(hl), #0x01
	jr	00141$
00138$:
;src/gameplay.c:167: else if (col == 443) player.mode = MODE_CUBE;
	ld	a, c
	sub	a, #0xbb
	jr	NZ, 00141$
	dec	b
	jr	NZ, 00141$
	ldhl	sp,	#13
	ld	(hl), #0x00
00141$:
;src/gameplay.c:170: if (idx == 3) {
	ldhl	sp,	#36
	ld	a, (hl)
	or	a, a
	jr	Z, 00154$
;src/gameplay.c:171: uint16_t col = (player.world_x + 8) >> 4;
	ldhl	sp,	#4
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ld	hl, #0x0008
	add	hl, bc
	xor	a, a
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	add	hl, hl
	rla
	ld	b, a
;src/gameplay.c:172: if (col == 292) player.gravity_flipped = 1;
	ld	c, h
	ld	a, c
	sub	a, #0x24
	jr	NZ, 00151$
	ld	a, b
	dec	a
	jr	NZ, 00151$
	ldhl	sp,	#12
	ld	(hl), #0x01
	jr	00154$
00151$:
;src/gameplay.c:173: else if (col == 429) player.gravity_flipped = 0;
	ld	a, c
	sub	a, #0xad
	jr	NZ, 00148$
	ld	a, b
	dec	a
	jr	NZ, 00148$
	ldhl	sp,	#12
	ld	(hl), #0x00
	jr	00154$
00148$:
;src/gameplay.c:174: else if (col == 566) player.mode = MODE_SHIP;
	ld	a, c
	sub	a, #0x36
	jr	NZ, 00145$
	ld	a, b
	sub	a, #0x02
	jr	NZ, 00145$
	ldhl	sp,	#13
	ld	(hl), #0x01
	jr	00154$
00145$:
;src/gameplay.c:175: else if (col == 707) player.mode = MODE_CUBE;
	ld	a, c
	sub	a, #0xc3
	jr	NZ, 00154$
	ld	a, b
	sub	a, #0x02
	jr	NZ, 00154$
	ldhl	sp,	#13
	ld	(hl), #0x00
00154$:
;src/gameplay.c:91: player_init(&player, 0, 240);
;src/gameplay.c:179: died = player_update(&player, joy, level_map, level_map_w, level_map_h, level_map_bank);
	ldhl	sp,	#23
	ld	a, (hl-)
	dec	hl
	push	af
	inc	sp
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	push	de
	ldhl	sp,	#22
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	push	de
	ldhl	sp,	#22
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	push	de
	ldhl	sp,	#52
	ld	a, (hl)
	push	af
	inc	sp
	ld	hl, #12
	add	hl, sp
	ld	e, l
	ld	d, h
	push	de
	ld	e, #b_player_update
	ld	hl, #_player_update
	call	___sdcc_bcall_ehl
	add	sp, #10
	ldhl	sp,	#41
	ld	(hl), a
;src/gameplay.c:182: py = player_screen_y(&player, cam_py);
	ldhl	sp,	#26
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	ld	hl, #6
	add	hl, sp
	ld	e, l
	ld	d, h
	push	de
	ld	e, #b_player_screen_y
	ld	hl, #_player_screen_y
	call	___sdcc_bcall_ehl
;src/gameplay.c:183: if (py < CAM_Y_TOP_ZONE) {
	add	sp, #6
	push	bc
;src/gameplay.c:186: if ((uint16_t)target_cam_py > cam_py_max) target_cam_py = (int16_t)cam_py_max;
	ldhl	sp,	#28
	ld	a, (hl)
	ldhl	sp,	#2
	ld	(hl), a
	ldhl	sp,	#29
	ld	a, (hl)
	ldhl	sp,	#3
	ld	(hl), a
;src/gameplay.c:183: if (py < CAM_Y_TOP_ZONE) {
	ldhl	sp,	#0
	ld	a, (hl+)
	sub	a, #0x14
	ld	a, (hl)
	sbc	a, #0x00
	ld	d, (hl)
	ld	a, #0x00
	bit	7,a
	jr	Z, 00534$
	bit	7, d
	jr	NZ, 00535$
	cp	a, a
	jr	00535$
00534$:
	bit	7, d
	jr	Z, 00535$
	scf
00535$:
	jr	NC, 00166$
;src/gameplay.c:184: int16_t target_cam_py = player.world_y - CAM_Y_TOP_ZONE;
	ldhl	sp,	#6
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ld	a, c
	add	a, #0xec
	ld	c, a
	ld	a, b
	adc	a, #0xff
	ldhl	sp,	#26
	ld	(hl), c
	inc	hl
;src/gameplay.c:185: if (target_cam_py < 0) target_cam_py = 0;
	ld	(hl-), a
	ld	a, (hl+)
	bit	7, (hl)
	jr	Z, 00156$
	dec	hl
	xor	a, a
	ld	(hl+), a
	ld	(hl), a
00156$:
;src/gameplay.c:186: if ((uint16_t)target_cam_py > cam_py_max) target_cam_py = (int16_t)cam_py_max;
	ldhl	sp,	#26
	ld	a, (hl+)
	ld	c, a
	ld	a, (hl+)
	ld	b, a
	ld	a, (hl+)
	sub	a, c
	ld	a, (hl)
	sbc	a, b
	jr	NC, 00167$
	ldhl	sp,	#2
	ld	a, (hl)
	ldhl	sp,	#26
	ld	(hl), a
	ldhl	sp,	#3
	ld	a, (hl)
	ldhl	sp,	#27
	ld	(hl), a
;src/gameplay.c:187: cam_py = (uint16_t)target_cam_py;
	jr	00167$
00166$:
;src/gameplay.c:188: } else if (py > CAM_Y_BOTTOM_ZONE) {
	ldhl	sp,	#0
	ld	a, #0x64
	sub	a, (hl)
	inc	hl
	ld	a, #0x00
	sbc	a, (hl)
	jr	NC, 00167$
;src/gameplay.c:189: int16_t target_cam_py = player.world_y - CAM_Y_BOTTOM_ZONE;
	ldhl	sp,	#6
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ld	a, c
	add	a, #0x9c
	ld	c, a
	ld	a, b
	adc	a, #0xff
	ld	b, a
;src/gameplay.c:190: if (target_cam_py < 0) target_cam_py = 0;
	ld	h, b
	bit	7, h
	jr	Z, 00160$
	ld	bc, #0x0000
00160$:
;src/gameplay.c:191: if ((uint16_t)target_cam_py > cam_py_max) target_cam_py = (int16_t)cam_py_max;
	ld	e, c
	ld	d, b
	ldhl	sp,	#28
	ld	a, (hl+)
	sub	a, e
	ld	a, (hl)
	sbc	a, d
	jr	NC, 00162$
	ldhl	sp,	#2
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
00162$:
;src/gameplay.c:192: cam_py = (uint16_t)target_cam_py;
	ldhl	sp,	#26
	ld	a, c
	ld	(hl+), a
	ld	(hl), b
00167$:
;src/gameplay.c:134: if (cam_px < ((level_map_w - VIEW_MT_W) << 4)) {
	ldhl	sp,	#46
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
;src/gameplay.c:196: uint16_t scroll_px = (cam_px > PLAYER_SCREEN_X) ? (cam_px - PLAYER_SCREEN_X) : 0;
	ld	a, #0x20
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jr	NC, 00206$
	ld	a, c
	add	a, #0xe0
	ld	e, a
	jr	00207$
00206$:
	ld	e, #0x00
00207$:
;src/gameplay.c:197: uint8_t sprite_x = (cam_px < PLAYER_SCREEN_X) ? (uint8_t)cam_px : PLAYER_SCREEN_X;
	ld	a, c
	sub	a, #0x20
	ld	a, b
	sbc	a, #0x00
	jr	NC, 00208$
	ldhl	sp,	#46
	ld	a, (hl)
	jr	00209$
00208$:
	ld	a, #0x20
00209$:
	ldhl	sp,	#45
	ld	(hl), a
;src/gameplay.c:198: int16_t final_py = player_screen_y(&player, cam_py);
	push	de
	ldhl	sp,	#28
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	ld	hl, #8
	add	hl, sp
	ld	c, l
	ld	b, h
	push	bc
	ld	e, #b_player_screen_y
	ld	hl, #_player_screen_y
	call	___sdcc_bcall_ehl
	add	sp, #4
	pop	de
;src/gameplay.c:201: wait_vbl_done();
	call	_wait_vbl_done
;src/gameplay.c:204: move_bkg((uint8_t)scroll_px, (uint8_t)cam_py);
	ldhl	sp,	#26
	ld	d, (hl)
	ld	a, e
	ldh	(_SCX_REG + 0), a
;c:\gbdk\include\gb\gb.h:1461: SCX_REG=x, SCY_REG=y;
	ld	a, d
	ldh	(_SCY_REG + 0), a
;src/gameplay.c:206: if (needs_render) {
	ldhl	sp,	#42
	ld	a, (hl)
	or	a, a
	jr	Z, 00169$
;src/gameplay.c:207: loaded_r = need_col;
	inc	hl
	ld	a, (hl)
	ldhl	sp,	#30
	ld	(hl), a
	ldhl	sp,	#44
	ld	a, (hl)
	ldhl	sp,	#31
	ld	(hl), a
;src/gameplay.c:208: draw_mt_column((uint8_t)(need_col % BKG_MT_W), need_col, level_map, level_map_w, level_map_h, level_map_bank);
	ldhl	sp,	#43
	ld	a, (hl+)
	ld	e, (hl)
	and	a, #0x0f
	push	bc
	ldhl	sp,	#25
	ld	h, (hl)
	push	hl
	inc	sp
	ldhl	sp,	#24
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	ldhl	sp,	#24
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	ldhl	sp,	#24
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	ldhl	sp,	#52
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	call	_draw_mt_column
	pop	bc
00169$:
;src/gameplay.c:211: if (player.mode == MODE_SHIP) {
	ldhl	sp,	#13
	ld	a, (hl)
	ldhl	sp,	#42
	ld	(hl), a
;src/gameplay.c:213: move_metasprite_vflip(ship_metasprites[0], 0, 0, sprite_x + 8, final_py + 16);
	ldhl	sp,	#45
	ld	a, (hl-)
	dec	hl
	ld	(hl+), a
	ld	a, c
	add	a, #0x10
	ld	(hl-), a
	ld	a, (hl+)
	inc	hl
	add	a, #0x08
	ld	(hl), a
;src/gameplay.c:211: if (player.mode == MODE_SHIP) {
	ldhl	sp,	#42
	ld	a, (hl)
	dec	a
	jr	NZ, 00177$
;src/gameplay.c:212: if (player.gravity_flipped) {
	ldhl	sp,	#12
	ld	a, (hl)
	or	a, a
	jr	Z, 00171$
;src/gameplay.c:213: move_metasprite_vflip(ship_metasprites[0], 0, 0, sprite_x + 8, final_py + 16);
	ldhl	sp,	#44
	ld	a, (hl+)
	ld	b, a
	ld	c, (hl)
	ld	hl, #_ship_metasprites
	ld	a,	(hl+)
	ld	h, (hl)
;c:\gbdk\include\gb\metasprites.h:209: __current_metasprite = metasprite;
	ld	e, a
	ld	d, h
	ld	hl, #___current_metasprite
	ld	a, e
	ld	(hl+), a
	ld	(hl), d
;c:\gbdk\include\gb\metasprites.h:210: __current_base_tile = base_tile;
;c:\gbdk\include\gb\metasprites.h:211: __current_base_prop = 0;
	xor	a, a
	ld	(#___current_base_tile), a
	ld	(#___current_base_prop),a
;c:\gbdk\include\gb\metasprites.h:212: return __move_metasprite_vflip(base_sprite, (y << 8) | (uint8_t)(x - 8u));
	ld	d, b
	ld	a, c
	add	a, #0xf8
	ld	e, a
	xor	a, a
	call	___move_metasprite_vflip
;src/gameplay.c:213: move_metasprite_vflip(ship_metasprites[0], 0, 0, sprite_x + 8, final_py + 16);
	jr	00178$
00171$:
;src/gameplay.c:215: move_metasprite(ship_metasprites[0], 0, 0, sprite_x + 8, final_py + 16);
	ldhl	sp,	#44
	ld	a, (hl+)
	ld	b, a
	ld	c, (hl)
	ld	hl, #_ship_metasprites
	ld	a,	(hl+)
	ld	h, (hl)
;c:\gbdk\include\gb\metasprites.h:169: __current_metasprite = metasprite;
	ld	e, a
	ld	d, h
	ld	hl, #___current_metasprite
	ld	a, e
	ld	(hl+), a
	ld	(hl), d
;c:\gbdk\include\gb\metasprites.h:170: __current_base_tile = base_tile;
;c:\gbdk\include\gb\metasprites.h:171: __current_base_prop = 0;
	xor	a, a
	ld	(#___current_base_tile), a
	ld	(#___current_base_prop),a
;c:\gbdk\include\gb\metasprites.h:172: return __move_metasprite(base_sprite, (y << 8) | (uint8_t)x);
	ld	d, b
	ld	e, c
	xor	a, a
	call	___move_metasprite
;src/gameplay.c:215: move_metasprite(ship_metasprites[0], 0, 0, sprite_x + 8, final_py + 16);
	jr	00178$
00177$:
;src/gameplay.c:218: if (player.gravity_flipped) {
	ldhl	sp,	#12
	ld	a, (hl)
	or	a, a
	jr	Z, 00174$
;src/gameplay.c:219: move_metasprite_vflip(icon1_metasprites[player.anim_frame], 0, 0, sprite_x + 22, final_py + 16);
	ldhl	sp,	#44
	ld	a, (hl-)
	ld	b, a
	ld	a, (hl)
	add	a, #0x16
	ld	c, a
	ldhl	sp,	#14
	ld	l, (hl)
	ld	h, #0x00
	add	hl, hl
	ld	de, #_icon1_metasprites
	add	hl, de
	ld	a, (hl+)
	ld	l, (hl)
;c:\gbdk\include\gb\metasprites.h:209: __current_metasprite = metasprite;
	ld	e, a
	ld	d, l
	ld	hl, #___current_metasprite
	ld	a, e
	ld	(hl+), a
	ld	(hl), d
;c:\gbdk\include\gb\metasprites.h:210: __current_base_tile = base_tile;
;c:\gbdk\include\gb\metasprites.h:211: __current_base_prop = 0;
	xor	a, a
	ld	(#___current_base_tile), a
	ld	(#___current_base_prop),a
;c:\gbdk\include\gb\metasprites.h:212: return __move_metasprite_vflip(base_sprite, (y << 8) | (uint8_t)(x - 8u));
	ld	d, b
	ld	a, c
	add	a, #0xf8
	ld	e, a
	xor	a, a
	call	___move_metasprite_vflip
;src/gameplay.c:219: move_metasprite_vflip(icon1_metasprites[player.anim_frame], 0, 0, sprite_x + 22, final_py + 16);
	jr	00178$
00174$:
;src/gameplay.c:221: move_metasprite(icon1_metasprites[player.anim_frame], 0, 0, sprite_x + 8, final_py + 16);
	ldhl	sp,	#44
	ld	a, (hl+)
	ld	b, a
	ld	c, (hl)
	ldhl	sp,	#14
	ld	l, (hl)
	ld	h, #0x00
	add	hl, hl
	ld	de, #_icon1_metasprites
	add	hl, de
	ld	a, (hl+)
	ld	l, (hl)
;c:\gbdk\include\gb\metasprites.h:169: __current_metasprite = metasprite;
	ld	e, a
	ld	d, l
	ld	hl, #___current_metasprite
	ld	a, e
	ld	(hl+), a
	ld	(hl), d
;c:\gbdk\include\gb\metasprites.h:170: __current_base_tile = base_tile;
;c:\gbdk\include\gb\metasprites.h:171: __current_base_prop = 0;
	xor	a, a
	ld	(#___current_base_tile), a
	ld	(#___current_base_prop),a
;c:\gbdk\include\gb\metasprites.h:172: return __move_metasprite(base_sprite, (y << 8) | (uint8_t)x);
	ld	d, b
	ld	e, c
	xor	a, a
	call	___move_metasprite
;src/gameplay.c:221: move_metasprite(icon1_metasprites[player.anim_frame], 0, 0, sprite_x + 8, final_py + 16);
00178$:
;src/gameplay.c:225: if (died) {
	ldhl	sp,	#41
	ld	a, (hl)
	or	a, a
	jp	Z, 00185$
;src/gameplay.c:226: TAC_REG = 0x00;   // Stop music timer immediately
	xor	a, a
	ldh	(_TAC_REG + 0), a
;src/gameplay.c:228: NR52_REG = 0x00; // Silence
	xor	a, a
	ldh	(_NR52_REG + 0), a
;src/gameplay.c:230: NR52_REG = 0x80; // Turn sound back ON
	ld	a, #0x80
	ldh	(_NR52_REG + 0), a
;src/gameplay.c:231: NR51_REG = 0xFF; // Route all channels to left and right
	ld	a, #0xff
	ldh	(_NR51_REG + 0), a
;src/gameplay.c:232: NR50_REG = 0x77; // Set master volume to max
	ld	a, #0x77
	ldh	(_NR50_REG + 0), a
;src/gameplay.c:234: NR41_REG = 0x00; // Length
	xor	a, a
	ldh	(_NR41_REG + 0), a
;src/gameplay.c:235: NR42_REG = 0xF2; // Volume
	ld	a, #0xf2
	ldh	(_NR42_REG + 0), a
;src/gameplay.c:236: NR43_REG = 0x43; // Note
	ld	a, #0x43
	ldh	(_NR43_REG + 0), a
;src/gameplay.c:237: NR44_REG = 0x80; // Trigger
	ld	a, #0x80
	ldh	(_NR44_REG + 0), a
;src/gameplay.c:239: for (uint8_t i = 0; i < 60; i++) wait_vbl_done();
	ld	c, #0x00
00202$:
	ld	a, c
	sub	a, #0x3c
	jr	NC, 00179$
	call	_wait_vbl_done
	inc	c
	jr	00202$
00179$:
;src/gameplay.c:240: NR52_REG = 0x80;
	ld	a, #0x80
	ldh	(_NR52_REG + 0), a
;src/gameplay.c:241: NR51_REG = 0xFF;
	ld	a, #0xff
	ldh	(_NR51_REG + 0), a
;src/gameplay.c:242: NR50_REG = 0x77;
	ld	a, #0x77
	ldh	(_NR50_REG + 0), a
;src/gameplay.c:244: if (level_songs[idx]) {
	ldhl	sp,#24
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	a, (de)
	ld	c, a
	inc	de
	ld	a, (de)
	ld	b, a
	or	a, c
	jr	Z, 00181$
;src/gameplay.c:245: init_music_banked(level_songs[idx], song_bank[idx], l->timer_divider);
	ldhl	sp,#37
	ld	a, (hl+)
	ld	e, a
	ld	a, (hl+)
	ld	d, a
	ld	a, (de)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	af
	ld	a, (de)
	inc	sp
	ld	e, c
	ld	d, b
	call	_init_music_banked
;src/gameplay.c:246: current_song_bank = song_bank[idx];
	ldhl	sp,#39
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	a, (de)
	ld	hl, #_current_song_bank
	ld	(hl), a
00181$:
;c:\gbdk\include\gb\gb.h:811: __asm__("di");
	di
;src/gameplay.c:250: cam_px = 0;
	xor	a, a
	ldhl	sp,	#46
	ld	(hl+), a
	ld	(hl), a
;src/gameplay.c:251: cam_py = 112;
	ldhl	sp,	#26
	ld	a, #0x70
	ld	(hl+), a
	xor	a, a
	ld	(hl), a
;src/gameplay.c:252: scroll_acc = 0;
	ldhl	sp,	#32
;src/gameplay.c:253: loaded_r = BKG_MT_W - 1;
	xor	a, a
	ld	(hl-), a
	dec	hl
	ld	a, #0x0f
	ld	(hl+), a
	xor	a, a
	ld	(hl), a
;src/gameplay.c:254: player_init(&player, 0, 240);
	ld	de, #0x00f0
	push	de
	ld	de, #0x0000
	push	de
	ld	hl, #8
	add	hl, sp
	ld	e, l
	ld	d, h
	push	de
	ld	e, #b_player_init
	ld	hl, #_player_init
	call	___sdcc_bcall_ehl
	add	sp, #6
;c:\gbdk\include\gb\gb.h:1461: SCX_REG=x, SCY_REG=y;
	xor	a, a
	ldh	(_SCX_REG + 0), a
	ld	a, #0x70
	ldh	(_SCY_REG + 0), a
;src/gameplay.c:256: fill_scroll_bg(level_map, level_map_w, level_map_h, level_map_bank);
	ldhl	sp,	#23
	ld	a, (hl-)
	dec	hl
	push	af
	inc	sp
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	push	de
	ldhl	sp,	#22
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ldhl	sp,	#20
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	call	_fill_scroll_bg
;src/gameplay.c:258: TAC_REG = 0x04;
	ld	a, #0x04
	ldh	(_TAC_REG + 0), a
;src/gameplay.c:259: music_ready = 1;
	ld	hl, #_music_ready
	ld	(hl), #0x01
;c:\gbdk\include\gb\gb.h:795: __asm__("ei");
	ei
;src/gameplay.c:260: enable_interrupts();
	jp	00185$
00186$:
;src/gameplay.c:265: HIDE_SPRITES;
	ldh	a, (_LCDC_REG + 0)
	and	a, #0xfd
	ldh	(_LCDC_REG + 0), a
;c:\gbdk\include\gb\gb.h:1461: SCX_REG=x, SCY_REG=y;
	xor	a, a
	ldh	(_SCX_REG + 0), a
	xor	a, a
	ldh	(_SCY_REG + 0), a
;src/gameplay.c:267: waitpadup();
	call	_waitpadup
;c:\gbdk\include\gb\gb.h:811: __asm__("di");
	di
;src/gameplay.c:269: setup_menu_font();
	ld	e, #b_setup_menu_font
	ld	hl, #_setup_menu_font
	call	___sdcc_bcall_ehl
;c:\gbdk\include\gb\gb.h:795: __asm__("ei");
	ei
;src/gameplay.c:271: redraw = 1;
	ld	hl, #_redraw
	ld	(hl), #0x01
;src/gameplay.c:272: }
	add	sp, #48
	ret
	.area _CODE_1
	.area _INITIALIZER
	.area _CABS (ABS)
