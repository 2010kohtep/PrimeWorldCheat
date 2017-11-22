unit Common;

interface

uses
 SysUtils, Windows, PsAPI, TlHelp32, CvarDef;

procedure COM_FillChar(const Dest: Pointer; Size: LongWord; Value: Byte);

function GetProcessNameByPID(PID: LongWord): String;
function GetProcessByName(const ProcessName: PChar): LongWord;

procedure StringFromVarRec(const Data: array of const; var S: String); overload;
function StringFromVarRec(const Data: array of const): String; overload;

function GetModuleSize(Address: LongWord): LongWord;

procedure SaveECX;
procedure RestoreECX;

function GetPacketType(B: Byte): String;

implementation

procedure COM_FillChar(const Dest: Pointer; Size: LongWord; Value: Byte);
asm
 cmp edx, 32
 mov ch, cl
 jl @Small
 mov [eax], cx
 mov [eax+2], cx
 mov [eax+4], cx
 mov [eax+6], cx
 sub edx, 16
 fld qword ptr [eax]
 fst qword ptr [eax+edx]
 fst qword ptr [eax+edx+8]
 mov ecx, eax
 and ecx, 7
 sub ecx, 8
 sub eax, ecx
 add edx, ecx
 add eax, edx
 neg edx
@Loop:
 fst qword ptr [eax+edx]
 fst qword ptr [eax+edx+8]
 add edx, 16
 jl @Loop
 ffree st(0)
 ret
 nop
 nop
 nop
@Small:
 test edx, edx
 jle @Done
 mov [eax+edx-1], cl
 and edx, -2
 neg edx
 lea edx, [@SmallFill + 60 + edx * 2]
 jmp edx
 nop
 nop
@SmallFill:
 mov [eax+28], cx
 mov [eax+26], cx
 mov [eax+24], cx
 mov [eax+22], cx
 mov [eax+20], cx
 mov [eax+18], cx
 mov [eax+16], cx
 mov [eax+14], cx
 mov [eax+12], cx
 mov [eax+10], cx
 mov [eax+8], cx
 mov [eax+6], cx
 mov [eax+4], cx
 mov [eax+2], cx
 mov [eax], cx
 ret
@Done:
end;

function GetProcessNameByPID(PID: LongWord): String;
var
 Snapshot: THandle;
 Process: PROCESSENTRY32;
begin
 Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
 Result := '';
 Process.dwSize := SizeOf(Process);

 if Process32First(Snapshot, Process) then
  while Process32Next(Snapshot, Process) do
   if Process.th32ProcessID = PID then
    begin
     Result := Process.szExeFile;
     Break;
    end;

 CloseHandle(Snapshot);
end;

function GetProcessByName(const ProcessName: PChar): LongWord;
var
 Snapshot: THandle;
 Process: PROCESSENTRY32;
 ProcID: LongWord absolute Result;
begin
 Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
 ProcID := 0;
 Process.dwSize := SizeOf(Process); // GOD DEMIT

 if Process32First(Snapshot, Process) then
  while Process32Next(Snapshot, Process) do
   if StrIComp(Process.szExeFile, ProcessName) = 0 then
    begin
     ProcID := Process.th32ProcessID;
     GetModuleHandleA(Process.szExeFile);
     Break;
    end;

 CloseHandle(Snapshot);
end;

procedure StringFromVarRec(const Data: array of const; var S: String);
var
 I: LongInt;
begin
S := '';
for I := 0 to High(Data) do
 with Data[I] do
  case VType of
   vtInteger: S := S + IntToStr(VInteger);
   vtBoolean: S := S + BoolToStr(VBoolean, True);
   vtChar: S := S + VChar;
   vtExtended: S := S + FloatToStr(VExtended^);
   vtString: S := S + VString^;
   vtPChar: S := S + VPChar;
   vtAnsiString: S := S + String(VAnsiString);
  end;
end;

function StringFromVarRec(const Data: array of const): String;
begin
Cardinal(Result) := 0;
StringFromVarRec(Data, Result);
end;

function GetModuleSize(Address: LongWord): LongWord;
asm
 add eax, dword ptr [eax.TImageDosHeader._lfanew]
 mov eax, dword ptr [eax.TImageNtHeaders.OptionalHeader.SizeOfImage]
end;

function GetProcessSize(Handle: LongWord): LongWord;
var
 MemInfo: PROCESS_MEMORY_COUNTERS;
begin
 MemInfo.cb := SizeOf(MemInfo);
 GetProcessMemoryInfo(Handle, @MemInfo, SizeOf(MemInfo));
 Result := MemInfo.WorkingSetSize;
end;

procedure SaveECX;
asm
 mov SavedECX, ecx
end;

procedure RestoreECX;
asm
 mov ecx, SavedECX
end;

function GetPacketType(B: Byte): String;
begin
 case B of
   0: Result := 'HandshakeInit';
   1: Result := 'HandshakeInitAck';
   2: Result := 'HandshakeAck';
   3: Result := 'HandshakeRefused';
   4: Result := 'RetryHandshake';
   5: Result := 'Datagram';
   6: Result := 'DatagramChunk';
   7: Result := 'DatagramAck';
   8: Result := 'DatagramRaw';
   9: Result := 'Shutdown';
   $A: Result := 'ShutdownAck';
   $B: Result := 'Ping';
   $C: Result := 'Pong'
  else Result := '<Unknown>';
 end;
end;

end.
