#include <gb/gb.h>
#include "physics.h"

int16_t cube_y = GROUND_Y * SCALE;
int16_t velocity_y = 0;
uint8_t is_jumping = 0;

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