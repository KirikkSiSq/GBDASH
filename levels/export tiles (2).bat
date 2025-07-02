@echo off
rgbgfx -o tileset.2bpp tileset.png
python 2bpp2c.py tileset.2bpp tiles_tiles
cls
echo finished
pause

