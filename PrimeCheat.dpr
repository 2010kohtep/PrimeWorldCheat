library PrimeCheat;

uses
  SysUtils,
  Windows,
  MemSearch,
  Detours,
  CvarDef,
  MsgAPI,
  Common,
  Funcs,
  Console,
  FileLog,
  Hacks,
  TlHelp32;

{$R *.res}

procedure KM_AdvancedCheat;
const
 CheatKey = VK_F12;
var
 B: Boolean;
label
 A1;
begin
 B := False;
 B2 := False;

 while True do
  begin
   if B2 then
    goto A1;

   if GetKeyState(CheatKey) and $8000 <> 0 then
    begin
     //Toggle_CRCEndChecking(False);
     Toggle_EntityRendering(True);
     AdvancedRenderIsActive := True;
     // SetConsoleTitle(PChar(Cheat + ' - Active'));

     B := False;
     B2 := True;

     while GetKeyState(CheatKey) and $8000 <> 0 do ;
     Continue;
    end;

   if B then Continue;

A1:
   if GetKeyState(CheatKey) and $8000 <> 0 then
    begin
     Toggle_EntityRendering(False);
     //Toggle_CRCEndChecking(False);
     //Toggle_PacketsFunc(False);
     AdvancedRenderIsActive := False;
     // SetConsoleTitle(PChar(Cheat + ' - Inactive'));

     B := True;
     B2 := False;

     while GetKeyState(CheatKey) and $8000 <> 0 do ;
    end;

    Sleep(50);
  end;
end;

procedure KM_CasualCheat;
const
 CheatKey = VK_F1;
var
 B: Boolean;
label
 A1;
begin
 B := False;
 B3 := False;

 while True do
  begin
   if B3 then
    goto A1;

   if GetKeyState(CheatKey) and $8000 <> 0 then
    begin
     //Toggle_CRCEndChecking(False);
     Toggle_MapIcoRendering(True);
     CasualRenderIsActive := True;

     B := False;
     B3 := True;

     while GetKeyState(CheatKey) and $8000 <> 0 do ;
     Continue;
    end;

   if B then Continue;

A1:
   if GetKeyState(CheatKey) and $8000 <> 0 then
    begin
     Toggle_MapIcoRendering(False);
     //Toggle_CRCEndChecking(False);
     CasualRenderIsActive := False;

     B := True;
     B3 := False;

     while GetKeyState(CheatKey) and $8000 <> 0 do ;
    end;

    Sleep(50);
  end;
end;

function GetThreadsList(PID: Cardinal): Boolean;
var
 SnapProcHandle: THandle;
 NextProc: Boolean;
 TThreadEntry: TThreadEntry32;
begin
 SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
 Result := (SnapProcHandle <> INVALID_HANDLE_VALUE);
 if Result then
  try
   TThreadEntry.dwSize := SizeOf(TThreadEntry);
   NextProc := Thread32First(SnapProcHandle, TThreadEntry);
   while NextProc do
   begin
    if TThreadEntry.th32OwnerProcessID = PID then
    begin
     WriteLn('Thread ID: ', IntToHex(TThreadEntry.th32ThreadID, 8));
     WriteLn('Base priority: ', IntToStr(TThreadEntry.tpBasePri));
     WriteLn('Delta priority: ', IntToStr(TThreadEntry.tpBasePri));
     WriteLn('Process name: ', GetProcessNameByPID(TThreadEntry.th32OwnerProcessID));
     WriteLn;
    end;

    NextProc := Thread32Next(SnapProcHandle, TThreadEntry);
   end;
  finally
    CloseHandle(SnapProcHandle);
  end;
end;

{procedure KeyMonitor;
begin
 MaphackIsActive := False;
 WriteLn('Keyboard monitor is enabled.');

 while True do
  begin
   if GetKeyState(VK_F1) and $8000 <> 0 then
    if not MaphackIsActive then
     begin
      MaphackIsActive := True;
      WriteLn('ICanSeeEverything: Activated.');
      ICanSeeEverything;
     end
    else
   else
    if MaphackIsActive then
     begin
      MaphackIsActive := False;
      WriteLn('ICanSeeEverything: Deactivated.');
      ICanSeeEverything;
     end;

   Sleep(5);
  end;
end;}

function HexToInt(HexStr: String): Int64;
var
 RetVar: Int64;
 I: Byte;
begin
 if HexStr[Length(HexStr)] = 'H' then
  Delete(HexStr, Length(HexStr), 1);

 RetVar := 0;

 HexStr := UpperCase(HexStr);
 for I := 1 to Length(HexStr) do
  begin
   RetVar := RetVar shl 4;
   if HexStr[I] in ['0'..'9'] then
    RetVar := RetVar + (Byte(HexStr[I]) - 48)
   else
   if HexStr[I] in ['A'..'F'] then
    RetVar := RetVar + (Byte(HexStr[I]) - 55)
   else
   begin
    RetVar := 0;
    Break;
   end;
  end;

 Result := RetVar;
end;

function DeleteFirstSpaceSeparatedString(var S: String): Boolean;
var
 L: LongInt;
begin
 L := Pos(' ', S);
 Result := L <> 0;

 if L <> 0 then
  Delete(S, 1, L);
end;

