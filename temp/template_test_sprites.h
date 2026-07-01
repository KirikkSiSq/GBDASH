#ifndef TEMPLATE_TEST_SPRITES_H
#define TEMPLATE_TEST_SPRITES_H

#include <stdint.h>

typedef struct {
    uint16_t x;
    uint16_t y;
    uint8_t tile;
} template_test_sprites_placement_t;

#define TEMPLATE_TEST_SPRITES_COUNT 0
extern const template_test_sprites_placement_t template_test_sprites_placements[];

#endif /* TEMPLATE_TEST_SPRITES_H */
