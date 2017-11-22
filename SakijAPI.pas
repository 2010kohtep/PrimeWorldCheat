unit SakijAPI;

interface

type
 TPSM_0 = procedure; stdcall;
 TPSC_Uninitialize = function: LongInt; stdcall;
 TPSC_StartInitialization = function(Unk: LongWord): LongInt; stdcall;
 TPSC_PerformInitializationAtValidLicense = function: LongInt; stdcall;
 TPSC_LoadString = function(Unk1: Pointer; Unk2: LongInt; Unk3: Pointer): LongWord; stdcall;
 TPSC_LeaveGlobalCriticalSection = function: LongInt; stdcall;
 TPSC_GetErrorInformation = function(Unk1: Pointer; Unk2: PLongInt; Unk3: LongInt; Unk4: PLongInt): LongInt; stdcall;
 TPSC_FinishInitializationSuccess = function: LongInt; stdcall;
 TPSC_FinishInitializationFailure = function: LongInt; stdcall;
 TPSC_EnterGlobalCriticalSection = function: LongInt; stdcall;
 TPSA_Uninitialize = function: LongInt; stdcall;
 TPSA_DummyFunction = procedure; stdcall;

implementation

end.
