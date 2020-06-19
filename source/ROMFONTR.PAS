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
    erROMFile,
    erFontFile
  );
  TParameterErrors = set of TParameterError;

  TParameters = record
    Offset: Integer;
    FontFileSize: Integer;
    UpdateChecksum: Boolean;
    ROMFileName: String;
    FontFileName: String;
    Errors: TParameterErrors;
  end;

const
  { program stringtable }
  sEmpty                  = '';

  sProgramTitle           = 'ROM Font Replacer  VER: 0.1 REV: B';
  sProgramCopyright       = 'Copyright (C) 1998-2020 Microprogramming TECHNIQUES';
  sProgramAuthor          = 'Programming/PC Code: Alexandru Groza';
  sProgramRights          = 'All rights reserved.';

  sParameterMissing       = ' parameter missing.';

  sTypeHelp               = 'Type:' + #13#10 +
                            '  romfontr.exe -help';
  sHelpUsage              = 'Usage is:' + #13#10 +
                            '  romfontr.exe [-help] [-u] -romfile=videorom.bin -fontfile=fonts.bin' + #13#10;
  sHelpParameters1        = 'Where:' + #13#10 +
                            '  -help     shows this screen; all other parameters are ignored' + #13#10 +
                            '  -u        updates the ROM 8-bit checksum';
  sHelpParameters2        = '  -romfile  specifies the path and filename of the binary Video ROM file' + #13#10 +
                            '  -fontfile specifies the path and filename of the binary Fonts ROM file';

  sCannotOpenInputFile    = 'Cannot open input file ';
  sCannotReadInputFile    = 'Cannot read input file ';
  sCannotOpenOutputFile   = 'Cannot open output file ';
  sCannotReadOutputFile   = 'Cannot read output file ';
  sCannotWriteOutputFile  = 'Cannot write output file ';

  sFileNameError          = ' path and filename cannot be empty.';

  sStatisticsWrote        = 'Wrote ';
  sStatisticsBytesOffset  = ' bytes at offset ';
  sStatisticsChecksum     = 'Checksum updated: ';

  sYesNo: array[Boolean] of String = (
    'NO',
    'YES'
  );

  sParameterErrors: array[TParameterError] of String = (
    'ROM File',
    'Fonts File'
  );

  { program commandline parameters }
  pHelp                   = '-help';
  pUpdateChecksum         = '-u';
  pROMFileName            = '-romfile=';
  pFontFileName           = '-fontfile=';

  { single character constants }
  cEqual                  = '=';
  cFullStop               = '.';

  kROMFontOffset       = 17948;

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

function IntToHex(const AInteger: Integer): String;
const
  kHexLength = 4;
  kHexDigits: array[0..15] of Char = '0123456789ABCDEF';

var
  I: Integer;
  LInteger: Integer;

begin
  LInteger := AInteger;

  IntToHex[0] := Char(kHexLength);

  for I := kHexLength downto 1 do
  begin
    IntToHex[I] := kHexDigits[LInteger and $F];
    LInteger := LInteger shr 4;
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

begin
  FillChar(AParameters, SizeOf(AParameters), $00);

  SetAllParameterErrors(AParameters.Errors);

  if ParamCount > 0 then
  begin
    AParameters.UpdateChecksum := FindSimpleParameter(pUpdateChecksum);

    if FindComplexParameter(pROMFileName, LValue) then
    begin
      Aparameters.ROMFileName := LValue;
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

function ReplaceROMFont(var AParameters: TParameters): Boolean;
var
  I: Integer;
  LByte: Byte;
  LChecksum: Byte;
  LROMFile: File of Byte;
  LFontFile: File of Byte;

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

  Seek(LROMFile, AParameters.Offset);

{$I-}
  Assign(LFontFile, AParameters.FontFileName);
  FileMode := fmReadOnly;
  Reset(LFontFile);
{$I+}
  if IOResult <> 0 then
  begin
    WriteError(sCannotOpenInputFile + AParameters.FontFileName);
{$I-}
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
      Close(LFontFile);
      Close(LROMFile);
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
    Seek(LROMFile, 0);

    LChecksum := 0;

    for I := 0 to Pred(Pred(FileSize(LROMFile))) do
    begin
{$I-}
      Read(LROMFile, LByte);
{$I+}
      if IOResult <> 0 then
      begin
        Writeln(sCannotReadOutputFile, AParameters.ROMFileName);
{$I-}
        Close(LROMFile);
        Close(LFontFile);
{$I+}
        Exit;
      end;

      LChecksum := LChecksum + LByte;
    end;

    LChecksum := (256 - LChecksum) mod 256;
{$I-}
    Write(LROMFile, LChecksum);
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
      GParameters.Offset := kROMFontOffset;

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
