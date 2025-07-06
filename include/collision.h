#ifndef COLLISION_H
#define COLLISION_H

#include <stdint.h>
#include "metatiles.h" // Para NUM_METATILES

extern const uint8_t is_metatile_solid[NUM_METATILES];

uint8_t get_metatile_at_pixel(int16_t px, int16_t py);
uint8_t is_pixel_in_solid_metatile(int16_t px, int16_t py);

#endif