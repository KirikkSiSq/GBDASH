#include <gb/cgb.h>
#include "gbc_palettes.h"


const uint16_t menu_pal[4] = {
    RGB8(20, 20, 40), RGB8(100, 100, 150), RGB8(200, 200, 255), RGB8(255, 255, 255)
};

const uint16_t gbc_sprite_palettes[32] = {
    // 0: Player (Outline: Black, Primary: Blue, Secondary: Green)
    RGB8(255, 255, 255), RGB8(0, 255, 255), RGB8(0, 255, 0), RGB8(0, 0, 0),
    // 1: Cube (Outline: Black, Primary: Green, Secondary: Green)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(0, 255, 0), RGB8(0, 255, 0),
    // 2: Normal Gravity (Outline: Black, Primary: Teal, Secondary: Teal)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(0, 255, 255), RGB8(0, 255, 255),
    // 3: Inverted Gravity (Outline: Black, Primary: Yellow, Secondary: Yellow)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(255, 255, 0), RGB8(255, 255, 0),
    // 4: Ship (Outline: Black, Primary: Pink, Secondary: Pink)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(255, 100, 255), RGB8(255, 100, 255),
    // 5: Ball (Outline: Black, Primary: Red, Secondary: Red)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(255, 0, 0), RGB8(255, 0, 0),
    // 6: Mirror Portal Entrance (Soft Blue/Cyan: outline black, ring blue, highlight white)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(200, 160, 95), RGB8(250, 225, 160),
    // 7: Mirror Portal Exit (Warm Gold/Orange: outline black, ring gold, highlight white)
    RGB8(255, 255, 255), RGB8(0, 0, 0), RGB8(115, 175, 195), RGB8(200, 235, 245)
};
