#include <gb/gb.h>
#include <gb/cgb.h>
#include <stdint.h>
#include "menuscreen.h"
#include "tiles.h"
#include "tileset.h"
#include "gb-madness.h"
#include "register.h"
#include "metatiles.h"
#include <gbdk/platform.h>
#include <gbdk/metasprites.h>
#include "icon1.h"
#include "physics.h"
#include "vram_loader.h"

static uint8_t frame = 0;

uint16_t current_loaded_map_x = 0;
uint16_t current_loaded_map_y = 0;

const unsigned int background_palette[] = {
    0x7FFF,
    0x5294,
    0x2A52,
    0x0000
};

void load_map_segment(uint16_t map_start_x_tiles, uint16_t map_start_y_tiles) {
    current_loaded_map_x = map_start_x_tiles;
    current_loaded_map_y = map_start_y_tiles;

    for (uint8_t by_vram = 0; by_vram < BKG_MAP_HEIGHT_TILES; by_vram++) {
        for (uint8_t bx_vram = 0; bx_vram < BKG_MAP_WIDTH_TILES; bx_vram++) {
            uint16_t full_map_tile_x = map_start_x_tiles + bx_vram;
            uint16_t full_map_tile_y = map_start_y_tiles + by_vram;

            uint8_t tile_idx_to_load = 0;

            if (full_map_tile_x < MAP_TILE_WIDTH && full_map_tile_y < MAP_TILE_HEIGHT) {
                uint8_t metatile_x = full_map_tile_x / 2;
                uint8_t metatile_y = full_map_tile_y / 2;
                uint8_t metatile_idx = level_map[metatile_y * LEVEL_MAP_WIDTH + metatile_x];

                if (metatile_idx < NUM_METATILES) {
                    const unsigned char *mt = metatiles[metatile_idx];
                    if ((full_map_tile_y % 2) == 0) {
                        tile_idx_to_load = (full_map_tile_x % 2) ? mt[1] : mt[0];
                    } else {
                        tile_idx_to_load = (full_map_tile_x % 2) ? mt[3] : mt[2];
                    }
                }
            }
            vram_loader_enqueue(JOB_TILEMAP, bx_vram, by_vram, 1, 1, &tile_idx_to_load);
        }
    }
}

static void setup(void) {
    stopall();
    SPRITES_8x16;
    SHOW_SPRITES;

    set_bkg_data(0, 64, tiles_tiles);
    set_bkg_palette(0, 1, background_palette);

    load_map_segment(0, 0); 
    SHOW_BKG;

    set_sprite_palette(0, icon1_PALETTE_COUNT, icon1_palettes);
    set_sprite_data(icon1_TILE_ORIGIN, icon1_TILE_COUNT, icon1_tiles);

    play(1);
}

void dolevel(void) {
    fade(setup);

    while (1) {
        uint8_t joy = joypad();

        if (joy & J_START) {
            HIDE_SPRITES;
            domenu();
            break;
        }

        handle_jump(joy);
        handle_horizontal_movement(joy);
        update_physics();
        
        hide_metasprite(icon1_metasprites[frame], 0);

        frame = (frame + 1);
        if (frame >= 25) frame = 0; 

        move_metasprite(icon1_metasprites[frame], icon1_TILE_ORIGIN, 0,
                        cube_x_pixel + 10,
                        (cube_y / SCALE) + 16);

        vram_loader_process();   // process queued jobs

        wait_vbl_done();
    }
}