#include <gb/gb.h>
#include "assets.h"
#include "gameplay.h"
#include "hUGEDriver.h"

uint8_t music_ready = 0;
uint8_t redraw = 1;
uint8_t selected = 0;
volatile uint8_t current_song_bank = 0;

// Called by the timer interrupt to update music
void play_music_safe(void) {
  if (music_ready) {
    uint8_t prev_bank = _current_bank;
    SWITCH_ROM(current_song_bank);
    hUGE_dosound();
    SWITCH_ROM(prev_bank);
  }
}

void main(void) {
  music_ready = 0;

  // Enable sound hardware
  NR52_REG = 0x80;
  NR51_REG = 0xFF;
  NR50_REG = 0x77;

  // Set up timer at ~60 Hz for music playback
  TMA_REG = 187;   // ~60 Hz (4096 Hz / (256-187) ≈ 59.4 Hz)
  TAC_REG = 0x04;
  add_TIM(play_music_safe);
  set_interrupts(VBL_IFLAG | TIM_IFLAG);
  enable_interrupts();

  setup_menu_font();

  while (1) {
    if (redraw) draw_menu();

    uint8_t joy = joypad();

    // Level selection handling
    if (joy & J_UP) {
      if (selected > 0) { selected--; redraw = 1; }
      waitpadup();
    } else if (joy & J_DOWN) {
      if (selected < MAX_LEVELS - 1) { selected++; redraw = 1; }
      waitpadup();
    } else if (joy & J_A) {
      disable_interrupts();
      play_level(selected);
      enable_interrupts();
    }

    wait_vbl_done();
  }
}
