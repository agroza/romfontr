# romfontr
Video ROM Font Replacer

This program modifies the standard VGA ROM fonts in a VGA ROM BIOS binary file.\
I wrote it originally to modify the fonts on my Tseng Labs ISA VGA card with a font that I wanted to create for a long time.
Now I am using it for the fonts of my DIY ISA Video Display Controller card.

Read more here: [Microelectronics - VGA ROM Fonts Essay](http://www.alexandrugroza.ro/microelectronics/essays-research/vga-rom-fonts/index.html)

```
Usage is:
  romfontr.exe [-help] [-u] -offset=461C|AUTO
    -romfile=videorom.bin -fontfile=8x16font.bin

Where:
  -help     shows this screen; all other parameters are ignored
  -u        updates the video ROM file 8-bit checksum
  -offset   specifies the hexadecimal font offset in the binary video ROM file
            if set to AUTO, the program will try to figure out the font offset
            according to the given binary font file
  -romfile  specifies the path and filename of the binary video ROM file
  -fontfile specifies the path and filename of the binary font file
```
