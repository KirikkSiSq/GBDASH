#include <gb/gb.h>
#include "collision.h"
#include "gb-madness.h" // Para LEVEL_MAP_WIDTH, LEVEL_MAP_HEIGHT, level_map
#include "metatiles.h" // Para la definición de metatiles y NUM_METATILES

// Definición de qué metatiles son sólidos
// ASEGÚRATE de que estos índices coincidan con los de tu array `metatiles` en metatiles.c
// y que los valores (0 para no sólido, 1 para sólido) sean correctos para tu mapa.
const uint8_t is_metatile_solid[NUM_METATILES] = {
    0, // 0: blank (no sólido)
    1, // 1: block (sólido)
    0, // 2: big spike (no sólido)
    0, // 3: big spike dw
    0, // 4: big spike left
    0, // 5: big spike right
    0, // 6: mid spike
    0, // 7: mid spike dw
    0, // 8: mid spike right
    0, // 9: mid spike left
    0, // 10: mini spikes
    0, // 11: mini spikes deco
    1, // 12: dfb
    0, // 13: default block 0 
    1, // 14: default block t 
    1, // 15: default block d 
    1, // 16: default block r 
    1, // 17: default block l 
    1, // 18: default cor r 
    1, // 19: default cor l 
    1, // 20: default cor dl 
    1, // 21: default cor dr 
    1, // 22: default block 1 
    1, // 23: default block 2 
    1, // 24: default block 3 
    0, // 25: slab u
    0, // 26: slab d
    0, // 27: orb
    0  // 28: pad
};

uint8_t get_metatile_at_pixel(int16_t px, int16_t py) {
    // Asegurarse de que el punto esté dentro de los límites del mapa en píxeles
    // El mapa es 10x9 metatiles, lo que es 160x144 píxeles.
    if (px < 0 || py < 0 || px >= (LEVEL_MAP_WIDTH * 16) || py >= (LEVEL_MAP_HEIGHT * 16)) {
        return 0; // Fuera de límites del mapa, tratar como espacio vacío (metatile 0)
    }
    
    // Convertir píxeles a coordenadas de metatile (cada metatile es 16x16 píxeles)
    uint8_t mt_x = px / 16;
    uint8_t mt_y = py / 16;

    // Aunque ya se comprobó el rango de píxeles, esta es una seguridad extra
    // if (mt_x >= LEVEL_MAP_WIDTH || mt_y >= LEVEL_MAP_HEIGHT) return 0; // Esto no debería ser necesario con la comprobación de píxeles anterior
    
    // El mapa es plano, así que calcular el índice
    return level_map[mt_y * LEVEL_MAP_WIDTH + mt_x];
}

uint8_t is_pixel_in_solid_metatile(int16_t px, int16_t py) {
    uint8_t metatile_index = get_metatile_at_pixel(px, py);
    // Asegurarse de que el índice del metatile esté dentro del rango de is_metatile_solid
    if (metatile_index >= NUM_METATILES) {
        // Esto indica un problema, el mapa está usando un índice de metatile no definido
        // Para evitar crashes, devolvemos 0 (no sólido)
        return 0; 
    }
    return is_metatile_solid[metatile_index];
}