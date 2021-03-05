# Video ROM Font Replacer

This project is also known as ```romfontr```.

## Synopsis
The Video ROM Font Replacer program modifies the standard VGA ROM fonts in any 16-bit VGA ROM BIOS binary file.\
I originally wrote it to modify the fonts on my Tseng Labs ET4000/W32i ISA VGA card with my own versions that I wanted to create for a long time. In the meantime I finished working on my DIY ISA Video Display Controller card. So now I am using ```romfontr``` with this card instead.

I wrote an essay on replacing the VGA fonts in a Video ROM BIOS image. You can read it here: [Microelectronics - VGA ROM Fonts Essay](http://www.alexandrugroza.ro/microelectronics/essays-research/vga-rom-fonts/index.html)

### Program Usage

The following lines are taken directly from the commandline help screen.

```
Usage is:
  romfontr.exe [-help] [-b] [-u] -offset=461C|AUTO
    -romfile=videorom.bin -fontfile=8x16font.bin

Where:
  -help     shows this screen; all other parameters are ignored
  -b        makes a backup of the binary video ROM file
  -u        updates the video ROM file 8-bit checksum
  -offset   specifies the hexadecimal font offset in the binary video ROM file
            if set to AUTO, the program will try to figure out the font offset
            according to the given binary font file
  -romfile  specifies the path and filename of the binary video ROM file
  -fontfile specifies the path and filename of the binary font file
```

### Notes
* This program does not work with VGA ROM BIOS images that are split between high and low independent ROM ICs.
