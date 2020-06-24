@echo off
echo ---------------------------------------------------------------------------
echo - ROM Font Replacer Test - Checksum Update (rfrtestu.bat)                 -
echo - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  -
echo - All rights reserved.                                                    -
echo ---------------------------------------------------------------------------
echo - License: GNU General Public License v3.0                                -
echo ---------------------------------------------------------------------------

romfontr.exe -u -offset=2EEF -romfile=vga.bin -fontfile=ag868x14.bin
romfontr.exe -u -offset=3CEF -romfile=vga.bin -fontfile=ag869x14.bin
romfontr.exe -u -offset=3E1C -romfile=vga.bin -fontfile=ag868x8.bin
romfontr.exe -u -offset=461C -romfile=vga.bin -fontfile=ag868x16.bin
romfontr.exe -u -offset=561C -romfile=vga.bin -fontfile=ag869x16.bin
echo.
