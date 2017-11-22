unit Funcs;

interface

uses
 MsgAPI, CvarDef, Common, Console, SysUtils, WinSock, FileLog, Hacks;

procedure HookMessage(Unk1, Unk2, Unk3, Unk4: Pointer); stdcall;
procedure HookMessage2(Unk1: Pointer); stdcall;
//function HookMessage3(Unk1, Unk2: Pointer; Unk3: LongWord): LongWord; stdcall;
procedure HookMessage4;
procedure HookMessage5;

function sub_815FA0: Pointer; stdcall;
procedure sub_816020; stdcall;
procedure sub_8211A0; stdcall;
procedure sub_4F6660; cdecl;

procedure SakijTrap; cdecl;

function recv_Our(S: TSocket; var Buf; Len, Flags: LongInt): LongInt; stdcall;
function recvfrom_Our(S: TSocket; Buf: Pointer; Len, Flags: LongInt; var From: TSockAddr; var FromLen: LongInt): LongInt; stdcall;

function DllMain_Our(hinstDLL: HINST; fdwReason: LongWord; lpvReserved: Pointer): Boolean; stdcall;

procedure PSM_0_Our; stdcall;
function PSC_Uninitialize_Our: LongInt; stdcall;
function PSC_StartInitialization_Our(Unk: LongWord): LongInt; stdcall;
function PSC_PerformInitializationAtValidLicense_Our: LongInt; stdcall;
function PSC_LoadString_Our(Unk1: Pointer; Unk2: LongInt; Unk3: Pointer): LongWord; stdcall;
function PSC_LeaveGlobalCriticalSection_Our: LongInt; stdcall;
function PSC_GetErrorInformation_Our(Unk1: Pointer; Unk2: PLongInt; Unk3: LongInt; Unk4: PLongInt): LongInt; stdcall;
function PSC_FinishInitializationSuccess_Our: LongInt; stdcall;
function PSC_FinishInitializationFailure_Our: LongInt; stdcall;
function PSC_EnterGlobalCriticalSection_Our: LongInt; stdcall;
function PSA_Uninitialize_Our: LongInt; stdcall;
procedure PSA_DummyFunction_Our; stdcall;

procedure sub_7A75B0_Our(Str: PChar); cdecl;
//function sub_75A7D0_Our(A1: PChar): LongWord; cdecl;
procedure sub_75A7D0_Our;

procedure sub_6D8D00_Our;
procedure sub_AD0A90;

implementation

uses
 Windows;

procedure HookMessage(Unk1, Unk2, Unk3, Unk4: Pointer); stdcall;
{begin
 SaveECX;
 asm pushad end;
 RaiseAlert('HookMessage()');
 asm popad end;
 RestoreECX;
 LoadSceneMapObjects(Unk1, Unk2, Unk3, Unk4);
end;}
asm
 pushad
  mov eax, offset @Str
  call RaiseAlert
 popad

 jmp sub_820450
 
@Str:
 db 'HookMessage()', 0
end;

procedure HookMessage2(Unk1: Pointer); stdcall;
begin
 asm pushad end;

 RaiseAlert('HookMessage2()');

 asm popad end;
 HookMessage2(Unk1);
end;

{function HookMessage3(Unk1, Unk2: Pointer; Unk3: LongWord): LongWord; stdcall;
begin
 asm pushad end;

 RaiseAlert('HookMessage3()');
 RaiseAlert(IntToStr(Unk3));

 asm popad end;

 Result := PSC_LoadString_Gate(Unk1, Unk2, Unk3);
end;}

procedure SakijTrap; cdecl;
asm
 //mov eax, offset @Trap
 //call RaiseInfo

 xor eax, eax
 call EndThread

@Trap:
 db 'Trap.',0
end;



function sub_815FA0: Pointer; stdcall;
asm
 pushad

 mov eax, offset @Str
 call RaiseInfo

 popad

 jmp sub_815FA0_Gate
 
@Str:
 db 'sub_815FA0',0
end;

procedure sub_816020; stdcall;
asm
 pushad

 mov eax, offset @Str
 call RaiseInfo

 popad

 jmp sub_816020_Gate

@Str:
 db 'sub_816020',0

end;

procedure sub_8211A0; stdcall;
asm
 pushad

 mov eax, offset @Str
 call RaiseInfo

 popad

 jmp sub_8211A0_Gate

@Str:
 db 'sub_8211A0',0
end;

procedure sub_4F6660; cdecl;
asm
 pushad

 mov eax, offset @Str
 call RaiseInfo

 popad

 jmp sub_4F6660_Gate

