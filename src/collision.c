#include <gb/gb.h>
#include "collision.h"
#include "famidash_metatiles.h"

#define BKG_MT_H 16

// This function must be in BANK 0
uint8_t col_at(
    uint16_t world_px,
    int16_t  world_py,
    const uint8_t *map,
    uint16_t map_w,
    uint16_t map_h,
    uint8_t  map_bank
) {
    if (world_py < 0) return COL_NONE;
    uint16_t mx = world_px >> 4;
    uint16_t my = (uint16_t)world_py >> 4;

    if (mx >= map_w || my >= map_h) return COL_ALL;

    uint8_t col;
    uint8_t _prev = _current_bank;
    SWITCH_ROM(map_bank);
    col = famidash_metatile_collision[map[(uint16_t)my * map_w + mx]];
    SWITCH_ROM(_prev);

    if (col == COL_DEATH_TOP_HALF) {
        if (((uint16_t)world_py & 0x0F) < 8) return COL_NONE;
        return COL_DEATH;
    }
    if (col == COL_DEATH_BOTTOM_HALF) {
        if (((uint16_t)world_py & 0x0F) >= 8) return COL_NONE;
        return COL_DEATH;
    }

    return col;
}

// Loads tileset into VRAM. Handles splitting if tiles > 128.
// Also in Bank 0 because the 'tiles' pointer might be in another bank.
void load_bkg_tileset(const uint8_t* tiles, uint16_t tile_count, uint8_t bank) {
  uint8_t _prev = _current_bank;
  SWITCH_ROM(bank);
  if (tile_count == 256u) {
    set_bkg_data(0, 128, tiles);
    set_bkg_data(128, 128, tiles + (128u * 16u));
  } else {
    set_bkg_data(0, (uint8_t)tile_count, tiles);
  }
  SWITCH_ROM(_prev);
}

void draw_mt_column(uint8_t ring_col, uint16_t map_col,
  const uint8_t* map, uint16_t map_w, uint16_t map_h,
  uint8_t map_bank) {

  uint8_t bx = ring_col << 1;

  uint8_t _prev = _current_bank;
  SWITCH_ROM(map_bank);

  for (uint8_t r = 0; r < map_h && r < BKG_MT_H; r++) {
    uint8_t mt = map[(uint16_t)r * map_w + map_col];
    uint8_t by = (r & (BKG_MT_H - 1)) << 1;

    set_bkg_tiles(bx, by, 2, 1, &metatiles[mt][0]);
    set_bkg_tiles(bx, by + 1, 2, 1, &metatiles[mt][2]);
  }

  SWITCH_ROM(_prev);
}

void fill_scroll_bg(const uint8_t* map, uint16_t map_w, uint16_t map_h, uint8_t map_bank) {
  uint16_t cols = (map_w < 16) ? map_w : 16;
  for (uint16_t c = 0; c < cols; c++) {
    draw_mt_column((uint8_t)(c % 16), c, map, map_w, map_h, map_bank);
  }
}

#include "hUGEDriver.h"
extern uint8_t music_ready;
extern uint8_t current_song_bank;

void init_music_banked(const hUGESong_t * song, uint8_t bank, uint8_t divider) {
    uint8_t _prev = _current_bank;
    music_ready = 0;
    current_song_bank = bank;
    SWITCH_ROM(bank);
    disable_interrupts();
    hUGE_init(song);
    TMA_REG = divider;
    enable_interrupts();
    SWITCH_ROM(_prev);
    music_ready = 1;
}
