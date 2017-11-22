unit MemSearch;

{$I Default.inc}

interface

// 28.07.15
// sakijapi.PSA_DummyFunction+6EB614 - start crc checking thread and stuff
// B097AE - crc result compare
// B09570 - another unknown compare function

procedure Toggle_CRCEndChecking(Status: Boolean);
procedure Toggle_PacketsFunc(Status: Boolean);
procedure Toggle_MapIcoRendering(Status: Boolean); // True - cheat, False - original
procedure Toggle_EntityRendering(Status: Boolean); // True - cheat, False - original
procedure Toggle_AsyncException(Status: Boolean); // True - cheat, False - original

function Absolute(BaseAddr, RelativeAddr: LongWord): LongWord; overload;
function Absolute(BaseAddr, RelativeAddr: Pointer): LongWord; overload;
function Absolute(Addr: LongWord): LongWord; overload;
function Absolute(Addr: Pointer): LongWord; overload;
function Relative(Addr, NewFunc: LongWord): LongWord; overload;
function Relative(Addr, NewFunc: Pointer): LongWord; overload;

function Bounds(Address, LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean; overload;
function Bounds(const Address: Pointer; LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean; overload;
function Bounds(Address: Pointer): Boolean; overload;

function CompareMemory_Internal(const Address, Pattern: Pointer; Size: LongWord): Boolean;

function CompareMemory(Address, Pattern, Size: LongWord): Boolean; overload;
function CompareMemory(const Address, Pattern: Pointer; Size: LongWord): Boolean; overload;

procedure ReplaceMemory(Address, Pattern, Size: LongWord); overload;
procedure ReplaceMemory(const Address, Pattern: Pointer; Size: LongWord); overload;

function FindPattern(StartAddr, EndAddr: LongWord; const Pattern: Pointer; PatternSize: LongWord; const Offset: LongInt = 0): Pointer; overload;
function FindPattern(const StartAddr, EndAddr, Pattern: Pointer; PatternSize: LongWord; const Offset: LongInt = 0): Pointer; overload;
function FindPattern(Pattern: Pointer): Pointer; overload;

function CheckByte(Address: LongWord; Value: Byte; const Offset: LongInt = 0): Boolean; overload;
function CheckByte(const Address: Pointer; Value: Byte; const Offset: LongInt = 0): Boolean; overload;
function CheckWord(Address: LongWord; Value: Word; const Offset: LongInt = 0): Boolean; overload;
function CheckWord(const Address: Pointer; Value: Word; const Offset: LongInt = 0): Boolean; overload;
function CheckLongWord(Address, Value: LongWord; const Offset: LongInt = 0): Boolean; overload;
function CheckLongWord(const Address: Pointer; Value: LongWord; const Offset: LongInt = 0): Boolean; overload;

function FindNextByte(const Address: Pointer; const Value: Byte; const Offset: LongInt = 0): Pointer;
function FindNextByteBack(const Address: Pointer; const Value: Byte; const Offset: LongInt = 0): Pointer;
function FindNextWord(const Address: Pointer; const Value: Word; const Offset: LongInt): Pointer;
function FindNextWordBack(const Address: Pointer; const Value: Word; const Offset: LongInt): Pointer;
function FindNextLongWord(const Address: Pointer; const Value: LongWord; const Offset: LongInt): Pointer;
function FindNextLongWordBack(const Address: Pointer; const Value: LongWord; const Offset: LongInt): Pointer;

function FindAllCandidats(const StartAddr, EndAddr, Pattern: Pointer; PatternSize: LongWord; Extended: Boolean = False): LongInt; overload;
function FindAllCandidats(Pattern: Pointer; PatternSize: LongWord; Extended: Boolean = False): LongInt; overload;
function FindAllCandidats(Pattern: String; Extended: Boolean = False): LongInt; overload;
function FindAllCandidats(Pattern: Pointer; Extended: Boolean = False): LongInt; overload;

// procedure PatchByte(Addr: Pointer; B: Byte; B2: Byte = $FF);

function FindMainGameModule: Boolean;
procedure GetMainGameModuleInfo;

//procedure Find_Test;
procedure Load_SakijAPI;
//procedure Patch_SakijAPI;
//procedure Find_recv;
//procedure Find_recvfrom;
//procedure Find_Sakij_DllMain;

//procedure Find_Sakij_Funcs;
function Find_MobsRendererCode: Boolean;

procedure SakijapiHandler;
procedure SakijapiHandlerDbg;

procedure Find_SakijapiHandler;
procedure Hook_SakijapiHandler;
procedure Find_SakijApiCRCCheck;
procedure Hook_SakijApiCRCCheck;

function DisableSakijapiThread: Boolean;

function Find_SeriousRenderCode: LongBool;
function Find_StuffRendererCode: Boolean;
procedure Find_FogRenderCode;
procedure Find_sendto;
procedure Find_recvfrom;

procedure Hook_MySexyHandlerFromAnotherMother;
procedure Find_MySexyHandlerFromAnotherMother;

procedure Find_CxxThrowException;
procedure Hook_CxxThrowException;

procedure Find_CRCResultCheckCode;
procedure Hook_CRCResultCheckCode;

implementation

uses CvarDef, Windows, MsgAPI, Detours, SysUtils, Common, Funcs, Console, TlHelp32;

procedure Toggle_CRCEndChecking(Status: Boolean);
begin
 if Status then
  begin
   PByte(SakijApiCRCEndCheckOrig)^ := $E9;
   PLongWord(LongWord(SakijApiCRCEndCheckOrig) + 1)^ := LongWord(CRCEndJmpAddr);
  end
 else
  begin
   PByte(SakijApiCRCEndCheckOrig)^ := $FF;
   PLongWord(LongWord(SakijApiCRCEndCheckOrig) + 1)^ := $A23F36E2;
  end;
end;

procedure Toggle_AsyncException(Status: Boolean); // True - cheat, False - original
const
 Async_DefBytes: array[0..4] of Byte = ($85, $ED,
                                        $0F, $9D, $C0);
 Async_NewBytes: array[0..4] of Byte = ($B8, $00, $00, $00, $00);
var
 L: LongWord;
 P: Pointer;
begin
 P := Pointer($593C73);
 VirtualProtect(P, 5, PAGE_EXECUTE_READWRITE, L);
 if Status then Move(Async_NewBytes, P^, 5) else Move(Async_DefBytes, P^, 5);
 VirtualProtect(P, 5, L, L);

 P := Pointer($593B5D);
 VirtualProtect(P, 4, PAGE_EXECUTE_READWRITE, L);
 if Status then PLongWord(P)^ := $90FFCD83 else PLongWord(P)^ := $E88BD0FF;
 VirtualProtect(P, 4, L, L);
end;

procedure Toggle_PacketsFunc(Status: Boolean);
var
 L: LongWord;
 P: Pointer;
begin
 P := sendto_Orig;
 VirtualProtect(P, 5, PAGE_EXECUTE_READWRITE, L);
 if Status then
  begin
   PByte(P)^ := $31;
   PLongWord(LongWord(P) + 1)^ := $0018C2C0;
  end
 else
 begin
  PByte(P)^ := $8B;
  PLongWord(LongWord(P) + 1)^ := $EC8B55FF;
 end;
 VirtualProtect(P, 5, L, L);

 P := recvfrom_Orig;
 VirtualProtect(P, 5, PAGE_EXECUTE_READWRITE, L);
 if Status then
  begin
   PByte(P)^ := $31;
   PLongWord(LongWord(P) + 1)^ := $0018C2C0;
  end
 else
 begin
  PByte(P)^ := $8B;
  PLongWord(LongWord(P) + 1)^ := $EC8B55FF;
 end;
 VirtualProtect(P, 5, L, L);
end;

procedure Toggle_MapIcoRendering(Status: Boolean); // True - cheat, False - original
var
 L: LongWord;
 P: Pointer;
begin
 P := MobsRendererCode;
 VirtualProtect(P, 1, PAGE_EXECUTE_READWRITE, L);
 if Status then PByte(P)^ := $FF else PByte(P)^ := $00;
 VirtualProtect(P, 1, L, L);
end;

procedure Toggle_EntityRendering(Status: Boolean); // True - cheat, False - original
var
 L: LongWord;
 P: Pointer;
begin
 P := StuffRendererCode;
 VirtualProtect(P, 4, PAGE_EXECUTE_READWRITE, L);
 if Status then PLongWord(P)^ := $5BFFC883 else PLongWord(P)^ := $5BC0950F;
 VirtualProtect(P, 4, L, L);

 P := FogRendererCode;
 VirtualProtect(P, 1, PAGE_EXECUTE_READWRITE, L);
 if Status then PByte(P)^ := $04 else PByte(P)^ := $1C;
 VirtualProtect(P, 1, L, L);
end;

function GetThreadStartAddress(th32ThreadID: DWORD): LongWord;
var
 hThread: THandle;
 ThreadStartAddress: Pointer;
begin
 Result := 0;
 hThread := OpenThread(THREAD_QUERY_INFORMATION, False, th32ThreadID);
 if (hThread = 0) then
  RaiseLastOSError;
 try
   if NtQueryInformationThread(hThread, ThreadQuerySetWin32StartAddress, @ThreadStartAddress, SizeOf(ThreadStartAddress), nil) = STATUS_SUCCESS then
     Result := LongWord(ThreadStartAddress)
   else
   RaiseLastOSError;
 finally
  CloseHandle(hThread);
 end;
end;

function DisableSakijapiThread: Boolean;
const
 THREAD_ALL_ACCESS = $000F0000 or $00100000 or $3FF;
var
 SnapProcHandle: THandle;
 NextProc: Boolean;
 TThreadEntry: TThreadEntry32;
 BaseStart: LongWord;
 h: LongWord;
begin
 SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
 Result := SnapProcHandle <> INVALID_HANDLE_VALUE;
 if Result then
  try
   TThreadEntry.dwSize := SizeOf(TThreadEntry);
   NextProc := Thread32First(SnapProcHandle, TThreadEntry);

   BaseStart := SakijAPI.BaseStart and $FFF00000;
   while NextProc do
    begin
     if TThreadEntry.th32OwnerProcessID = PWID then
      if (GetThreadStartAddress(TThreadEntry.th32ThreadID) and $FFF00000) = BaseStart then
       begin
        h := OpenThread(THREAD_ALL_ACCESS, False, TThreadEntry.th32ThreadID);
        Result := TerminateThread(h, 0);
        CloseHandle(h);
        Exit;
       end;

      NextProc := Thread32Next(SnapProcHandle, TThreadEntry);
     end;

  Result := False;
  finally
   CloseHandle(SnapProcHandle);
  end;
end;

function FindBytePattern(StartBase, EndBase: LongWord; Pattern: Pointer; PatternSize: LongWord): Pointer; stdcall;
asm
 push edi
 push esi
 push ebx

 mov edi, [StartBase]
 mov edx, [EndBase]
 mov eax, [Pattern]
 mov al, [eax]
 inc [Pattern]
 dec [PatternSize]

@Next:
 mov ecx, edx
 repne scasb
 jne @NotFound

 mov edx, ecx
 mov ecx, [PatternSize]
 mov esi, [Pattern]
 mov ebx, edi

@Cont:
 repe cmpsb
 je @Found

 cmp byte ptr [esi - 1], 0FFh
 je @Cont

 mov edi, ebx
 jmp @Next

@NotFound:
 xor ebx, ebx
 inc ebx

@Found:
 lea eax, [ebx - 1]
 pop ebx
 pop esi
 pop edi
end;

{$IFNDEF ASM}
function Absolute(BaseAddr, RelativeAddr: LongWord): LongWord;
begin
Result := RelativeAddr + BaseAddr + 4;
end;

function Absolute(BaseAddr, RelativeAddr: Pointer): LongWord;
begin
Result := Cardinal(RelativeAddr) + Cardinal(BaseAddr) + 4;
end;

function Absolute(Addr: LongWord): LongWord;
begin
Result := Addr + PCardinal(Addr)^ + 4;
end;

function Absolute(Addr: Pointer): LongWord;
begin
Result := Cardinal(Addr) + PCardinal(Addr)^ + 4;
end;

function Relative(Addr, NewFunc: LongWord): LongWord;
begin
Result := NewFunc - Addr - 5;
end;

function Relative(Addr, NewFunc: Pointer): LongWord;
begin
Result := Cardinal(NewFunc) - Cardinal(Addr) - 5;
end;
{$ELSE}
function Absolute(BaseAddr, RelativeAddr: LongWord): LongWord;
asm
 lea eax, dword ptr [eax + edx + 4]
end;

function Absolute(BaseAddr, RelativeAddr: Pointer): LongWord;
asm
 lea eax, dword ptr [eax + edx + 4]
end;

function Absolute(Addr: LongWord): LongWord;
asm
 add eax, [eax]
 add eax, 4
end;

function Absolute(Addr: Pointer): LongWord;
asm
 add eax, [eax]
 add eax, 4
end;

function Relative(Addr, NewFunc: LongWord): LongWord;
asm
 sub edx, eax
 sub edx, 5
 mov eax, edx
end;

function Relative(Addr, NewFunc: Pointer): LongWord;
asm
 sub edx, eax
 sub edx, 5
 mov eax, edx
end;
{$ENDIF}

{$IFNDEF ASM}
function Bounds(Address, LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
begin
Result := (Address < LowBound) or (Address > HighBound) or (Align and (Address and $F > 0));
end;

function Bounds(const Address: Pointer; LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
begin
Result := (Cardinal(Address) < LowBound) or (Cardinal(Address) > HighBound) or (Align and (Cardinal(Address) and $F > 0));
end;
{$ELSE}
function Bounds(Address, LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
asm
 cmp eax, edx
 jl @Return
 cmp eax, ecx
 jg @Return
 cmp byte ptr [Align], 0
 je @InBounds
 and eax, $F
 jg @Return

@InBounds:
 xor eax, eax
 jmp @StackFrame

@Return:
 mov eax, 1

@StackFrame:
end;

function Bounds(const Address: Pointer; LowBound, HighBound: LongWord; const Align: Boolean = False): Boolean;
asm
 cmp eax, edx
 jl @Return
 cmp eax, ecx
 jg @Return
 cmp byte ptr [Align], 0
 je @InBounds
 and eax, $F
 jg @Return

@InBounds:
 xor eax, eax
 jmp @StackFrame

@Return:
 mov eax, 1

@StackFrame:
end;
{$ENDIF}

function Bounds(Address: Pointer): Boolean;
begin
 Result := Bounds(Cardinal(Address), PWGame.BaseStart, PWGame.BaseEnd);
end;

{$IFNDEF ASM}
function CompareMemory(const Address, Pattern: Pointer; Size: LongWord): Boolean;
var
 I: LongWord;
 B: Byte;
begin
if (Address = nil) or (Pattern = nil) or (Size = 0) then
 Result := False
else
 begin
  for I := 0 to Size - 1 do
   begin
    B := PByte(Cardinal(Pattern) + I)^;
    if (PByte(Cardinal(Address) + I)^ <> B) and (B <> $FF) then
     begin
      Result := False;
      Exit;
     end;
   end;
  Result := True;
 end;
end;
{$ELSE}
function CompareMemory(const Address, Pattern: Pointer; Size: LongWord): Boolean;
asm
 test eax, eax
 je @NotEqual
 test edx, edx
 je @NotEqual
 test ecx, ecx
 je @NotEqual

 push ebx

@Loop:
 mov bl, byte ptr [edx]
 cmp bl, byte ptr [eax]
 je @PostLoop
 sub bl, $FF
 je @PostLoop

 xor eax, eax
 pop ebx
 ret

@PostLoop:
 inc eax
 inc edx
 dec ecx
 jne @Loop

 mov eax, 1
 pop ebx
 ret

@NotEqual:
 xor eax, eax
end;
{$ENDIF}

function CompareMemory(Address, Pattern, Size: LongWord): Boolean;
begin
Result := CompareMemory(Pointer(Address), Pointer(Pattern), Size);
end;

procedure ReplaceMemory(const Address, Pattern: Pointer; Size: LongWord);
var
 I, Protect: LongWord;
begin
if (Address = nil) or (Pattern = nil) or (Size = 0) then
 Exit
else
 begin
  VirtualProtect(Address, Size, PAGE_READWRITE, Protect);
  for I := 0 to Size - 1 do
   PByte(Cardinal(Address) + I)^ := PByte(Cardinal(Pattern) + I)^;
  VirtualProtect(Address, Size, Protect, Protect);
 end;
end;

procedure ReplaceMemory(Address, Pattern, Size: LongWord);
begin
 ReplaceMemory(Pointer(Address), Pointer(Pattern), Size);
end;

function CompareMemory_Internal(const Address, Pattern: Pointer; Size: LongWord): Boolean;
asm
 push ebx

@Loop:
 mov bl, byte ptr [edx]
 cmp bl, byte ptr [eax]
 je @PostLoop
 sub bl, $FF
 je @PostLoop

 xor eax, eax
 pop ebx
 ret

@PostLoop:
 inc eax
 inc edx
 dec ecx
 jne @Loop

 mov eax, 1
 pop ebx
 ret

@NotEqual:
 xor eax, eax
end;

function FindPattern(const StartAddr, EndAddr, Pattern: Pointer; PatternSize: LongWord; const Offset: LongInt = 0): Pointer;
var
 I: LongWord;
begin
if (StartAddr = nil) or (EndAddr = nil) or (Pattern = nil) or (PatternSize = 0) then
 Result := nil
else
 begin
  for I := Cardinal(StartAddr) to Cardinal(EndAddr) - (PatternSize - 1) do
   if CompareMemory_Internal(Pointer(I), Pattern, PatternSize) then
    begin
     Result := Pointer(LongInt(I) + Offset);
     Exit;
    end;
  Result := nil;
 end;
end;

function FindPattern(StartAddr, EndAddr: LongWord; const Pattern: Pointer; PatternSize: LongWord; const Offset: LongInt = 0): Pointer;
begin
Result := FindPattern(Pointer(StartAddr), Pointer(EndAddr), Pattern, PatternSize, Offset);
end;

function FindPattern(Pattern: Pointer): Pointer;
begin
Result := FindPattern(Pointer(PWGame.BaseStart), Pointer(PWGame.BaseEnd), Pattern, SizeOf(Pattern), 0);
end;

function CheckByte(Address: LongWord; Value: Byte; const Offset: LongInt = 0): Boolean;
begin
Result := (Address = 0) or (PByte(LongInt(Address) + Offset)^ <> Value);
end;

function CheckByte(const Address: Pointer; Value: Byte; const Offset: LongInt = 0): Boolean;
begin
Result := (Address = nil) or (PByte(LongInt(Address) + Offset)^ <> Value);
end;

function CheckWord(Address: LongWord; Value: Word; const Offset: LongInt = 0): Boolean;
begin
Result := (Address = 0) or (PWord(LongInt(Address) + Offset)^ <> Value);
end;

function CheckWord(const Address: Pointer; Value: Word; const Offset: LongInt = 0): Boolean;
begin
Result := (Address = nil) or (PWord(LongInt(Address) + Offset)^ <> Value);
end;

function CheckLongWord(Address, Value: LongWord; const Offset: LongInt = 0): Boolean;
begin
Result := (Address = 0) or (PLongWord(LongInt(Address) + Offset)^ <> Value);
end;

function CheckLongWord(const Address: Pointer; Value: LongWord; const Offset: LongInt = 0): Boolean;
begin
Result := (Address = nil) or (PLongWord(LongInt(Address) + Offset)^ <> Value);
end;

function FindNextByte(const Address: Pointer; const Value: Byte; const Offset: LongInt = 0): Pointer;
var
 L: LongInt;
begin
 Result := nil;

 if Address = nil then
  Exit
 else
 for L := 0 to MAX_ATTEMPTS - 1 do
  if PByte(LongInt(Address) + L)^ = Value then
   begin
    Result := Pointer(LongInt(Address) + L + Offset);
    Exit;
   end;
end;

function FindNextByteBack(const Address: Pointer; const Value: Byte; const Offset: LongInt = 0): Pointer;
var
 L: LongInt;
begin
 Result := nil;

 if Address = nil then
  Exit
 else
 for L := 0 to MAX_ATTEMPTS - 1 do
  if PByte(LongInt(Address) - L)^ = Value then
   begin
    Result := Pointer(LongInt(Address) - L + Offset);
    Exit;
   end;
end;

function FindNextWord(const Address: Pointer; const Value: Word; const Offset: LongInt): Pointer;
var
 L: LongInt;
begin
 Result := nil;

 if Address = nil then
  Exit
 else
 for L := 0 to MAX_ATTEMPTS - 1 do
  if PWord(LongInt(Address) + L)^ = Value then
   begin
    Result := Pointer(LongInt(Address) + L + Offset);
    Exit;
   end;
end;

function FindNextWordBack(const Address: Pointer; const Value: Word; const Offset: LongInt): Pointer;
var
 L: LongInt;
begin
 Result := nil;

 if Address = nil then
  Exit
 else
 for L := 0 to MAX_ATTEMPTS - 1 do
  if PWord(LongInt(Address) - L)^ = Value then
   begin
    Result := Pointer(LongInt(Address) - L + Offset);
    Exit;
   end;
end;

function FindNextLongWord(const Address: Pointer; const Value: LongWord; const Offset: LongInt): Pointer;
var
 L: LongInt;
begin
 Result := nil;

 if Address = nil then
  Exit
 else
 for L := 0 to MAX_ATTEMPTS - 1 do
  if PLongWord(LongInt(Address) + L)^ = Value then
   begin
    Result := Pointer(LongInt(Address) + L + Offset);
    Exit;
   end;
end;

function FindNextLongWordBack(const Address: Pointer; const Value: LongWord; const Offset: LongInt): Pointer;
var
 L: LongInt;
begin
 Result := nil;

 if Address = nil then
  Exit
 else
 for L := 0 to MAX_ATTEMPTS - 1 do
  if PLongWord(LongInt(Address) - L)^ = Value then
   begin
    Result := Pointer(LongInt(Address) - L + Offset);
    Exit;
   end;
end;

function FindAllCandidats(const StartAddr, EndAddr, Pattern: Pointer; PatternSize: LongWord; Extended: Boolean = False): LongInt;
var
 I: LongWord;
begin
if (StartAddr = nil) or (EndAddr = nil) or (Pattern = nil) or (PatternSize = 0) then
 Result := -1
else
 begin
  Result := 0;
  for I := Cardinal(StartAddr) to Cardinal(EndAddr) - (PatternSize - 1) do
   if CompareMemory_Internal(Pointer(I), Pattern, PatternSize) then
    begin
     if Extended then
      ShowPointer(I);
     Inc(Result);
    end;
 end;
end;

function FindAllCandidats(Pattern: Pointer; PatternSize: LongWord; Extended: Boolean = False): LongInt;
begin
 Result := FindAllCandidats(Pointer(PWGame.BaseStart), Pointer(PWGame.BaseEnd), Pattern, PatternSize, Extended);
end;

function FindAllCandidats(Pattern: String; Extended: Boolean = False): LongInt;
begin
 Result := FindAllCandidats(Pointer(PWGame.BaseStart), Pointer(PWGame.BaseEnd), Pointer(Pattern), Length(Pattern), Extended);
end;

function FindAllCandidats(Pattern: Pointer; Extended: Boolean = False): LongInt;
begin
 Result := FindAllCandidats(Pointer(PWGame.BaseStart), Pointer(PWGame.BaseEnd), Pointer(Pattern), SizeOf(Pattern), Extended);
end;

{procedure PatchByte(Addr: Pointer; B: Byte; B2: Byte = $FF);
var
 Protect: LongWord;
begin
 if Addr = nil then
  Exit;

 if B2 <> $FF then
  if PByte(Addr)^ <> B2 then
   RaiseError('PatchByte: Current address is not consists required byte.');

 VirtualProtect(Addr, SizeOf(Byte), PAGE_EXECUTE_READWRITE, Protect);
 PByte(Addr)^ := B;
 VirtualProtect(Addr, SizeOf(Byte), Protect, Protect);
end;}

function FindMainGameModule: Boolean;
begin
 PWID := GetProcessByName('PW_Game.exe');
 Result := PWID <> 0;
end;

procedure GetMainGameModuleInfo;
var
 H: THandle;
 L: LongWord;
label
 Loop;
begin
Loop:
 L := GetModuleHandle(nil);
 if L = 0 then
  begin
   Sleep(100);
   goto Loop;
  end;

 PWGame.BaseStart := L;

 H := OpenProcess(PROCESS_ALL_ACCESS, False, PWID);
 ReadProcessMemory(H, Pointer(PWGame.BaseStart), @PWDOSHeader, SizeOf(PWDOSHeader), PLongWord(nil)^);
 ReadProcessMemory(H, Pointer(PWGame.BaseStart + PWDOSHeader._lfanew), @PWNTHeader, SizeOf(PWNTHeader), PLongWord(nil)^);
 CloseHandle(H);
 
 PWGame.BaseSize := PWNTHeader.OptionalHeader.SizeOfImage * PWNTHeader.OptionalHeader.SectionAlignment;
 PWGame.BaseEnd := PWGame.BaseStart + PWGame.BaseSize;
end;

{procedure Find_Test;
const
 Pattern: array[0..9] of Char = 'openWarFog';
var
 Addr: Pointer;
begin
 Addr := FindPattern(PWGame.BaseStart, PWGame.BaseEnd, @Pattern, SizeOf(Pattern));
 ShowPointer(Addr);
end; }

procedure Load_SakijAPI;
var
 I, L: LongInt; // because speed
begin
 I := GetModuleHandle('sakijapi.dll');
 if I = 0 then
  RaiseError('Failed to find "sakijapi.dll" base address.');

 SakijAPI.BaseStart := I;
 L := GetModuleSize(SakijAPI.BaseStart);
 SakijAPI.BaseSize := L;
 SakijAPI.BaseEnd := I + L - 5;
end;

{procedure Patch_SakijAPI;
var
 //DllMain: Pointer;
 Addr: Pointer;
 Protect: LongWord;
begin
 {DllMain := Pointer(SakijAPI.BaseStart + $B167);
 DllMain := Pointer(LongWord(DllMain) + 57);

 VirtualProtect(DllMain, 5, PAGE_EXECUTE_READWRITE, Protect);
 WriteNOPs(DllMain, 5);
 VirtualProtect(DllMain, 5, Protect, Protect);


 Addr := Pointer(SakijAPI.BaseStart + $10E2B4);

 VirtualProtect(Addr, 6, PAGE_EXECUTE_READWRITE, Protect);
 WriteNOPs(Addr, 6);
 VirtualProtect(Addr, 6, Protect, Protect);

 WriteLn('Patch_SakijAPI(): True');
end;

procedure Find_recv;
var
 WS2Base: LongWord;
begin
 WS2Base := GetModuleHandle('WS2_32.dll');
 recv_Orig := GetProcAddress(WS2Base, 'recv');

 if @recv_Orig = nil then
  RaiseError('Failed to find "recv" pointer.');

 WriteLn('recv: $', IntToHex(LongWord(@recv_Orig), 8));
end;

procedure Find_recvfrom;
var
 WS2Base: LongWord;
begin
 WS2Base := GetModuleHandle('WS2_32.dll');
 recvfrom_Orig := GetProcAddress(WS2Base, 'recvfrom');

 if @recvfrom_Orig = nil then
  RaiseError('Failed to find "recvfrom" pointer.');

 WriteLn('recvfrom: $', IntToHex(LongWord(@recvfrom_Orig), 8));
end;

procedure Find_Sakij_DllMain;
begin
 DllMain_Orig := Pointer(SakijAPI.BaseStart + $B167);

 if PWord(@DllMain_Orig)^ <> $086A then
  RaiseError('Failed to find "DllMain_Orig" pointer.');
end;

procedure Find_Sakij_Funcs;
var
 Base: LongWord;
begin
 Base := SakijAPI.BaseStart;

 @PSM_0_Orig := GetProcAddress(Base, 'PSM_0');
 @PSC_Uninitialize_Orig := GetProcAddress(Base, 'PSC_Uninitialize');
 @PSC_StartInitialization_Orig := GetProcAddress(Base, 'PSC_StartInitialization');
 @PSC_PerformInitializationAtValidLicense_Orig := GetProcAddress(Base, 'PSC_PerformInitializationAtValidLicense');
 @PSC_LoadString_Orig := GetProcAddress(Base, 'PSC_LoadString');
 @PSC_LeaveGlobalCriticalSection_Orig := GetProcAddress(Base, 'PSC_LeaveGlobalCriticalSection');
 @PSC_GetErrorInformation_Orig := GetProcAddress(Base, 'PSC_GetErrorInformation');
 @PSC_FinishInitializationSuccess_Orig := GetProcAddress(Base, 'PSC_FinishInitializationSuccess');
 @PSC_FinishInitializationFailure_Orig := GetProcAddress(Base, 'PSC_FinishInitializationFailure');
 @PSC_EnterGlobalCriticalSection_Orig := GetProcAddress(Base, 'PSC_EnterGlobalCriticalSection');
 @PSA_Uninitialize_Orig := GetProcAddress(Base, 'PSA_Uninitialize');
 @PSA_DummyFunction_Orig := GetProcAddress(Base, 'PSA_DummyFunction');
end;}

{procedure ClearConsole;
const
 sTrashLine = #32#32#32#32#32#32#32#32#32#32#32#32 + // 9 * 12 = 108 bytes
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32 +
              #32#32#32#32#32#32#32#32#32#32#32#32;
var
 L: LongInt;
 Coord: TCoord;
begin
 Coord.X := 0;
 Coord.Y := 0;
 SetConsoleCursorPosition(hConsole, Coord);

 for L := 0 to 63 do
  WriteLn(sTrashLine);

 SetConsoleCursorPosition(hConsole, Coord);
end;}

function WriteSakijapiHandlerInfo(P: Pointer): LongWord;
var
 I: LongInt;
 B: Boolean;
begin
 B := False;

 for I := 0 to Length(PtrsInfo) - 1 do
  if PtrsInfo[I].Addr = P then
   begin
    Inc(PtrsInfo[I].Count);
    Result := I;
    B := True;
    Break;
   end;

 if not B then
  begin
   Result := Length(PtrsInfo);
   SetLength(PtrsInfo, Result + 1);

   PtrsInfo[Result].ID := Result;
   PtrsInfo[Result].Count := 1;
   PtrsInfo[Result].Addr := P;
   PtrsInfo[Result].ThreadID := GetCurrentThreadId;
  end;
end;

var
 TempShit: LongInt = -1;
 TempEAX: LongInt = -1;

procedure SakijapiHandlerDbg;
asm
 push ebx
 push ecx
 push edx
 push esi
 push edi
 lea ecx, [esp+24]
 push ecx
 push ebp
 pushfd
 cld
 xchg [esp+32], eax

 //jmp @Skip

 pushad
  call WriteSakijapiHandlerInfo
  mov dword ptr [TempShit], eax
 popad

 {pushad
  mov eax, dword ptr [TempShit]
  lea eax, [PtrsInfo+eax*4]
  mov eax, [eax]

  add eax, 8 + 12
  mov [eax], 0DEFACEDh
  mov [eax+4], ecx
  mov [eax+8], edx
  mov [eax+12], ebx
  mov [eax+16], esp
  mov [eax+20], ebp
  mov [eax+24], esi
  mov [eax+28], edi

  pushfd
   mov edx, [esp]
  popfd

  mov [eax+32], edx

  //add eax, 36
  //lea edx, [esp+32]
  //lea ecx, [STACK_DUMPSIZE*4]
  //call CopyMemory
 popad}

@Skip:

 jmp eax
end;

procedure HandleDangerousThread;
begin
 if AdvancedRenderIsActive then
  begin
   Toggle_EntityRendering(False);
   B2 := False;

   //AdvancedRenderIsActive := False;
  end;

 if CasualRenderIsActive then
  begin
   Toggle_MapIcoRendering(False);
   B3 := False;

   //CasualRenderIsActive := False;
  end;
end;

procedure SakijapiHandler;
asm
 push ebx
 push ecx
 push edx
 push esi
 push edi
 lea ecx, [esp+24]
 push ecx
 push ebp
 pushfd
 cld
 xchg [esp+32], eax

 pushad
  add eax, 8
  mov eax, dword ptr [eax]

  // cmp eax, 0FFC1915Ch
  // cmp eax, 0FFF5493Bh
  // cmp eax, 0FF6E79B1h
  // cmp eax, 0FFCC8BC0h
  cmp eax, 0FFB762A5h
  jne @IsNotDangerThread
   call HandleDangerousThread
@IsNotDangerThread:

 popad

 jmp eax
end;

procedure Find_SakijapiHandler;
const
 Pattern: array[0..5] of Byte = ($53,
                                 $51,
                                 $52,
                                 $56,
                                 $57,
                                 $8D);
asm
 push type Pattern
 push offset Pattern
 push [SakijAPI.BaseSize]
 push [SakijAPI.BaseStart]
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  mov eax, ERRORTYPE_SEARCH
  inc eax
  jmp RaiseErrorCode

@GoodByte:
 mov [SakijAPIHandlerOrig], eax
end;

procedure Hook_SakijapiHandler;
var
 P: Pointer;
 L: LongWord;
begin
 P := SakijAPIHandlerOrig;

 VirtualProtect(P, 5, PAGE_EXECUTE_READWRITE, L);

  asm
   mov eax, P
   mov edx, offset SakijapiHandler
   sub edx, eax
   sub edx, 5
   mov byte ptr [eax], 0E9h
   mov dword ptr [eax+1], edx
  end;

 VirtualProtect(P, 5, L, L);
end;

procedure SakijApiCRCCheck;
asm
 pop esi

 {pushad
 // our code here
 popad}

 mov ecx, esi
 inc ecx
 jmp ecx
end;

procedure Find_SakijApiCRCCheck;
const
 Pattern: array[0..5] of Byte = ($81, $C6, $5C, $91, $C1, $FF);
asm
 push type Pattern
 push offset Pattern
 push [SakijAPI.BaseSize]
 push [SakijAPI.BaseStart]
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  mov eax, ERRORTYPE_SEARCH
  add eax, 80h
  jmp RaiseErrorCode

@GoodByte:
 sub eax, 5
 mov [SakijApiCRCCheckOrig], eax
end;

procedure Hook_SakijApiCRCCheck;
asm
 push edi
 push esi

 mov edi, [SakijApiCRCCheckOrig]
 mov esi, offset SakijApiCRCCheck
 sub esi, edi
 sub esi, 4

 push esp
 push esp
 push PAGE_EXECUTE_READWRITE
 push 4
 push edi
 call VirtualProtect

 mov dword ptr [edi], esi

 push [esp]
 push 4
 push edi
 call VirtualProtect

 pop esi
 pop edi
end;

function Find_SeriousRenderCode: LongBool;
const
 ErrorText: PChar = 'Failed to find SeriousRenderCode pattern.';
 Pattern: array[0..9] of Byte =
 ($8B, $54, $0B, $04,
  $8B, $0C, $BA,
  $80, $3C, $08);
asm
 push type Pattern
 push offset Pattern
 push [PWGame.BaseSize]
 push [PWGame.BaseStart]
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  ret

@GoodByte:
 add eax, 10

 cmp byte ptr [eax], 0
 je @ERIsInactive
  inc [AdvancedRenderIsActive]

@ERIsInactive:
 mov [SeriousRenderCode], eax
end;

function Find_MobsRendererCode: Boolean;
const
 ErrorText: PChar = 'Failed to get process memory.';
 ErrorText2: PChar = 'Failed to find MobsRendererCode pointer.';

 {Pattern: array[0..19] of Byte =
 ($D8, $5C, $24, $FF,
  $DF, $E0,
  $F6, $C4, $41,
  $0F, $84, $FF, $FF, $FF, $FF,
  $80, $FF, $FF, $FF,
  $8B);}
 // since 15.06.15
 Pattern: array[0..10] of Byte =
 ($0F, $84, $FF, $FF, $FF, $FF,
  $80, $7D, $24, $FF,
  $0F);
asm
 push esi // BaseSize
 push edi
 push ebx

 mov esi, [PWGame.BaseSize]
 mov edi, eax

 mov ebx, [PWGame.BaseStart]

 push type Pattern
 push offset Pattern
 push esi
 push ebx
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  mov eax, ERRORTYPE_SEARCH
  add eax, 2

@GoodByte:
 add eax, 9
 mov [MobsRendererCode], eax

@Finish:
 pop ebx
 pop edi
 pop esi
end;

function Find_StuffRendererCode: Boolean;
const
 Pattern: array[0..4] of Byte =
 ($80, $3C, $08, $00,
  $5F);
asm
 push type Pattern
 push offset Pattern
 push [PWGame.BaseSize]
 push [PWGame.BaseStart]
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  mov eax, ERRORTYPE_SEARCH
  add eax, 3
  jmp RaiseErrorCode

@GoodByte:
 add eax, 7
 mov [StuffRendererCode], eax
end;

procedure Find_FogRenderCode;
const
 Pattern: array[0..8] of Byte =
 ($8B, $44, $FF, $FF,
  $33, $DB,
  $38, $FF, $02);
asm
 push type Pattern
 push offset Pattern
 push [PWGame.BaseSize]
 push [PWGame.BaseStart]
 call FindBytePattern

 dec eax
 jns @GoodByte
  mov eax, ERRORTYPE_SEARCH
  add eax, 4
  jmp RaiseErrorCode

@GoodByte:
 add eax, 8
 mov [FogRendererCode], eax
end;

procedure Find_sendto;
begin
 sendto_Orig := GetProcAddress(GetModuleHandle('ws2_32.dll'), 'sendto');
 if sendto_Orig = nil then
  RaiseErrorCode(ERRORTYPE_SEARCH or $20);
end;

procedure Find_recvfrom;
begin
 recvfrom_Orig := GetProcAddress(GetModuleHandle('ws2_32.dll'), 'recvfrom');
 if recvfrom_Orig = nil then
  RaiseErrorCode(ERRORTYPE_SEARCH or $30);
end;

procedure MySexyHandlerFromAnotherMother;
{begin
 if AdvancedRenderIsActive then
  Toggle_EntityRendering(True);

 if CasualRenderIsActive then
  Toggle_MapIcoRendering(True);}
asm
 pop esi
 lea ecx, [esi+1]
 pushad

 cmp byte ptr [AdvancedRenderIsActive], 0
 je @Skip1
  mov al, 1
  call Toggle_EntityRendering
@Skip1:
 cmp byte ptr [CasualRenderIsActive], 0
 je @Skip2
  mov al, 1
  call Toggle_MapIcoRendering
@Skip2:

 popad
 jmp ecx
end;

procedure Find_MySexyHandlerFromAnotherMother;
const
 Pattern: array[0..5] of Byte = ($81, $C6, $5C, $91, $C1, $FF);
asm
 push type Pattern
 push offset Pattern
 push [SakijAPI.BaseSize]
 push [SakijAPI.BaseStart]
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  mov eax, ERRORTYPE_SEARCH
  add eax, 90h
  jmp RaiseErrorCode

@GoodByte:
 add eax, 37
 mov [SakijApiCRCEndCheckOrig], eax
end;

// sakijapi.PSC_LoadString+40EEA6
procedure Hook_MySexyHandlerFromAnotherMother;
asm
 push edi
 push esi

 mov edi, [SakijApiCRCEndCheckOrig]
 mov esi, offset MySexyHandlerFromAnotherMother

 sub esi, edi
 sub esi, 5

 push esp
 push esp
 push PAGE_EXECUTE_READWRITE
 push 5
 push edi
 call VirtualProtect

 mov byte ptr [edi], 0E9h
 mov dword ptr [edi+1], esi

 push [esp]
 push 5
 push edi
 call VirtualProtect

 pop esi
 pop edi
end;

procedure Find_CxxThrowException;
var
 P: Pointer;
 h: THandle;
begin
 h := GetModuleHandle('MSVCR90.dll');
 if h = 0 then
  RaiseErrorCode(ERRORTYPE_SEARCH or $B0);

 {P := GetProcAddress(h, 'CxxThrowException');
 if P = nil then
  RaiseErrorCode(ERRORTYPE_SEARCH or $B1);}

 P := Pointer(h + $5DF18);
 if PWord(P)^ <> $FF8B then
  RaiseErrorCode(ERRORTYPE_SEARCH or $B1);

 CxxThrowException_Orig := P;
end;

procedure Hook_CxxThrowException;
var
 P: Pointer;
 L: LongWord;
 I: LongWord;
begin
 P := CxxThrowException_Orig;
 VirtualProtect(P, 8, PAGE_EXECUTE_READWRITE, L);

 I := $593B91 - LongWord(P) - 8;
 PLongWord(P)^ := $E90CC483;
 PLongWord(LongWord(P) + 4)^ := I;

 VirtualProtect(P, 8, L, L);
end;

procedure Find_CRCResultCheckCode;
const
 Pattern: array[0..5] of Byte = ($81, $C6, $59, $3F, $E3, $FF);
asm
 push type Pattern
 push offset Pattern
 push [SakijAPI.BaseSize]
 push [SakijAPI.BaseStart]
 call FindBytePattern

 test eax, eax
 jnz @GoodByte
  mov eax, ERRORTYPE_SEARCH
  add eax, 0C0h
  jmp RaiseErrorCode

@GoodByte:
 sub eax, 5
 mov [CRCResultCheckCode], eax
end;

procedure Hook_CRCResultCheckCode;
asm
 push edi
 push esi

 mov edi, [CRCResultCheckCode]
 mov esi, offset MySexyHandlerFromAnotherMother

 sub esi, edi
 sub esi, 4

 push esp
 push esp
 push PAGE_EXECUTE_READWRITE
 push 5
 push edi
 call VirtualProtect

 mov dword ptr [edi], esi

 push [esp]
 push 5
 push edi
 call VirtualProtect

 pop esi
 pop edi
end;

end.
