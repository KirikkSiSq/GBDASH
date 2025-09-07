#include "vram_loader.h"

static vram_job_t queue[VRAM_JOB_QUEUE_SIZE];
static uint8_t head = 0, tail = 0;

void vram_loader_init(void) {
    head = tail = 0;
}

void vram_loader_enqueue(uint8_t type, uint8_t x, uint8_t y,
                         uint8_t w, uint8_t h, const uint8_t *src) {
    uint8_t next = (tail + 1) % VRAM_JOB_QUEUE_SIZE;
    if(next != head) {
        queue[tail].type = type;
        queue[tail].x = x;
        queue[tail].y = y;
        queue[tail].w = w;
        queue[tail].h = h;
        queue[tail].src = src;
        tail = next;
    }
}

void vram_loader_process(void) {
    uint8_t jobs = VRAM_JOBS_PER_FRAME;
    while((head != tail) && jobs > 0) {
        vram_job_t *job = &queue[head];

        if(job->type == JOB_TILEMAP) {
            set_bkg_tiles(job->x, job->y, job->w, job->h, job->src);
        }

        head = (head + 1) % VRAM_JOB_QUEUE_SIZE;
        jobs--;
    }
}