{ --------------------------------------------------------------------------- }
{ - ROM Font Replacer - Types (types.pas)                                   - }
{ - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

unit Types;

interface

type
  TParameterError = (
    erOffset,
    erROMFile,
    erFontFile
  );
  TParameterErrors = set of TParameterError;

  TParameters = record
    BackupROMFile: Boolean;
    UpdateChecksum: Boolean;
    Offset: Longint;
    ROMFileName: String;
    FontFileName: String;

    Errors: TParameterErrors;

    FontFileSize: Longint;
    BackupStatus: Boolean;
  end;

  TBinaryFile = File of Byte;

  TFontType = (
    ftUnknown,
    ft8x8,
    ft8x14,
    ft8x16
  );

implementation

end.
