# romfontr
ROM Font Replacer

This program modifies the standard VGA ROM fonts in a VGA ROM BIOS binary file.\
I wrote it to modify the fonts on my ISA VGA card with a font that I wanted to create for a long time.

Read more here: [Microelectronics - VGA ROM Fonts Essay](http://www.alexandrugroza.ro/microelectronics/vga-rom-fonts/index.html)

```
Usage is:
  romfontr.exe [-help] [-u] -romfile=videorom.bin -fontfile=fonts.bin

Where:
  -help     shows this screen; all other parameters are ignored
  -u        updates the ROM 8-bit checksum
  -romfile  specifies the path and filename of the binary Video ROM file
  -fontfile specifies the path and filename of the binary Fonts ROM file
```