{procedure COM_TokenizeString(S: String);
var
 IsQuote: Boolean;
 I, L: LongInt;
begin
 SetLength(LastArgs, 0);
 IsQuote := False;
 L := 1;

 S := Trim(S);
 if S = '' then
  Exit;

 while True do
  begin
   //if S[L] = '"' then
    //IsQuote := not IsQuote;


   if (not IsQuote) and (S[L] = ' ') then
    begin
     I := Length(LastArgs);
     SetLength(LastArgs, I + 1);
     LastArgs[I] := Copy(S, 1, L);
     Delete(S, 1, L);
     L := 1;
     Continue;
    end;

   Inc(L);

   if L > Length(S) then
    begin
     I := Length(LastArgs);
     SetLength(LastArgs, I + 1);
     LastArgs[I] := Copy(S, 1, L);
     Break;
    end;
  end;
end;

function Cmd_Argv(ID: LongInt): String;
begin
 Result := LastArgs[ID];
end; }

procedure StartConsoleDialogue;
var
 I, L: LongInt;
 S: String;
 FirstArg: String;

 ID: LongInt;
label
 Back;
begin
 while True do
  begin
Back:
   ReadLn(S);

   if Length(S) = 0 then
    goto Back;

   L := Pos(' ', S);

   if L <> 0 then
    FirstArg := Copy(S, 1, L - 1)
   else
    FirstArg := S;

   {if FirstArg = 'ptrrpl' then // pointer replace
    begin
     if DeleteFirstSpaceSeparatedString(S) then
      PtrReplace := HexToInt(S)
     else
      WriteLn('PtrReplace = ', IntToHex(PtrReplace, 8));
    end;}

   if FirstArg = 'ptrdump' then
    begin
     if not DeleteFirstSpaceSeparatedString(S) then
      begin
       WriteLn('Syntax: ptrdump <ID>');
       goto Back;
      end
     else
      begin
       ID := StrToInt(S);

     ClearConsole;
     for L := 0 to Length(PtrsInfo) - 1 do
      if PtrsInfo[L].ID = ID then
       begin
        WriteLn('Registers:');
        WriteLn(' EAX: ', IntToHex(PtrsInfo[L].Payload.EAX, 8));
        WriteLn(' EBX: ', IntToHex(PtrsInfo[L].Payload.EBX, 8));
        WriteLn(' ECX: ', IntToHex(PtrsInfo[L].Payload.ECX, 8));
        WriteLn(' EDX: ', IntToHex(PtrsInfo[L].Payload.EDX, 8));
        WriteLn(' ESI: ', IntToHex(PtrsInfo[L].Payload.ESI, 8));
        WriteLn(' EDI: ', IntToHex(PtrsInfo[L].Payload.EDI, 8));
        WriteLn(' ESP: ', IntToHex(PtrsInfo[L].Payload.ESP, 8));
        WriteLn(' EBP: ', IntToHex(PtrsInfo[L].Payload.EBP, 8));
        WriteLn(' EFLAGS: ', IntToHex(PtrsInfo[L].Payload.EFLAGS, 8));

        WriteLn;
        WriteLn('Stack dump:');
        for I := 0 to STACK_DUMPSIZE - 1 do
         WriteLn(' +', I * 4, #9, IntToHex(PtrsInfo[L].Payload.Stack[I], 8));

        Break;
       end;

      Continue;
     end;
    end;

   if FirstArg = 'ptrsinfo' then
    begin
     ClearConsole;

     WriteLn('InfoID'#9, 'jmp'#9#9, 'CallCount'#9, 'ThreadID');
     for L := 0 to Length(PtrsInfo) - 1 do
      WriteLn(PtrsInfo[L].ID, #9'$', IntToHex(LongWord(PtrsInfo[L].Addr), 8), ' '#9, PtrsInfo[L].Count, #9, IntToHex(PtrsInfo[L].ThreadID, 8));
     goto Back;
    end;

  if FirstArg = 'clearinfo' then
   begin
    SetLength(PtrsInfo, 0);
    goto Back;
   end;
   
  end;
end;

procedure Main;
begin
 AllocConsole;
 InitConsoleModule;

 SetConsoleTextColor(FOREGROUND_GREEN);
 SetConsoleTitle(Cheat + ' - Initializing...');
 WriteLn('PrimeCheat 0.5.2 started.');
 SetConsoleTextColor(COLOR_YELLOW);
 WriteLn(' -- 2010kohtep --');
 SetConsoleTextColor(COLOR_GREY);
 WriteLn;

 if not FindMainGameModule then
  RaiseError('Failed to find "PW_Game.exe" image base.');

 GetMainGameModuleInfo;

 Find_MobsRendererCode;
 Find_StuffRendererCode;
 Find_FogRenderCode;

 //Find_sendto;
 //Find_recvfrom;
 
 // doesn't need, I guess
 DisableSakijapiThread;

 Load_SakijAPI;
 Find_SakijapiHandler;
 Hook_SakijapiHandler;

 //Find_CRCResultCheckCode;
 //Hook_CRCResultCheckCode;

 Find_CxxThrowException;
 Hook_CxxThrowException;

 WriteLn('Press "F12" for advanced maphack.');
 WriteLn('Press "F1" for casual maphack.');

 BeginThread(nil, 0, @StartConsoleDialogue, nil, 0, PLongWord(nil)^);
 BeginThread(nil, 0, @KM_AdvancedCheat, nil, 0, PLongWord(nil)^);
 BeginThread(nil, 0, @KM_CasualCheat, nil, 0, PLongWord(nil)^);

 //SetConsoleTitle(Cheat + ' - Inactive');
 SetConsoleTitle(Cheat);

 EndThread(0);
end;

begin
 BeginThread(nil, 0, @Main, nil, 0, PLongWord(nil)^);
end.
