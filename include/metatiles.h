#ifndef METATILES_H
#define METATILES_H

#include <stdint.h>

#define NUM_METATILES 29

// Each metatile is a 2x2 arrangement of 8x8 tiles: {TL, TR, BL, BR}
extern const uint8_t metatiles[NUM_METATILES][4];

#endif
