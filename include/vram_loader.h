#ifndef VRAM_LOADER_H
#define VRAM_LOADER_H

#include <gb/gb.h>
#include <stdint.h>

#define JOB_TILEMAP 0
#define VRAM_JOB_QUEUE_SIZE 32
#define VRAM_JOBS_PER_FRAME 4   // how many jobs are executed each VBlank

typedef struct {
    uint8_t type;
    uint8_t x, y;
    uint8_t w, h;
    const uint8_t *src;
} vram_job_t;

void vram_loader_init(void);
void vram_loader_enqueue(uint8_t type, uint8_t x, uint8_t y,
                         uint8_t w, uint8_t h, const uint8_t *src);
void vram_loader_process(void);

#endif