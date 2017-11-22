unit MsgAPI;

interface

uses
 Windows, CvarDef, SysUtils;

const
 ERRORTYPE_SEARCH: LongWord = $00001000;
 ERRORTYPE_PATCH:  LongWord = $00002000;

procedure RaiseDebugAlert(Extra: String = '');

procedure RaiseError(const Msg: String); overload;
procedure RaiseError(Msg: array of const); overload;
procedure RaiseAlert(const Msg: String);
procedure RaiseInfo(Msg: PChar);

procedure ShowPointer(P: Pointer; Base: TLibrary); overload;
procedure ShowPointer(P: Pointer); overload;
procedure ShowPointer(P: LongWord); overload;

procedure ShowMemory(const Addr: Pointer; Length: LongInt = 8); overload;
procedure ShowMemory(const Addr: Cardinal; Length: LongInt = 8); overload;

procedure ShowRegistersStatus;
procedure RaiseErrorCode(Code: LongInt);

implementation

uses
 Common;

var
 AlertDebugValue: LongInt = 0;

procedure RaiseDebugAlert(Extra: String = '');
begin
 Inc(AlertDebugValue);
 RaiseAlert(IntToStr(AlertDebugValue) + sLineBreak + Extra);
end;

procedure RaiseError(const Msg: String);
begin
 MessageBox(HWND_DESKTOP, PChar(Msg), 'Fatal Error', MB_ICONERROR or MB_SYSTEMMODAL);
 Halt;
end;

procedure RaiseError(Msg: array of const);
begin
 MessageBox(HWND_DESKTOP, PChar(StringFromVarRec(Msg)), 'Fatal Error', MB_ICONERROR or MB_SYSTEMMODAL);
 Halt;
end;

procedure RaiseAlert(const Msg: String);
begin
 MessageBox(HWND_DESKTOP, PChar(Msg), 'Alert', MB_ICONWARNING or MB_SYSTEMMODAL);
end;

procedure RaiseInfo(Msg: PChar);
begin
 MessageBox(HWND_DESKTOP, Msg, 'Information', MB_ICONINFORMATION or MB_SYSTEMMODAL);
end;

procedure ShowPointer(P: Pointer; Base: TLibrary);
begin
 RaiseInfo(PChar(IntToHex(LongInt(P) - Base.BaseStart, 8)));
end;

procedure ShowPointer(P: Pointer);
begin
 ShowPointer(P, PWGame);
end;

procedure ShowPointer(P: LongWord);
begin
 ShowPointer(Pointer(P), PWGame);
end;

procedure ShowMemory(const Addr: Pointer; Length: LongInt = 8);
var
 S: String;
 L: LongInt;
begin
 S := '';
 for L := 0 to Length - 1 do
  S := S + IntToHex(PByte(LongInt(Addr) + L)^, 2) + ' ';

 RaiseAlert(S);
end;

procedure ShowMemory(const Addr: Cardinal; Length: LongInt = 8);
begin
 ShowMemory(Pointer(Addr), Length);
end;

procedure ShowRegistersStatus;
 procedure PrintRegs_Internal(EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP: LongWord); stdcall;
 var
  S: String;
 begin
  S := 'Registers dump:' + sLineBreak + sLineBreak;
  S := S + ' EAX: ' + IntToHex(EAX, 8) + '; ';
  S := S + ' EBX: ' + IntToHex(EBX, 8) + '; ';
  S := S + ' ECX: ' + IntToHex(ECX, 8) + '; ' + sLineBreak;
  S := S + ' EDX: ' + IntToHex(EDX, 8) + '; ';
  S := S + ' ESI: ' + IntToHex(ESI, 8) + '; ';
  S := S + ' EDI: ' + IntToHex(EDI, 8) + '; ' + sLineBreak;
  S := S + ' EBP: ' + IntToHex(EBP, 8) + '; ';
  S := S + ' ESP: ' + IntToHex(ESP, 8);
  MessageBox(HWND_DESKTOP, PChar(S), 'AsmStatus: Registers', MB_ICONINFORMATION or MB_SYSTEMMODAL);
 end;
asm
 push esp
 add [esp], 4 // - call return addr

 push ebp
 push edi
 push esi
 push edx
 push ecx
 push ebx
 push eax
 call PrintRegs_Internal
end;

procedure RaiseErrorCode(Code: LongInt);
begin
 RaiseError(PChar('An error has occured.'#10'Code: ' + IntToStr(Code)));
end;

end.
