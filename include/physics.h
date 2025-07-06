#ifndef PHYSICS_H
#define PHYSICS_H

#include <stdint.h>

#define SCALE 100
#define GRAVITY_PER_FRAME 11
#define JUMP_VELOCITY -230
#define GROUND_Y 128 // Esta constante se usará para la inicialización y el cálculo del suelo base
#define HORIZONTAL_SPEED 4 // NUEVO: Velocidad horizontal en píxeles por frame

extern int16_t cube_x_pixel;
extern int16_t cube_y;
extern int16_t velocity_y;
extern uint8_t is_jumping;

void update_physics(void);
void handle_jump(uint8_t joy);
void handle_horizontal_movement(uint8_t joy); // Asegúrate de que esta línea esté presente

#endif