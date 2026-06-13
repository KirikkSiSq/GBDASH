#include <gb/gb.h>
#include "metatiles.h"

const uint8_t metatiles[NUM_METATILES][4] = {
    { 0, 0, 0, 0 },         // blank
    { 45, 46, 47, 48 },     // block
    { 1, 2, 3, 4 },         // big spike
    { 5, 6, 7, 8 },         // big spike dw
    { 9, 10, 11, 12 },      // big spike left
    { 13, 14, 15, 16 },     // big spike right
    { 0, 0, 23, 24 },       // mid spike 
    { 21, 22, 0, 0 },       // mid spike dw
    { 0, 33, 0, 35 },       // mid spike right
    { 34, 0, 36, 0 },       // mid spike left
    { 0, 0, 53, 54 },       // mini spikes
    { 49, 50, 51, 52 },     // mini spikes deco
    { 25, 26, 27, 28 },     // dfb
    { 29, 30, 31, 32 },     // default block 0
    { 37, 38, 31, 32 },     // default block t
    { 29, 30, 41, 42 },     // default block d
    { 29, 39, 31, 40 },     // default block r
    { 43, 30, 44, 32 },     // default block l
    { 37, 26, 31, 40 },     // default cor r
    { 25, 38, 44, 32 },     // default cor l
    { 43, 30, 27, 42 },     // default cor dl
    { 29, 39, 41, 28 },     // default cor dr
    { 43, 39, 44, 40 },     // default block 1
    { 25, 26, 44, 40 },     // default block 2
    { 43, 39, 27, 28 },     // default block 3
    { 17, 18, 0, 0 },       // slab u
    { 0, 0, 19, 20 },       // slab d
    { 55, 56, 57, 58 },     // orb
    { 0, 0, 59, 60 }        // pad
};
