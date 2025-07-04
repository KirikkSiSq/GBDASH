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

// --- Variables globales necesarias para la animación ---
static uint8_t x = 80;
static uint8_t y = 72;
static uint8_t frame = 0;

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

    SPRITES_8x16;
    SHOW_SPRITES;

    // Carga los datos de tiles de fondo
    set_bkg_data(0, 64, tiles_tiles);

    // Pinta el mapa completo con metatiles
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

    // Configurar los datos del sprite
    set_sprite_palette(0, icon1_PALETTE_COUNT, icon1_palettes);
    set_sprite_data(icon1_TILE_ORIGIN, icon1_TILE_COUNT, icon1_tiles);

    // Dibujar primer frame
    move_metasprite(icon1_metasprites[frame], icon1_TILE_ORIGIN, 0, x, y);

    play(1);
}

void dolevel(void) {
    fade(setup); // Llama a setup y aplica efecto de transición

    while (1) {
        uint8_t joy = joypad();
        if (joy & J_START) {
            HIDE_SPRITES;
            domenu();
            break;
        }

        // Oculta el frame anterior
        hide_metasprite(icon1_metasprites[frame], 0);

        // Avanza al siguiente frame
        frame++;
        if (frame >= 24) frame = 0; // o usa 25 si tienes un frame extra

        // Muestra el frame actual en la misma posición
        move_metasprite(icon1_metasprites[frame], icon1_TILE_ORIGIN, 0, x, y);

        delay(100);        // Control de velocidad de animación
        wait_vbl_done();   // Esperar al VBlank para sincronizar
    }
}