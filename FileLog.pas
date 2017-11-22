unit FileLog;

interface

uses
 CvarDef;

procedure File_WriteLog(const S: String);
procedure File_Create;

implementation

procedure File_WriteLog(const S: String);
begin
 if PLongWord(@LogFileHandle)^ = 0 then Exit;

 AssignFile(LogFileHandle, 'log.txt');
 Append(LogFileHandle);
 WriteLn(LogFileHandle, S);
 CloseFile(LogFileHandle);
end;

procedure File_Create;
begin
 AssignFile(LogFileHandle, 'log.txt');
 ReWrite(LogFileHandle);
 CloseFile(LogFileHandle);
end;

end.
