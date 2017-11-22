unit Hacks;

interface

uses
 CvarDef, Windows;

procedure ICanSeeEverything;

implementation

procedure ICanSeeEverything;
var
 B: Byte;
 P: Pointer;
 Protect: LongWord;
begin
 P := MobsRendererCode;

 VirtualProtect(P, 1, PAGE_EXECUTE_READWRITE, Protect);
 B := PByte(P)^;
 if B = 0 then
  PByte(P)^ := 1
 else
  PByte(P)^ := 0;
 VirtualProtect(P, 1, Protect, Protect);
end;

end.
