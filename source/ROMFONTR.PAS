{ --------------------------------------------------------------------------- }
{ - ROM Font Replacer (romfontr.pas)                                        - }
{ - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }
program romfontr;

uses
  Crt;

type
  TParameterError = (
    erOffset,
    erROMFile,
    erFontFile
  );
  TParameterErrors = set of TParameterError;

  TParameters = record
    Offset: Longint;
    FontFileSize: Longint;
    UpdateChecksum: Boolean;
    ROMFileName: String;
    FontFileName: String;
    Errors: TParameterErrors;
  end;

  TBinaryFile = File of Byte;

  TFontType = (
    ftUnknown,
    ft8x8,
    ft8x14,
    ft8x16
  );

const
  { program stringtable }
  sEmpty                  = '';

  sProgramTitle           = 'ROM Font Replacer  VER: 0.5 REV: A';
  sProgramCopyright       = 'Copyright (C) 1998-2021 Microprogramming TECHNIQUES';
  sProgramAuthor          = 'Programming/PC Code: Alexandru Groza';
  sProgramRights          = 'All rights reserved.';

  sParameterMissing       = ' parameter missing.';

  sTypeHelp               = 'Type:' + #13#10 +
                            '  romfontr.exe -help';
  sHelpUsage              = 'Usage is:' + #13#10 +
                            '  romfontr.exe [-help] [-u] -offset=461C|AUTO' + #13#10 +
                            '    -romfile=videorom.bin -fontfile=8x16font.bin' + #13#10;
  sHelpParameters1        = 'Where:' + #13#10 +
                            '  -help     shows this screen; all other parameters are ignored' + #13#10 +
                            '  -u        updates the ROM 8-bit checksum';
  sHelpParameters2        = '  -offset   specifies the hexadecimal font offset in the binary Video ROM file' + #13#10 +
                            '            if set to AUTO, the program will try to figure out the font offset';
  sHelpParameters3        = '  -romfile  specifies the path and filename of the binary Video ROM file' + #13#10 +
                            '  -fontfile specifies the path and filename of the binary Fonts ROM file';

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
  sStatisticsChecksum     = 'Checksum updated: ';

  sYesNo: array[Boolean] of String[3] = (
    'NO',
    'YES'
  );

  sParameterErrors: array[TParameterError] of String[10] = (
    'Offset',
    'ROM File',
    'Fonts File'
  );

  sFontTypes: array[TFontType] of String[7] = (
    'unknown',
    '8x8',
    '8x16',
    '9x16'
  );

  { program commandline parameters }
  pHelp                   = '-help';
  pUpdateChecksum         = '-u';
  pOffset                 = '-offset=';
  pROMFileName            = '-romfile=';
  pFontFileName           = '-fontfile=';

  pOffsetAuto             = 'auto';
  kOffsetAuto             = -1;

  { single character constants }
  cHexIdentifier          = '$';
  cEqual                  = '=';
  cFullStop               = '.';

  { color constants }
  clError                 = Red;
  clNormal                = LightGray;
  clHighlight             = White;
  clHighlightSize         = Yellow;

  { file mode constants }
  fmReadOnly              = 0;
  fmWriteOnly             = 1;
  fmReadWrite             = 2;

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

procedure SetAllParameterErrors(var AParameterErrors: TParameterErrors);
var
  LParameterError: TParameterError;

begin
  for LParameterError := Low(TParameterError) to High(TParameterError) do
  begin
    Include(AParameterErrors, LParameterError);
  end;
end;

function ProcessParameters(var AParameters: TParameters): Boolean;
var
  LValue: String;
  LAutoValue: String;

begin
  FillChar(AParameters, SizeOf(AParameters), $00);

  SetAllParameterErrors(AParameters.Errors);

  if ParamCount > 0 then
  begin
    AParameters.UpdateChecksum := FindSimpleParameter(pUpdateChecksum);

    if FindComplexParameter(pOffset, LValue) then
    begin
      LAutoValue := LowerCase(Copy(LValue, Succ(Pos(cEqual, LValue)), 4));

      if LAutoValue = pOffsetAuto then
      begin
        AParameters.Offset := kOffsetAuto;
      end else
      begin
        AParameters.Offset := StrToIntDef(cHexIdentifier + LAutoValue, 0);
      end;

      Exclude(AParameters.Errors, erOffset);
    end;

    if FindComplexParameter(pROMFileName, LValue) then
    begin
      AParameters.ROMFileName := LValue;
      Delete(AParameters.ROMFileName, 1, Pos(cEqual, LValue));

      Exclude(AParameters.Errors, erROMFile);
    end;

    if FindComplexParameter(pFontFileName, LValue) then
    begin
      Aparameters.FontFileName := LValue;
      Delete(AParameters.FontFileName, 1, Pos(cEqual, LValue));

      Exclude(AParameters.Errors, erFontFile);
    end;
  end;

  ProcessParameters := AParameters.Errors = [];
