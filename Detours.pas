unit Detours;

{$I Default.inc}

interface

procedure WriteNOPs(const BaseAddr: Pointer; Count: LongWord);
function Detour(const BaseAddr, NewAddr: Pointer; const CodeLength: LongWord = 5): Pointer;
function DetourEx(const BaseAddr, NewAddr: Pointer; const FuncName: String): Pointer;

implementation

uses Windows, MemSearch, CvarDef, Common, AsmReader, MsgAPI, Console;

procedure WriteNOPs(const BaseAddr: Pointer; Count: LongWord);
begin
 COM_FillChar(BaseAddr, Count, $90);
end;

function Detour(const BaseAddr, NewAddr: Pointer; const CodeLength: LongWord = 5): Pointer;
var
 Ptr: Pointer;
 Protect: LongWord;
begin
if BaseAddr = nil then
 RaiseError('Detour: Invalid base address.')
else
if NewAddr = nil then
 RaiseError('Detour: Invalid function address.')
else
if CodeLength < 5 then
 RaiseError('Detour: Invalid code length.');

GetMem(Ptr, CodeLength + 5);

VirtualProtect(Ptr, CodeLength + 5, PAGE_EXECUTE_READWRITE, Protect);

VirtualProtect(BaseAddr, CodeLength, PAGE_EXECUTE_READWRITE, Protect);

CopyMemory(Ptr, BaseAddr, CodeLength);

PByte(Cardinal(Ptr) + CodeLength)^ := $E9;
PCardinal(Cardinal(Ptr) + CodeLength + 1)^ := Relative(Ptr, BaseAddr);

if CodeLength > 5 then
 WriteNOPs(Pointer(Cardinal(BaseAddr) + 5), CodeLength - 5);

PByte(BaseAddr)^ := $E9;
PCardinal(Cardinal(BaseAddr) + 1)^ := Relative(BaseAddr, NewAddr);

VirtualProtect(BaseAddr, CodeLength, Protect, Protect);

Result := Ptr;
end;

function DetourEx(const BaseAddr, NewAddr: Pointer; const FuncName: String): Pointer;
begin
 Result := nil;
 
 if BaseAddr = nil then
  RaiseError(['DetourEx: Invalid base address (', FuncName, ').'])
 else
 if BaseAddr = nil then
  RaiseError(['DetourEx: Invalid function address (', FuncName, ').'])
 else
 Result := Detour(BaseAddr, NewAddr, GetValidCodeLength(BaseAddr));

 SetConsoleTextColor(COLOR_YELLOW_INTENS);
 WriteLn('DetourEx: ', FuncName, ' is hooked.');
 SetConsoleTextColor(COLOR_GREY);
end;

end.
