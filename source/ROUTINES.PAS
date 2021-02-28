{ --------------------------------------------------------------------------- }
{ - ROM Font Replacer - Routines (routines.pas)                             - }
{ - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

unit Routines;

interface

uses
  Types;

function FindSimpleParameter(const AParameter: String): Boolean;
function FindComplexParameter(const AParameter: String; var AValue: String): Boolean;

function IntToHex(const AValue: Longint): String;
function StrToIntDef(const AString: String; const ADefault: Longint): Longint;
function LowerCase(const AString: String): String;

function ReplaceFileExt(const AFileName, AExtension: String): String;

function FileCopy(const ASourceFileName, ADestFileName: String): Boolean;

function FileOpen(var ABinaryFile: TBinaryFile; const AFileName: String;
  const AFileMode: Byte): Boolean;
function FileClose(var ABinaryFile: TBinaryFile): Boolean;
function FileReadByte(var ABinaryFile: TBinaryFile; var AByte: Byte): Boolean;
function FileWriteByte(var ABinaryFile: TBinaryFile; var AByte: Byte): Boolean;
function FileSeek(var ABinaryFile: TBinaryFile; const APosition: Longint): Boolean;

implementation

uses
  Consts,
  Dos;

{ public declarations }

function FindSimpleParameter(const AParameter: String): Boolean;
var
  I: Integer;

begin
  FindSimpleParameter := False;

  for I := 1 to ParamCount do
  begin
    if LowerCase(ParamStr(I)) = AParameter then
    begin
      FindSimpleParameter := True;

      Break;
    end;
  end;
end;

function FindComplexParameter(const AParameter: String; var AValue: String): Boolean;
var
  I: Integer;

begin
  FindComplexParameter := False;

  for I := 1 to ParamCount do
  begin
    if Pos(AParameter, LowerCase(ParamStr(I))) <> 0 then
    begin
      AValue := ParamStr(I);

      FindComplexParameter := True;

      Break;
    end;
  end;
end;

function IntToHex(const AValue: Longint): String;
const
  kHexDigits: array[$00..$0F] of Char = '0123456789ABCDEF';

begin
  if AValue <= 0 then
  begin
    IntToHex := sEmpty;
  end else
  begin
    IntToHex := IntToHex(AValue div $10) + kHexDigits[AValue mod $10];
  end;
end;

function StrToIntDef(const AString: String; const ADefault: Longint): Longint;
var
  LValue: Longint;
  LErrorCode: Integer;

begin
  Val(AString, LValue, LErrorCode);
  if LErrorCode = 0 then
  begin
    StrToIntDef := LValue;
  end else
  begin
    StrToIntDef := ADefault;
  end;
end;

function LowerCase(const AString: String): String; assembler;
asm
  push ds

  cld

  lds si,AString
  les di,@Result
  lodsb
  stosb

  xor ah,ah
  xchg ax,cx
  jcxz @exit

@lowercase:
  lodsb
  cmp al,'A'
  jb @next
  cmp al,'Z'
  ja @next
  add al,20h

@next:
  stosb
  loop @lowercase

@exit:
  pop ds

end;

function ReplaceFileExt(const AFileName, AExtension: String): String;
var
  I: Byte;

begin
  for I := Length(AFileName) downto 1 do
    if AFileName[I] = cFullStop then
      Break;

  if (I = 1) and (AFileName[I] <> cFullStop) then
  begin
    ReplaceFileExt := AFileName;
  end else
  begin
    ReplaceFileExt := Copy(AFileName, 1, I) + AExtension;
  end;
end;

function FileCopy(const ASourceFileName, ADestFileName: String): Boolean;
var
  LFileTime: Longint;
  LSourceFile: File;
  LDestFile: File;
  LBytesRead: Word;
  LBytesWritten: Word;
  LBuffer: array[1..2048] of Byte;

begin
{$I-}
  Assign(LSourceFile, ASourceFileName);
  FileMode := fmReadOnly;
  Reset(LSourceFile, 1);

  Assign(LDestFile, ADestFileName);
  FileMode := fmReadWrite;
  Rewrite(LDestFile, 1);

  GetFTime(LSourceFile, LFileTime);

  repeat
    BlockRead(LSourceFile, LBuffer, SizeOf(LBuffer), LBytesRead);
    BlockWrite(LDestFile, LBuffer, LBytesRead, LBytesWritten);
  until (LBytesRead = 0) or (LBytesWritten <> LBytesRead);

  SetFTime(LDestFile, LFileTime);
{$I+}
  FileCopy := IOResult = 0;
end;

function FileOpen(var ABinaryFile: TBinaryFile; const AFileName: String;
  const AFileMode: Byte): Boolean;
begin
{$I-}
  Assign(ABinaryFile, AFileName);
  FileMode := AFileMode;
  Reset(ABinaryFile);
{$I+}
  FileOpen := IOResult = 0;
end;

function FileClose(var ABinaryFile: TBinaryFile): Boolean;
begin
{$I-}
  Close(ABinaryFile);
{$I+}
  FileClose := IOResult = 0;
end;

function FileReadByte(var ABinaryFile: TBinaryFile; var AByte: Byte): Boolean;
begin
{$I-}
  Read(ABinaryFile, AByte);
{$I+}
  FileReadByte := IOResult = 0;
end;

function FileWriteByte(var ABinaryFile: TBinaryFile; var AByte: Byte): Boolean;
begin
{$I-}
  Write(ABinaryFile, AByte);
{$I+}
  FileWriteByte := IOResult = 0;
end;

function FileSeek(var ABinaryFile: TBinaryFile; const APosition: Longint): Boolean;
begin
{$I-}
  Seek(ABinaryFile, APosition);
{$I+}
  FileSeek := IOResult = 0;
end;

end.