end;

procedure WriteProgramHeader;
begin
  TextColor(clHighlight);
  Writeln;
  Writeln(sProgramTitle);

  TextColor(clNormal);
  Writeln(sProgramCopyright);
  Writeln(sProgramAuthor);
  Writeln(sProgramRights);
  Writeln;
end;

procedure WriteHelp;
begin
  Writeln(sHelpUsage);
  Writeln(sHelpParameters1);
  Writeln(sHelpParameters2);
  Writeln(sHelpParameters3);
end;

procedure WriteParameterErrors(const AParameterErrors: TParameterErrors);
var
  LParameterError: TParameterError;

begin
  TextColor(clError);

  for LParameterError := Low(TParameterError) to High(TParameterError) do
  begin
    if LParameterError in AParameterErrors then
    begin
      Write(sParameterErrors[LParameterError]);
      Writeln(sParameterMissing);
    end;
  end;

  TextColor(clNormal);
  Writeln;
  Writeln(sTypeHelp);
end;

procedure WriteFontTypeOffset(const AFontType: TFontType; const AOffset: Longint);
begin
  TextColor(clNormal);
  Write(sAutodetOffset1);

  TextColor(clHighlight);
  Write(sFontTypes[AFontType]);

  TextColor(clNormal);

  if AOffset = 0 then
  begin
    Writeln(sAutodetFailed);
  end else
  begin
    Write(sAutodetOffset2);

    TextColor(clHighlight);
    Write(IntToHex(AOffset));

    TextColor(clNormal);
    Writeln(cFullStop);
  end;
end;

procedure WriteStatistics(const AParameters: TParameters);
begin
  Write(sStatisticsWrote);

  TextColor(clHighlightSize);
  Write(AParameters.FontFileSize);

  TextColor(clNormal);
  Write(sStatisticsBytesOffset);

  TextColor(clHighlight);
  Write(IntToHex(AParameters.Offset));

  TextColor(clNormal);
  Writeln(cFullStop);
  Write(sStatisticsChecksum);

  TextColor(clHighlight);
  Write(sYesNo[AParameters.UpdateChecksum]);

  TextColor(clNormal);
  Writeln;
end;

procedure WriteError(const AMessage: String);
begin
  TextColor(clError);
  Write(AMessage);
  TextColor(clNormal);
  Writeln;
end;

function DetectFontType(var AFontFile: TBinaryFile): TFontType;
const
  k8x8FontSize  = 2048;
  k8x14FontSize = 3584;
  k8x16FontSize = 4096;

begin
  case FileSize(AFontFile) of
    k8x8FontSize:
      DetectFontType := ft8x8;

    k8x14FontSize:
      DetectFontType := ft8x14;

    k8x16FontSize:
      DetectFontType := ft8x16;

  else
    DetectFontType := ftUnknown;
  end;
end;

function DetectFontOffset(var AROMFile: TBinaryFile; const AFontType: TFontType): Longint;
const
  kIDFont8x8: array[0..7] of Byte = (0, 0, 0, 0, 0, 0, 0, 0);
  kIDFont8x14: array[0..13] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  kIDFont8x16: array[0..15] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

var
  LSearchBuffer: array[0..15] of Byte;
  LBytesRead: Word;

begin
  case AFontType of
    ftUnknown:
      DetectFontOffset := 0;

    ft8x8:
      DetectFontOffset := 10;

    ft8x14:
      DetectFontOffset := 20;

    ft8x16:
      DetectFontOffset := 30;

  end;

{$I-}
  Seek(AROMFile, 0);
{$I+}
  if IOResult <> 0 then
  begin
    Writeln(sCannotSeekInFile, {AROMFileName}'???');
    Exit;
  end;

  { TODO -oagroza -cImplement : Detection of font offset within video ROM file. }
end;

function LocateFontOffset(var AROMFile, AFontFile: TBinaryFile): Longint;
var
  LFontType: TFontType;
  LOffset: Longint;

begin
  LFontType := DetectFontType(AFontFile);
  LOffset := DetectFontOffset(AROMFile, LFontType);

  WriteFontTypeOffset(LFontType, LOffset);

  LocateFontOffset := LOffset;

  { TODO -oagroza -cRemove : Temporary code to support missing functionality. }

  WriteError('AUTO parameter is not supported in this version.');
  WriteError('Code execution halted.');
  Halt(1);
