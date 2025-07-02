#include <gb/gb.h>
#include <stdint.h>
#include "menuscreen.h"
#include "tiles.c"
#include "tileset.c"
#include "physics.h"
#include "gb-madness.h"
#include "register.h"
#include "metatiles.h"

// Dibuja un metatile de 2×2 tiles en coordenadas (btiles) x,y
void set_metatile_xy(uint8_t bx, uint8_t by, uint8_t midx) {
    const unsigned char *mt = metatiles[midx];
    set_bkg_tiles(bx,     by,     1, 1, &mt[0]);
    set_bkg_tiles(bx + 1, by,     1, 1, &mt[1]);
    set_bkg_tiles(bx,     by + 1, 1, 1, &mt[2]);
    set_bkg_tiles(bx + 1, by + 1, 1, 1, &mt[3]);
}

static void setup(void) {
    stopall();

    // Carga los datos de tiles (64 tiles, ajusta si tienes otro número)
    set_bkg_data(0, 64, tiles_tiles);

    // Pinta el mapa completo con metatiles
    uint16_t idx = 0;
    for (uint8_t y = 0; y < LEVEL_MAP_HEIGHT; y++) {
        for (uint8_t x = 0; x < LEVEL_MAP_WIDTH; x++) {
            uint8_t m = level_map[idx++];
            if (m < NUM_METATILES) {
                set_metatile_xy(x * 2, y * 2, m);
            }
        }
    }

    SHOW_BKG;
    set_sprite_data(0, 2, TileLabel);
    set_sprite_tile(0, 0);
    player_x = 0;
    player_y = 0;
    x_pos = 0;
    y_pos = GROUND_Y << MODIFIER_SHIFT;
    scroll_x = 0;
    move_sprite(0, player_x, player_y);
    SHOW_SPRITES;
    play(1);
}

void dolevel(void) {
    fade(setup);

    while (1) {
        uint8_t joy = joypad();

        if (joy & (J_A | J_UP)) {
            jump();
        }
        if (joy & J_START) {
            HIDE_SPRITES;
            domenu();
            break;
        }

        update_player();
        move_sprite(0, player_x, player_y);
        wait_vbl_done();
    }
}