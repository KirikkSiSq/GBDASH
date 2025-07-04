#include <gb/gb.h>
#include <gb/cgb.h>
#include <stdint.h>
#include "menuscreen.h"
#include "tiles.c"
#include "tileset.c"
#include "gb-madness.h"
#include "register.h"
#include "metatiles.h"
#include <gbdk/platform.h>
#include <gbdk/metasprites.h>
#include "icon1.h"

// Constantes físicas
#define SCALE 1000
#define GRAVITY_PER_FRAME 7       // 0.007 px/frame² escalado
#define JUMP_VELOCITY -580        // Salto que sube 24 px
#define GROUND_Y 72               // Piso (en píxeles)

// Variables de física
int32_t cube_y = GROUND_Y * SCALE;
int32_t velocity_y = 0;
uint8_t is_jumping = 0;

// --- Variables globales necesarias para la animación ---
static uint8_t x = 80;
static uint8_t frame = 0;

void set_metatile_xy(uint8_t bx, uint8_t by, uint8_t midx) {
    const unsigned char *mt = metatiles[midx];
    set_bkg_tiles(bx,     by,     1, 1, &mt[0]);
    set_bkg_tiles(bx + 1, by,     1, 1, &mt[1]);
    set_bkg_tiles(bx,     by + 1, 1, 1, &mt[2]);
    set_bkg_tiles(bx + 1, by + 1, 1, 1, &mt[3]);
}

static void setup(void) {
    stopall();

    SPRITES_8x16;
    SHOW_SPRITES;

    set_bkg_data(0, 64, tiles_tiles);

    uint16_t idx = 0;
    for (uint8_t by = 0; by < LEVEL_MAP_HEIGHT; by++) {
        for (uint8_t bx = 0; bx < LEVEL_MAP_WIDTH; bx++) {
            uint8_t m = level_map[idx++];
            if (m < NUM_METATILES) {
                set_metatile_xy(bx * 2, by * 2, m);
            }
        }
    }

    SHOW_BKG;

    set_sprite_palette(0, icon1_PALETTE_COUNT, icon1_palettes);
    set_sprite_data(icon1_TILE_ORIGIN, icon1_TILE_COUNT, icon1_tiles);

    move_metasprite(icon1_metasprites[frame], icon1_TILE_ORIGIN, 0, x, cube_y / SCALE);

    play(1);
}

void update_physics(void) {
    velocity_y += GRAVITY_PER_FRAME;
    cube_y += velocity_y;

    if (cube_y >= GROUND_Y * SCALE) {
        cube_y = GROUND_Y * SCALE;
        velocity_y = 0;
        is_jumping = 0;
    }
}

void handle_jump(uint8_t joy) {
    if ((joy & J_A) && !is_jumping) {
        velocity_y = JUMP_VELOCITY;
        is_jumping = 1;
    }
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
        update_physics();

        hide_metasprite(icon1_metasprites[frame], 0);

        frame++;
        if (frame >= 24) frame = 0;

        move_metasprite(icon1_metasprites[frame], icon1_TILE_ORIGIN, 0, x, cube_y / SCALE);

        delay(16);         // Aprox 60 FPS
        wait_vbl_done();
    }
}
