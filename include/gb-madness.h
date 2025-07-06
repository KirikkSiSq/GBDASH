// gb-madness.h
#ifndef _LEVEL_MAP_H_
#define _LEVEL_MAP_H_

#define LEVEL_MAP_WIDTH 20
#define LEVEL_MAP_HEIGHT 9

#define MAP_TILE_WIDTH (LEVEL_MAP_WIDTH * 2)
#define MAP_TILE_HEIGHT (LEVEL_MAP_HEIGHT * 2)

#define SCREEN_TILE_WIDTH 20 // 160 / 8
#define SCREEN_TILE_HEIGHT 18 // 144 / 8

#define BKG_MAP_WIDTH_TILES 32
#define BKG_MAP_HEIGHT_TILES 32

extern const unsigned char level_map[];

#endif // _LEVEL_MAP_H_
