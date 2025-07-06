#include <gb/gb.h>
#include "physics.h"
#include "icon1.h"     // Para los pivots del sprite
#include "gb-madness.h" // Para LEVEL_MAP_WIDTH, LEVEL_MAP_HEIGHT, level_map
#include "collision.h" // Para la l�gica de colisi�n (is_pixel_in_solid_metatile)

// Variables de estado del cubo
int16_t cube_x_pixel = 80;
// Posici�n inicial Y: Asentar el sprite sobre el GROUND_Y (128).
// El tope del sprite estar� en (GROUND_Y - icon1_PIVOT_Y - icon1_PIVOT_H)
int16_t cube_y = (GROUND_Y - icon1_PIVOT_Y - icon1_PIVOT_H) * SCALE; // (128 - 1 - 14) * 100 = 11300

int16_t velocity_y = 0;
uint8_t is_jumping = 0;


void update_physics(void) {
    velocity_y += GRAVITY_PER_FRAME;
    cube_y += velocity_y;

    int16_t current_sprite_y_pixel = cube_y / SCALE;

    int16_t check_x_left = cube_x_pixel + icon1_PIVOT_X;
    int16_t check_x_right = cube_x_pixel + icon1_PIVOT_X + icon1_PIVOT_W - 1;

    // --- Colisi�n Vertical con el Suelo (ca�da) ---
    if (velocity_y > 0) { // Solo si est� cayendo
        int16_t bottom_y_collision_point = current_sprite_y_pixel + icon1_PIVOT_Y + icon1_PIVOT_H - 1;

        if (is_pixel_in_solid_metatile(check_x_left, bottom_y_collision_point) ||
            is_pixel_in_solid_metatile(check_x_right, bottom_y_collision_point)) {

            // Calcular la posici�n Y del tope del metatile s�lido impactado
            int16_t metatile_top_y = (bottom_y_collision_point / 16) * 16;

            // Ajustar la posici�n Y del cubo para que se siente exactamente sobre el metatile
            // Su punto de colisi�n inferior debe estar 1 p�xel por encima del metatile_top_y
            // (cube_y / SCALE) + icon1_PIVOT_Y + icon1_PIVOT_H - 1 = metatile_top_y - 1
            // (cube_y / SCALE) = metatile_top_y - icon1_PIVOT_Y - icon1_PIVOT_H
            cube_y = (metatile_top_y - icon1_PIVOT_Y - icon1_PIVOT_H) * SCALE;
            
            velocity_y = 0;     // Detener la ca�da
            is_jumping = 0;     // No est� saltando (ha aterrizado)
        }
    }
    // --- Colisi�n Vertical con el Techo (salto hacia arriba) ---
    else if (velocity_y < 0) { // Solo si est� subiendo
        int16_t top_y_collision_point = current_sprite_y_pixel + icon1_PIVOT_Y;

        if (is_pixel_in_solid_metatile(check_x_left, top_y_collision_point) ||
            is_pixel_in_solid_metatile(check_x_right, top_y_collision_point)) {

            // Calcular la posici�n Y del pie del metatile s�lido impactado
            // El pie del metatile es (metatile_y * 16) + 15
            // Si el top_y_collision_point est� en el metatile (mt_y), su fondo es (mt_y+1)*16 -1
            int16_t metatile_bottom_y = ((top_y_collision_point / 16) + 1) * 16 - 1;

            // Ajustar la posici�n Y del cubo para que est� justo debajo del metatile
            // (cube_y / SCALE) + icon1_PIVOT_Y = metatile_bottom_y + 1
            // (cube_y / SCALE) = metatile_bottom_y + 1 - icon1_PIVOT_Y
            cube_y = (metatile_bottom_y + 1 - icon1_PIVOT_Y) * SCALE;
            
            velocity_y = 0; // Detener el movimiento hacia arriba
        }
    }
}

void handle_jump(uint8_t joy) {
    if ((joy & J_A) && !is_jumping) {
        velocity_y = JUMP_VELOCITY;
        is_jumping = 1;
    }
}

void handle_horizontal_movement(uint8_t joy) {
    int16_t new_x_pixel = cube_x_pixel;
    
    if (joy & J_LEFT) {
        new_x_pixel -= HORIZONTAL_SPEED;
    }
    if (joy & J_RIGHT) {
        new_x_pixel += HORIZONTAL_SPEED;
    }

    if (new_x_pixel != cube_x_pixel) {
        int16_t top_y_pivot = (cube_y / SCALE) + icon1_PIVOT_Y;
        int16_t bottom_y_pivot = (cube_y / SCALE) + icon1_PIVOT_Y + icon1_PIVOT_H - 1;

        if (new_x_pixel < cube_x_pixel) { // Movi�ndose a la izquierda
            int16_t check_x = new_x_pixel + icon1_PIVOT_X;
            // Si choca con un metatile s�lido por la izquierda
            if (is_pixel_in_solid_metatile(check_x, top_y_pivot) ||
                is_pixel_in_solid_metatile(check_x, bottom_y_pivot)) {
                
                // Ajustar al borde derecho del metatile colisionado
                // metatile_x_right_edge = ((check_x / 16) + 1) * 16 - 1
                // new_x_pixel + icon1_PIVOT_X = metatile_x_right_edge + 1
                // new_x_pixel = metatile_x_right_edge + 1 - icon1_PIVOT_X
                new_x_pixel = (((check_x / 16) + 1) * 16 - icon1_PIVOT_X);
            }
        } else if (new_x_pixel > cube_x_pixel) { // Movi�ndose a la derecha
            int16_t check_x = new_x_pixel + icon1_PIVOT_X + icon1_PIVOT_W - 1;
            // Si choca con un metatile s�lido por la derecha
            if (is_pixel_in_solid_metatile(check_x, top_y_pivot) ||
                is_pixel_in_solid_metatile(check_x, bottom_y_pivot)) {
                
                // Ajustar al borde izquierdo del metatile colisionado
                // metatile_x_left_edge = (check_x / 16) * 16
                // new_x_pixel + icon1_PIVOT_X + icon1_PIVOT_W - 1 = metatile_x_left_edge - 1
                // new_x_pixel = metatile_x_left_edge - 1 - icon1_PIVOT_X - icon1_PIVOT_W + 1
                // new_x_pixel = metatile_x_left_edge - icon1_PIVOT_X - icon1_PIVOT_W
                new_x_pixel = ((check_x / 16) * 16 - icon1_PIVOT_X - icon1_PIVOT_W);
            }
        }
    }
    cube_x_pixel = new_x_pixel;
}