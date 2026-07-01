#ifndef STEREOMADNESS_TEST_SPRITES_H
#define STEREOMADNESS_TEST_SPRITES_H

#include <stdint.h>

typedef struct {
    uint16_t x;
    uint16_t y;
    uint8_t tile;
} stereomadness_test_sprites_placement_t;

#define STEREOMADNESS_TEST_SPRITES_COUNT 220
extern const stereomadness_test_sprites_placement_t stereomadness_test_sprites_placements[];

#endif /* STEREOMADNESS_TEST_SPRITES_H */
