{ --------------------------------------------------------------------------- }
{ - ROM Font Replacer - Font Detection (fontdet.pas)                        - }
{ - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

unit FontDet;

interface

uses
  Types;

function DetectFontType(var AFontFile: TBinaryFile): TFontType;
function DetectFontOffset(var AROMFile: TBinaryFile; const AFontType: TFontType): Longint;

implementation

uses
  Routines;

const
  kFontSize8x8  = 2048;
  kFontSize8x14 = 3584;
  kFontSize8x16 = 4096;

  kIDFont8x8:  array[$00..$07] of Byte = (0, 0, 0, 0, 0, 0, 0, 0);
  kIDFont8x14: array[$00..$0D] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  kIDFont8x16: array[$00..$0F] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

{ public declarations }

function DetectFontType(var AFontFile: TBinaryFile): TFontType;
var
  LFileSize: Longint;

begin
{$I-}
  LFileSize := FileSize(AFontFile);
{$I+}
  if IOResult <> 0 then
  begin
    DetectFontType := ftUnknown;
  end else
  begin
    case LFileSize of
      kFontSize8x8:
        DetectFontType := ft8x8;

      kFontSize8x14:
        DetectFontType := ft8x14;

      kFontSize8x16:
        DetectFontType := ft8x16;

    else
      DetectFontType := ftUnknown;
    end;
  end;
end;

function DetectFontOffset(var AROMFile: TBinaryFile; const AFontType: TFontType): Longint;
begin
  case AFontType of
    ftUnknown:
      DetectFontOffset := 0;

    ft8x8:
      DetectFontOffset := 0;

    ft8x14:
      DetectFontOffset := 0;

    ft8x16:
      DetectFontOffset := 0;

  end;
end;

end.