end;

function UpdateChecksum(var AROMFile: TBinaryFile; const AROMFileName: String): Boolean;
var
  I: Longint;
  LByte: Byte;
  LChecksum: Byte;

begin
  UpdateChecksum := False;

{$I-}
  Seek(AROMFile, 0);
{$I+}
  if IOResult <> 0 then
  begin
    Writeln(sCannotSeekInFile, AROMFileName);
    Exit;
  end;

  LChecksum := 0;

  for I := 0 to Pred(Pred(FileSize(AROMFile))) do
  begin
{$I-}
    Read(AROMFile, LByte);
{$I+}
    if IOResult <> 0 then
    begin
      Writeln(sCannotReadOutputFile, AROMFileName);
      Exit;
    end;

    LChecksum := LChecksum + LByte;
  end;

  LChecksum := (256 - LChecksum) mod 256;
{$I-}
  Write(AROMFile, LChecksum);
{$I+}
  if IOResult <> 0 then
  begin
    WriteError(sCannotWriteOutputFile + AROMFileName);
    Exit;
  end;

  UpdateChecksum := True;
end;

function ReplaceROMFont(var AParameters: TParameters): Boolean;
var
  I: Longint;
  LByte: Byte;
  LROMFile: TBinaryFile;
  LFontFile: TBinaryFile;

begin
  ReplaceROMFont := False;

  if AParameters.ROMFileName = sEmpty then
  begin
    WriteError(sParameterErrors[erROMFile] + sFileNameError);
    Exit;
  end;

  if AParameters.FontFileName = sEmpty then
  begin
    WriteError(sParameterErrors[erFontFile] + sFileNameError);
    Exit;
  end;

{$I-}
  Assign(LROMFile, AParameters.ROMFileName);
  FileMode := fmReadWrite;
  Reset(LROMFile);
{$I+}
  if IOResult <> 0 then
  begin
    WriteError(sCannotOpenOutputFile + AParameters.ROMFileName);
{$I-}
    Close(LROMFile);
{$I+}
    Exit;
  end;

{$I-}
  Assign(LFontFile, AParameters.FontFileName);
  FileMode := fmReadOnly;
  Reset(LFontFile);
{$I+}
  if IOResult <> 0 then
  begin
    WriteError(sCannotOpenInputFile + AParameters.FontFileName);
{$I-}
    Close(LROMFile);
    Close(LFontFile);
{$I+}
    Exit;
  end;

  if AParameters.Offset = kOffsetAuto then
  begin
    AParameters.Offset := LocateFontOffset(LROMFile, LFontFile);
  end;

{$I-}
  Seek(LROMFile, AParameters.Offset);
{$I+}
  if IOResult <> 0 then
  begin
    Writeln(sCannotSeekInFile, AParameters.ROMFileName);
{$I-}
    Close(LROMFile);
    Close(LFontFile);
{$I+}
    Exit;
  end;

  for I := 0 to Pred(FileSize(LFontFile)) do
  begin
{$I-}
    Read(LFontFile, LByte);
{$I+}
    if IOResult <> 0 then
    begin
      WriteError(sCannotReadInputFile + AParameters.FontFileName);
{$I-}
      Close(LROMFile);
      Close(LFontFile);
{$I+}
      Exit;
    end;
{$I-}
    Write(LROMFile, LByte);
{$I+}
    if IOResult <> 0 then
    begin
      WriteError(sCannotWriteOutputFile + AParameters.ROMFileName);
{$I-}
      Close(LROMFile);
      Close(LFontFile);
{$I+}
      Exit;
    end;
  end;

  AParameters.FontFileSize := FileSize(LFontFile);

  if AParameters.UpdateChecksum then
  begin
    if not UpdateChecksum(LROMFile, AParameters.ROMFileName) then
    begin
      AParameters.UpdateChecksum := False;
{$I-}
      Close(LROMFile);
      Close(LFontFile);
{$I+}
      Exit;
    end;
  end;

{$I-}
  Close(LROMFile);
  Close(LFontFile);
{$I+}

  ReplaceROMFont := True;
end;

var
  GParameters: TParameters;

begin
  WriteProgramHeader;

  if (ParamCount > 0) and (ParamStr(1) = pHelp) then
  begin
    WriteHelp;
  end else
  begin
    if ProcessParameters(GParameters) then
    begin
      if ReplaceROMFont(GParameters) then
      begin
        WriteStatistics(GParameters);
      end;
    end else
    begin
      WriteParameterErrors(GParameters.Errors);
    end;
  end;
end.