@Str:
 db 'sub_4F6660',0
end;

function recv_Our(S: TSocket; var Buf; Len, Flags: LongInt): LongInt; stdcall;
var
 BufF: String;
begin
 Result := recv_Gate(S, Buf, Len, Flags);

 BufF := '';
// for L := 0 to Result - 1 do
//  BufF := BufF + IntToHex(PByte(Buf)[L])
 WriteLn('recv_Our: S = ', S, '; Len: ', Result);
end;

function recvfrom_Our(S: TSocket; Buf: Pointer; Len, Flags: LongInt; var From: TSockAddr; var FromLen: LongInt): LongInt; stdcall;
type
 TArrayOfByte = array of Byte;
var
 L: LongInt;
 BufF: String;
 S2: String;

 // debug info
 Remote: LongWord;
 Seq: LongWord;
 PacketType: String;
 Size: LongWord;
 DestR: LongWord;
 LocalAddr: LongWord;
begin
 Result := recvfrom_Gate(S, Buf^, Len, Flags, From, FromLen);

 if (Result = SOCKET_ERROR) then
  begin
   WriteLn('recvfrom_Our: Result = SOCKET_ERROR');
   File_WriteLog('recvfrom_Our: Result = SOCKET_ERROR');
   Exit;
  end;

 if Result = 0 then
  begin
   WriteLn('recvfrom_Our: Connection closed gracefully.');
   File_WriteLog('recvfrom_Our: Connection closed gracefully.');
   Exit;
  end;

 if not EnableFileLog then Exit;

 if EnablePacketPatch then
  if PByte(Buf)^ = 5 then
   TArrayOfByte(Buf)[5] := $FF;

 SetLength(S2, Result);
 Move(Buf^, S2[1], Result);

 BufF := '';
 for L := 1 to Result do
  begin
   BufF := BufF + IntToHex(Ord(S2[L]), 2) + #32;
   if L mod 4 = 0 then
    BufF := BufF + '| ';
  end;

 SetLength(BufF, Length(BufF) - 1); // remove #32

 //WriteLn('recvfrom_Our: S = ', S, #9'; Len = ', Result, #9'; From: ', inet_ntoa(From.sin_addr), ':', From.sin_port);
 Write('recvfrom_Our: S = ', S, #9'; Len = ', Result, #9'; Header: ');
 for L := 1 to 8 do
  Write(IntToHex(Ord(S2[L]), 2) + #32);
 WriteLn;

 File_WriteLog('recvfrom_Our: S = ' + IntToStr(S) + #9'; Len = ' + IntToStr(Result) + #9'; From: ' + inet_ntoa(From.sin_addr) + ':' + IntToStr(From.sin_port));

 File_WriteLog('recvfrom_Our: Buf = ');
 File_WriteLog(BufF);
 File_WriteLog('');
end;

function DllMain_Our(hinstDLL: HINST; fdwReason: LongWord; lpvReserved: Pointer): Boolean; stdcall;
var
 Reason: String;
begin
 case fdwReason of
   DLL_PROCESS_ATTACH: Reason := 'DLL_PROCESS_ATTACH';
   DLL_PROCESS_DETACH: Reason := 'DLL_PROCESS_DETACH';
   DLL_THREAD_ATTACH: Reason := 'DLL_THREAD_ATTACH';
   DLL_THREAD_DETACH: Reason := 'DLL_THREAD_DETACH';
  else Reason := 'DLL_UNKNOWN';
 end;

 if MaphackIsActive then
  begin
   MaphackIsActive := False;
   SetConsoleTextColor(FOREGROUND_RED);
   WriteLn('PanicMap: sakijapi has been called; deactivating cheat.');
   SetConsoleTextColor(COLOR_GREY);
  end;


 //WriteLn('SakijAPI.DllMain(0x', IntToHex(LongWord(hinstDLL), 8), ', ', Reason, ', 0x', IntToHex(LongWord(lpvReserved), 8), ')');
 WriteLn('SakijAPI.DllMain: ', Reason);
{ if fdwReason = DLL_THREAD_DETACH then
  Result := DllMain_Gate(hinstDLL, fdwReason, lpvReserved)
 else
  Result := True;}

 Result := True;
end;

// sakijapi
procedure PSM_0_Our; stdcall;
begin
 PSM_0_Orig;
 WriteLn('PSM_0();');
end;

function PSC_Uninitialize_Our: LongInt; stdcall;
begin
 Result := PSC_Uninitialize_Orig;
 WriteLn('PSC_Uninitialize();');
end;

function PSC_StartInitialization_Our(Unk: LongWord): LongInt; stdcall;
begin
 Result := PSC_StartInitialization_Orig(Unk);
 WriteLn('PSC_StartInitialization(', Unk, ');');
end;

function PSC_PerformInitializationAtValidLicense_Our: LongInt; stdcall;
begin
 Result := PSC_PerformInitializationAtValidLicense_Orig;
 WriteLn('PSC_PerformInitializationAtValidLicense();');
end;

function PSC_LoadString_Our(Unk1: Pointer; Unk2: LongInt; Unk3: Pointer): LongWord; stdcall;
begin
 Result := PSC_LoadString_Orig(Unk1, Unk2, Unk3);
 WriteLn('PSC_LoadString(', IntToHex(LongWord(Unk1), 8), ', ', Unk2, ', ', IntToHex(LongWord(Unk3), 8), ');');
end;

function PSC_LeaveGlobalCriticalSection_Our: LongInt; stdcall;
begin
 Result := PSC_LeaveGlobalCriticalSection_Orig;
 WriteLn('PSC_LeaveGlobalCriticalSection();');
end;

function PSC_GetErrorInformation_Our(Unk1: Pointer; Unk2: PLongInt; Unk3: LongInt; Unk4: PLongInt): LongInt; stdcall;
begin
 Result := PSC_GetErrorInformation_Orig(Unk1, Unk2, Unk3, Unk4);
 WriteLn('PSC_GetErrorInformation(', IntToHex(LongWord(Unk1), 8), ', ', IntToHex(LongWord(Unk2), 8), ', ', Unk3, ', ', IntToHex(LongWord(Unk4), 8), ');');
end;

function PSC_FinishInitializationSuccess_Our: LongInt; stdcall;
begin
 Result := PSC_FinishInitializationSuccess_Orig;
 WriteLn('PSC_FinishInitializationSuccess_Our();');
end;

function PSC_FinishInitializationFailure_Our: LongInt; stdcall;
begin
 Result := PSC_FinishInitializationFailure_Orig;
 WriteLn('PSC_FinishInitializationFailure();');

end;

function PSC_EnterGlobalCriticalSection_Our: LongInt; stdcall;
begin
 Result := PSC_EnterGlobalCriticalSection_Orig;
 WriteLn('PSC_EnterGlobalCriticalSection();');
end;

function PSA_Uninitialize_Our: LongInt; stdcall;
begin
 Result := PSA_Uninitialize_Our;
 WriteLn('PSA_Uninitialize_Our();');
end;

procedure PrintStartCallInfo(Value: LongWord);
begin
 WriteLn(IntToHex(Value - LongWord(SakijAPI.BaseStart), 8));
end;

procedure PrintString(S: PChar);
begin
 Write(S);
end;

procedure PSA_DummyFunction_Our; stdcall;
asm
 mov eax, offset @Str
 call PrintString

 mov eax, [esp]
 call PrintStartCallInfo
 ret

@Str:
 db 'PSA_DummyFunction(); ret = ',0
end;

procedure HookMessage4;
asm
 pushad
  mov eax, offset @Str
  call RaiseInfo
 popad

 jmp sub_10008472
 ret

@Str:
 db 'HookMessage4(Crash right now)',0
end;

procedure Check1;
asm
 mov eax, offset @Str
 call RaiseInfo
 ret

@Str:
 db '1',0
end;

procedure HookMessage5;
asm
 //mov eax, [eax]
 //mov ecx, [edx]
 //mov [eax], ecx

 jmp GoTo10E2D0

@Str:
 db 'HookMessage5: ',0
end;

procedure sub_7A75B0_Our;
asm
 mov eax, 0
end;

procedure WriteString(Str: PChar);
begin
 WriteLn(Str);
end;

// function sub_75A7D0_Our(A1: PChar): LongWord; cdecl;
procedure sub_75A7D0_Our;
asm
 pushad
 call WriteString
 popad

 call sub_75A7D0
end;

procedure PrintLongWord(L: LongWord);
begin
 WriteLn(L);
end;

procedure sub_6D8D00_Our;
asm
 pushad
  mov edi, ecx
  lea eax, [edi+0B0h]
  call PrintLongWord

  lea eax, [edi+0B0h]
  mov eax, [eax]
  call PrintLongWord
 popad

 jmp sub_6D8D00
end;

procedure sub_AD0A90;
begin
 MessageBox(HWND_DESKTOP, 'sub_AD0A90 called', '', MB_ICONINFORMATION or MB_SYSTEMMODAL);
 ExitProcess(0);
end;

end.
