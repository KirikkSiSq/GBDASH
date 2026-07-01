@echo off
setlocal enabledelayedexpansion

REM This script converts all _bg.csv files in levels/level_data to GBDK-compatible level files.

pushd "%~dp0"

for %%f in (levels\level_data\*_bg.csv) do (
    set "full_filename=%%~nf"
    set "name=!full_filename:_bg=!"
    echo Converting %%f to !name!_16high...

    python tools\csv2level.py "%%f" -o levels\level_data\ -n !name!_16high --no-gid-offset --crop-height 16
)

for %%f in (levels\chr_data\tmx\*.tmx) do (
    set "full_filename=%%~nf"
    set "name=!full_filename!"
    echo Converting %%f to !name!_sprites...

    python tools\tmx2sprites.py "%%f" -o levels\level_data\ -n !name!
)

popd
echo.
echo Conversion complete.
pause
