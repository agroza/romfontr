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

{ private declarations }

function VectorSearch(var ABinaryFile: TBinaryFile; const AVector: array of Byte;
  var AVectorOffset: Longint): Boolean;

  function VectorFound: Boolean;
  var
    LIndex: Byte;
    LByte: Byte;

  begin
    for LIndex := Low(AVector) to High(AVector) do
    begin
      Read(ABinaryFile, LByte);
      if LByte <> AVector[LIndex] then
      begin
        VectorFound := False;
        Exit;
      end;
    end;

    VectorFound := True;
  end;

begin
  while AVectorOffset <= FileSize(ABinaryFile) - High(AVector) do
  begin
    FileSeek(ABinaryFile, AVectorOffset);

    if VectorFound then
    begin
      VectorSearch := True;
      Exit;
    end else
    begin
      Inc(AVectorOffset);
    end;
  end;

  Dec(AVectorOffset, High(AVector));

  VectorSearch := False;
end;

function IsVectorAtOffset(var ABinaryFile: TBinaryFile; const AVector: array of Byte;
  const AOffset: Longint): Boolean;
var
  LIndex: Byte;
  LByte: Byte;

begin
  Seek(ABinaryFile, AOffset);

  for LIndex := Low(AVector) to High(AVector) do
  begin
    Read(ABinaryFile, LByte);
    if LByte <> AVector[LIndex] then
    begin
      IsVectorAtOffset := False;
      Exit;
    end;
  end;

  IsVectorAtOffset := True;
end;

function FontSearch(var ABinaryFile: TBinaryFile; const AVector: array of Byte;
  const AFontSize: Longint): Longint;
var
  LVectorOffset: Longint;

begin
  FontSearch := 0;
  LVectorOffset := 0;

  while LVectorOffset <= FileSize(ABinaryFile) - High(AVector) - AFontSize do
  begin
    if VectorSearch(ABinaryFile, AVector, LVectorOffset) then
    begin
      if IsVectorAtOffset(ABinaryFile, AVector, LVectorOffset + AFontSize - High(AVector)) then
      begin
        FontSearch := LVectorOffset;
        Exit;
      end else
      begin
        Inc(LVectorOffset);
      end;
    end else
    begin
      Exit;
    end;
  end;
end;

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
      DetectFontOffset := FontSearch(AROMFile, kIDFont8x8, kFontSize8x8);

    ft8x14:
      DetectFontOffset := FontSearch(AROMFile, kIDFont8x14, kFontSize8x14);

    ft8x16:
      DetectFontOffset := FontSearch(AROMFile, kIDFont8x16, kFontSize8x16);

  end;
end;

end.
