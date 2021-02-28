{ --------------------------------------------------------------------------- }
{ - ROM Font Replacer (romfontr.pas)                                        - }
{ - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

program romfontr;

uses
  Crt,
  Dos,
  Consts,
  FontDet,
  Routines,
  Strings,
  Types;

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
    AParameters.BackupROMFile := FindSimpleParameter(pBackupROMFile);
    AParameters.UpdateChecksum := FindSimpleParameter(pUpdateChecksum);

    if FindComplexParameter(pOffset, LValue) then
    begin
      LAutoValue := LowerCase(Copy(LValue, Succ(Pos(cEqual, LValue)), 4));

      if LAutoValue = pOffsetAuto then
      begin
        AParameters.Offset := kOffsetAuto;
      end else
      begin
        AParameters.Offset := StrToIntDef(cDollarSign + LAutoValue, 0);
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
  Writeln(sHelpParameters4);
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
  Write(sStatisticsBackup);

  TextColor(clErrorSuccess[AParameters.BackupROMFile]);
  Write(sYesNo[AParameters.BackupROMFile]);

  if AParameters.BackupROMFile then
  begin
    TextColor(clNormal);
    Write(cSpace + cOpenBracket);

    TextColor(clErrorSuccess[AParameters.BackupStatus]);
    Write(sFailedSucceeded[AParameters.BackupStatus]);

    TextColor(clNormal);
    Writeln(cClosedBracket);
  end;

  TextColor(clNormal);
  Write(sStatisticsChecksum);

  TextColor(clErrorSuccess[AParameters.UpdateChecksum]);
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

function LocateFontOffset(var AROMFile, AFontFile: TBinaryFile;
  var AFontOffset: Longint): Boolean;
var
  LFontType: TFontType;

begin
  LFontType := DetectFontType(AFontFile);
  AFontOffset := DetectFontOffset(AROMFile, LFontType);

  WriteFontTypeOffset(LFontType, AFontOffset);

  { TODO -oagroza -cModify : Return value of LocateFontOffset function. }

  LocateFontOffset := False;
end;

function UpdateChecksum(var AROMFile: TBinaryFile; const AROMFileName: String): Boolean;
var
  I: Longint;
  LByte: Byte;
  LChecksum: Byte;

begin
  UpdateChecksum := False;

  if not FileSeek(AROMFile, 0) then
  begin
    Writeln(sCannotSeekInFile, AROMFileName);

    Exit;
  end;

  LChecksum := 0;

  for I := 0 to Pred(Pred(FileSize(AROMFile))) do
  begin
    if not FileReadByte(AROMFile, LByte) then
    begin
      Writeln(sCannotReadOutputFile, AROMFileName);

      Exit;
    end;

    LChecksum := LChecksum + LByte;
  end;

  LChecksum := (256 - LChecksum) mod 256;

  if not FileWriteByte(AROMFile, LChecksum) then
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

  if AParameters.BackupROMFile then
  begin
    AParameters.BackupStatus := FileCopy(
      AParameters.ROMFileName,
      ReplaceFileExt(FExpand(AParameters.ROMFileName), fmBAKFiles)
    );
  end;

  if not FileOpen(LROMFile, AParameters.ROMFileName, fmReadWrite) then
  begin
    WriteError(sCannotOpenOutputFile + AParameters.ROMFileName);

    FileClose(LROMFile);

    Exit;
  end;

  if not FileOpen(LFontFile, AParameters.FontFileName, fmReadOnly) then
  begin
    WriteError(sCannotOpenInputFile + AParameters.FontFileName);

    FileClose(LROMFile);
    FileClose(LFontFile);

    Exit;
  end;

  if AParameters.Offset = kOffsetAuto then
  begin
    if not LocateFontOffset(LROMFile, LFontFile, AParameters.Offset) then
    begin
      { TODO -oagroza -cRemove : Temporary code to support missing functionality. }

      WriteError('AUTO parameter is not supported in this version.');
      WriteError('Code execution halted.');
      Halt(1);
    end;
  end;

  if not FileSeek(LROMFile, AParameters.Offset) then
  begin
    Writeln(sCannotSeekInFile, AParameters.ROMFileName);

    FileClose(LROMFile);
    FileClose(LFontFile);

    Exit;
  end;

  for I := 0 to Pred(FileSize(LFontFile)) do
  begin
    if not FileReadByte(LFontFile, LByte) then
    begin
      WriteError(sCannotReadInputFile + AParameters.FontFileName);

      FileClose(LROMFile);
      FileClose(LFontFile);

      Exit;
    end;

    if not FileWriteByte(LROMFile, LByte) then
    begin
      WriteError(sCannotWriteOutputFile + AParameters.ROMFileName);

      FileClose(LROMFile);
      FileClose(LFontFile);

      Exit;
    end;
  end;

  AParameters.FontFileSize := FileSize(LFontFile);

  if AParameters.UpdateChecksum then
  begin
    if not UpdateChecksum(LROMFile, AParameters.ROMFileName) then
    begin
      AParameters.UpdateChecksum := False;

      FileClose(LROMFile);
      FileClose(LFontFile);

      Exit;
    end;
  end;

  FileClose(LROMFile);
  FileClose(LFontFile);

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
