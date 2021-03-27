{ --------------------------------------------------------------------------- }
{ - ROM Font Replacer - Constants (consts.pas)                              - }
{ - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

unit Consts;

interface

uses
  Crt,
  Types;

const
  { program stringtable }
  sEmpty                  = '';

  sProgramTitle           = 'Video ROM Font Replacer  VER: 0.6 REV: D';
  sProgramCopyright       = 'Copyright (C) 1998-2021 Microprogramming TECHNIQUES';
  sProgramAuthor          = 'Programming/PC Code: Alexandru Groza';
  sProgramRights          = 'All rights reserved.';

  sParameterMissing       = ' parameter missing.';

  sTypeHelp               = 'Type:' + #13#10 +
                            '  romfontr.exe -help';
  sHelpUsage              = 'Usage is:' + #13#10 +
                            '  romfontr.exe [-help] [-b] [-u] -offset=461C|AUTO' + #13#10 +
                            '    -romfile=videorom.bin -fontfile=8x16font.bin' + #13#10;
  sHelpParameters1        = 'Where:' + #13#10 +
                            '  -help     shows this screen; all other parameters are ignored' + #13#10 +
                            '  -b        makes a backup of the binary video ROM file';
  sHelpParameters2        = '  -u        updates the video ROM file 8-bit checksum' + #13#10 +
                            '  -offset   specifies the hexadecimal font offset in the binary video ROM file';
  sHelpParameters3        = '            if set to AUTO, the program will try to figure out the font offset' + #13#10 +
                            '            according to the given binary font file';
  sHelpParameters4        = '  -romfile  specifies the path and filename of the binary video ROM file' + #13#10 +
                            '  -fontfile specifies the path and filename of the binary font file';

  sCannotOpenInputFile    = 'Cannot open input file ';
  sCannotReadInputFile    = 'Cannot read input file ';
  sCannotOpenOutputFile   = 'Cannot open output file ';
  sCannotReadOutputFile   = 'Cannot read output file ';
  sCannotWriteOutputFile  = 'Cannot write output file ';
  sCannotSeekInFile       = 'Cannot seek in file ';

  sFileNameError          = ' path and filename cannot be empty.';

  sAutodetOffset1         = 'Automatic detection of ';
  sAutodetOffset2         = ' fonts revealed offset ';
  sAutodetFailed          = ' fonts failed.';

  sStatisticsWrote        = 'Wrote ';
  sStatisticsBytesOffset  = ' bytes at offset ';
  sStatisticsBackup       = 'ROM file backup: ';
  sStatisticsChecksum     = 'Checksum updated: ';

  sYesNo: array[Boolean] of String[3] = (
    'NO',
    'YES'
  );

  sFailedSucceeded: array[Boolean] of String[9] = (
    'failed',
    'succeeded'
  );

  sParameterErrors: array[TParameterError] of String[10] = (
    'Offset',
    'ROM File',
    'Fonts File'
  );

  sFontTypes: array[TFontType] of String[7] = (
    'unknown',
    '8x8',
    '8x14',
    '8x16'
  );

  { program commandline parameters }
  pHelp                   = '-help';
  pBackupROMFile          = '-b';
  pUpdateChecksum         = '-u';
  pOffset                 = '-offset=';
  pROMFileName            = '-romfile=';
  pFontFileName           = '-fontfile=';

  pOffsetAuto             = 'auto';
  kOffsetAuto             = -1;

  { single character constants }
  cSpace                  = ' ';
  cFullStop               = '.';
  cDollarSign             = '$';
  cEqual                  = '=';
  cOpenBracket            = '(';
  cClosedBracket          = ')';

  { color constants }
  clError                 = Red;
  clSuccess               = Green;
  clNormal                = LightGray;
  clHighlight             = White;
  clHighlightSize         = Yellow;

  clErrorSuccess: array[Boolean] of Byte = (
    clError,
    clSuccess
  );

  { file masks }
  fmBAKFiles              = 'bak';

  { file mode constants }
  fmReadOnly              = 0;
  fmWriteOnly             = 1;
  fmReadWrite             = 2;

implementation

end.
