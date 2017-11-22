unit CvarDef;

interface

uses
 Windows, WinSock, SakijAPI;

type
 NTSTATUS = LongInt;
 THREADINFOCLASS = LongWord;

function NtQueryInformationThread(
    ThreadHandle: THandle;  ThreadInformationClass: THREADINFOCLASS;
    ThreadInformation: Pointer; ThreadInformationLength: ULONG;  ReturnLength: PULONG): NTSTATUS; stdcall; external 'ntdll.dll';

function OpenThread(dwDesiredAccess: DWord;
                    bInheritHandle: Bool;
                    dwThreadId: DWord): DWord; stdcall; external 'kernel32.dll';

type
 TLibrary = record
  BaseStart: LongInt;
  BaseEnd: LongInt;
  BaseSize: LongInt;
 end;

const
 CheatName = 'PrimeCheat';
 CheatVersion = '0.5 Fix 1';
 Cheat = CheatName + ' ' + CheatVersion;

 MAX_ATTEMPTS = 256;

var
 PWDOSHeader: IMAGE_DOS_HEADER;
 PWNTHeader: IMAGE_NT_HEADERS;

 SakijAPI: TLibrary;

 PWGame: TLibrary;
 PWID: THandle;

 PushAddrPattern: array[0..5] of Byte;

 sub_820450: procedure(Unk: Pointer); stdcall;
 LoadSceneMapObjects: procedure(Unk1, Unk2, Unk3, Unk4: Pointer); stdcall;
 PieceOfShit: procedure(Unk1: Pointer); stdcall;

 sub_815FA0_Gate: procedure; stdcall;
 sub_816020_Gate: procedure; stdcall;
 sub_8211A0_Gate: procedure; stdcall;
 sub_4F6660_Gate: procedure; cdecl;

 recv_Orig: function(S: LongWord; var Buf; Len, Flags: LongInt): LongInt; stdcall;
 recv_Gate: function(S: LongWord; var Buf; Len, Flags: LongInt): LongInt; stdcall;

 //recvfrom_Orig: function(S: TSocket; var Buf; Len, Flags: LongInt; var From: TSockAddr; var FromLen: LongInt): LongInt; stdcall;
 recvfrom_Gate: function(S: TSocket; var Buf; Len, Flags: LongInt; var From: TSockAddr; var FromLen: LongInt): LongInt; stdcall;

 DllMain_Orig: function(hinstDLL: HINST; fdwReason: LongWord; lpvReserved: Pointer): Boolean; stdcall;
 DllMain_Gate: function(hinstDLL: HINST; fdwReason: LongWord; lpvReserved: Pointer): Boolean; stdcall;

 PSM_0_Orig: TPSM_0;
 PSC_Uninitialize_Orig: TPSC_Uninitialize;
 PSC_StartInitialization_Orig: TPSC_StartInitialization;
 PSC_PerformInitializationAtValidLicense_Orig: TPSC_PerformInitializationAtValidLicense;
 PSC_LoadString_Orig: TPSC_LoadString;
 PSC_LeaveGlobalCriticalSection_Orig: TPSC_LeaveGlobalCriticalSection;
 PSC_GetErrorInformation_Orig: TPSC_GetErrorInformation;
 PSC_FinishInitializationSuccess_Orig: TPSC_FinishInitializationSuccess;
 PSC_FinishInitializationFailure_Orig: TPSC_FinishInitializationFailure;
 PSC_EnterGlobalCriticalSection_Orig: TPSC_EnterGlobalCriticalSection;
 PSA_Uninitialize_Orig: TPSA_Uninitialize;
 PSA_DummyFunction_Orig: TPSA_DummyFunction;

 PSM_0_Gate: TPSM_0;
 PSC_Uninitialize_Gate: TPSC_Uninitialize;
 PSC_StartInitialization_Gate: TPSC_StartInitialization;
 PSC_PerformInitializationAtValidLicense_Gate: TPSC_PerformInitializationAtValidLicense;
 PSC_LoadString_Gate: TPSC_LoadString;
 PSC_LeaveGlobalCriticalSection_Gate: TPSC_LeaveGlobalCriticalSection;
 PSC_GetErrorInformation_Gate: TPSC_GetErrorInformation;
 PSC_FinishInitializationSuccess_Gate: TPSC_FinishInitializationSuccess;
 PSC_FinishInitializationFailure_Gate: TPSC_FinishInitializationFailure;
 PSC_EnterGlobalCriticalSection_Gate: TPSC_EnterGlobalCriticalSection;
 PSA_Uninitialize_Gate: TPSA_Uninitialize;
 PSA_DummyFunction_Gate: TPSA_DummyFunction;

 sub_10008472: procedure; stdcall;
 sub_1010E2B8: procedure; stdcall;

 SavedECX: LongWord = 0;

 GoTo10E2D0: LongWord = 0;

 LogFileHandle: TextFile;
 EnableFileLog: Boolean = False;
 EnablePacketPatch: Boolean = False;

 sub_7A75B0: Pointer = nil;
 sub_75A7D0: function(A1: PChar): LongWord; cdecl;
 sub_6D8D00: procedure;

 MaphackIsActive: Boolean = False;

 SakijAPIHandlerOrig: Pointer = nil;
 SakijApiCRCCheckOrig: Pointer = nil;

const
 STACK_DUMPSIZE = 32;

const
 THREAD_QUERY_INFORMATION   = $0040;
 STATUS_SUCCESS             = $00000000;
 ThreadQuerySetWin32StartAddress = 9;

type
 TPayload = record
  EAX: LongWord;
  ECX: LongWord;
  EDX: LongWord;
  EBX: LongWord;
  ESP: LongWord;
  EBP: LongWord;
  ESI: LongWord;
  EDI: LongWord;
  EFLAGS: LongWord;

  Stack: array[0..STACK_DUMPSIZE - 1] of LongWord;
 end;

type
 PSakijPtr = ^TSakijPtr;
 TSakijPtr = record
  ID: LongInt;

  Count: LongWord;
  Addr: Pointer;

  ThreadID: LongWord;

  Payload: TPayload;
 end;

var
 PtrsInfo: array of TSakijPtr;
 PtrReplace: LongWord = 0;

 AdvancedRenderIsActive: Boolean = False;
 CasualRenderIsActive: Boolean = False;
 FogCheatIsActive: Boolean = False;

 B2: Boolean = False;
 B3: Boolean = False;

 SeriousRenderCode: Pointer = nil;
 MobsRendererCode: Pointer = nil;
 StuffRendererCode: Pointer = nil;
 FogRendererCode: Pointer = nil;

 sendto_Orig: Pointer = nil;
 recvfrom_Orig: Pointer = nil;
 CxxThrowException_Orig: Pointer = nil;

 SakijApiCRCEndCheckOrig: Pointer = nil;
 CRCEndJmpAddr: Pointer = nil;

 CRCResultCheckCode: Pointer = nil;

implementation

end.
