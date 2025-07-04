#ifndef PHYSICS_H
#define PHYSICS_H

#include <stdint.h>

#define SCALE 100
#define GRAVITY_PER_FRAME 1       // Simula 0.01 px/frame²
#define JUMP_VELOCITY -69         // Salto de 24 px
#define GROUND_Y 72               // Piso en pixeles

extern int16_t cube_y;
extern int16_t velocity_y;
extern uint8_t is_jumping;

void update_physics(void);
void handle_jump(uint8_t joy);

#endif