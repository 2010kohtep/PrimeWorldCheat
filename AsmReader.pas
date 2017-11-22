unit AsmReader;

interface

uses
 Windows, SysUtils, CvarDef;

function GetValidCodeLength(Addr: Pointer; MinCodeLength: LongInt = 5): LongInt;

type
 TOPCode = record
  Value: array[1..4] of Byte;
  Size: Byte;
  Name: PChar;
end;

const
 Instructions: array[1..87] of TOPCode = (
 (Value: ($50, $0, $0, $0); Size: 1; Name: 'push eax'),
 (Value: ($51, $0, $0, $0); Size: 1; Name: 'push ecx'),
 (Value: ($52, $0, $0, $0); Size: 1; Name: 'push edx'),
 (Value: ($53, $0, $0, $0); Size: 1; Name: 'push ebx'),
 (Value: ($55, $0, $0, $0); Size: 1; Name: 'push ebp'),
 (Value: ($56, $0, $0, $0); Size: 1; Name: 'push esi'),
 (Value: ($57, $0, $0, $0); Size: 1; Name: 'push edi'),
 (Value: ($6A, $0, $0, $0); Size: 2; Name: 'push NUMBER'),
 (Value: ($68, $0, $0, $0); Size: 5; Name: 'push offset VARIABLE'),

 (Value: ($5B, $0, $0, $0); Size: 1; Name:  'pop ebx'),
 (Value: ($5D, $0, $0, $0); Size: 1; Name:  'pop ebp'),
 (Value: ($5E, $0, $0, $0); Size: 1; Name:  'pop esi'),
 (Value: ($5F, $0, $0, $0); Size: 1; Name:  'pop edi'),

 (Value: ($E8, $0, $0, $0); Size: 5; Name:  'call xxx'),
 (Value: ($FF, $15, $0, $0); Size: 6; Name: 'call off_xxx'),
 (Value: ($E9, $0, $0, $0); Size: 5; Name:  'jmp xxx'),

 (Value: ($8B, $C1, $0, $0); Size: 2; Name:  'mov eax, ecx'),
 (Value: ($B8, $0, $0, $0); Size: 5; Name:   'mov eax, NUMBER'), // 8B 00 = mov eax, [eax]
 (Value: ($A1, $0, $0, $0); Size: 5; Name:   'mov eax, VARIABLE'),
 (Value: ($8B, $EC, $0, $0); Size: 2; Name:  'mov ebp, esp'),
 (Value: ($8B, $0D, $0, $0); Size: 6; Name:  'mov ecx, VARIABLE'),
 (Value: ($8B, $CC, $0, $0); Size: 2; Name:  'mov ecx, esp'),
 (Value: ($8B, $F2, $0, $0); Size: 2; Name:  'mov esi, edx'),
 (Value: ($8B, $49, $0, $0); Size: 3; Name:  'mov ecx, [ecx+OFFSET]'),
 (Value: ($8B, $45, $0, $0); Size: 3; Name:  'mov eax, [ebp+OFFSET]'),
 (Value: ($8B, $44, $24, $0); Size: 4; Name: 'mov eax, [esp+OFFSET]'),
 (Value: ($8B, $54, $24, $0); Size: 4; Name: 'mov edx, [esp+OFFSET]'),
 (Value: ($8B, $4C, $24, $0); Size: 4; Name: 'mov ecx, [esp+OFFSET]'),
 (Value: ($8B, $6C, $24, $0); Size: 4; Name: 'mov ebp, [esp+OFFSET]'),
 (Value: ($8B, $4D, $0, $0); Size: 3; Name:  'mov ecx, [ebp+OFFSET]'),
 (Value: ($8B, $75, $0, $0); Size: 3; Name:  'mov esi, [ebp+OFFSET]'),
 (Value: ($8B, $74, $24, $0); Size: 4; Name: 'mov esi, [esp+4+OFFSET]'),
 (Value: ($8B, $F1, $0, $0); Size: 2; Name:  'mov esi, ecx'),
 (Value: ($8B, $55, $0, $0); Size: 3; Name:  'mov edx, [ebp+OFFSET]'),
 (Value: ($C7, $05, $0, $0); Size: 10; Name: 'mov dword ptr VARIABLE+4, NUMBER'),
 (Value: ($89, $33, $0, $0); Size: 2; Name:  'mov [ebx], esi'),
 (Value: ($89, $1A, $0, $0); Size: 2; Name:  'mov [edx], ebx'),
 (Value: ($B9, $0, $0, $0); Size: 5; Name:   'mov ecx, NUMBER'),
 (Value: ($BE, $0, $0, $0); Size: 5; Name:   'mov esi, offset VARIABLE'),
 (Value: ($89, $13, $0, $0); Size: 2; Name:  'mov [ebx], ebx'),
 (Value: ($8A, $08, $0, $0); Size: 2; Name:  'mov cl, [eax]'),
 (Value: ($8B, $EE, $0, $0); Size: 2; Name:  'mov ebp, esi'),
 (Value: ($8B, $7C, $24, $0); Size: 4; Name: 'mov edi, [esp+OFFSET]'),
 (Value: ($8B, $06, $0, $0); Size: 2; Name:  'mov eax, [esi]'),
 (Value: ($8B, $FF, $0, $0); Size: 2; Name:  'mov edi, edi'),
 (Value: ($8B, $4C, $24, $0); Size: 4; Name: 'mov ecx, [esp+OFFSET]'),

 (Value: ($83, $E4, $0, $0); Size: 3; Name: 'and esp, NUMBER'),
 (Value: ($83, $C4, $0, $0); Size: 3; Name: 'add esp, NUMBER'),
 (Value: ($83, $EC, $0, $0); Size: 3; Name: 'sub esp, NUMBER'),
 (Value: ($81, $EC, $0, $0); Size: 6; Name: 'sub esp, NUMBER'),
 (Value: ($0B, $C5, $0, $0); Size: 2; Name: 'or eax, ebp'),
 (Value: ($83, $C8, $0, $0); Size: 3; Name: 'or eax, NUMBER'),
 (Value: ($33, $0, $0, $0); Size: 2; Name:  'xor xxx, xxx'),


 (Value: ($80, $38, $0, $0); Size: 3; Name:   'cmp byte ptr [eax], NUMBER'),
 (Value: ($80, $3E, $0, $0); Size: 3; Name:   'cmp byte ptr [esi], NUMBER'),
 (Value: ($3C, $0, $0, $0); Size: 2; Name:    'cmp al, NUMBER'),
 (Value: ($83, $FA, $0, $0); Size: 2; Name:   'cmp edx, NUMBER'),
 (Value: ($83, $F8, $0, $0); Size: 3; Name:   'cmp eax, NUMBER'),
 (Value: ($83, $3D, $C0, $0); Size: 7; Name:  'cmp VARIABLE, NUMBER'),
 (Value: ($3A, $D3, $0, $0); Size: 2; Name:   'cmp dl, bl'),
 (Value: ($3B, $CE, $0, $0); Size: 2; Name:   'cmp ecx, esi'),
 (Value: ($3D, $0, $0, $0); Size: 5; Name:    'cmp eax, NUMBER'),
 (Value: ($3B, $CD, $0, $0); Size: 3; Name:   'cmp ecx, ebp'),
 (Value: ($39, $68, $0, $0); Size: 3; Name:   'cmp [eax+OFFSET], ebp'),
 (Value: ($3B, $C6, $0, $0); Size: 2; Name:   'cmp eax, esi'),

 (Value: ($D3, $E5, $0, $0); Size: 2; Name: 'shl ebp, cl'),
 (Value: ($D3, $EF, $0, $0); Size: 2; Name: 'shr edi, cl'),

 (Value: ($8D, $44, $24, $0); Size: 4; Name: 'lea eax, [esp+OFFSET]'),
 (Value: ($8D, $54, $24, $0); Size: 4; Name: 'lea edx, [esp+OFFSET]'),
 (Value: ($8D, $4C, $24, $0); Size: 4; Name: 'lea ecx, [esp+OFFSET]'),
 (Value: ($8D, $45, $0, $0); Size: 3; Name:  'lea eax, [ebp+OFFSET]'),
 (Value: ($8D, $4D, $0, $0); Size: 3; Name:  'lea ecx, [ebp+OFFSET]'),
 (Value: ($8D, $55, $0, $0); Size: 3; Name:  'lea edx, [ebp+OFFSET]'),

 (Value: ($D9, $05, $0, $0); Size: 6; Name:  'fld VARIABLE'),
 (Value: ($D9, $41, $0, $0); Size: 3; Name:  'fld dword ptr [ecx+OFFSET]'),
 (Value: ($D9, $44, $24, $0); Size: 4; Name: 'fld [esp+OFFSET]'),
 (Value: ($D8, $48, $0, $0); Size: 3; Name:  'fmul dword ptr [eax+OFFSET]'),
 (Value: ($D8, $08, $0, $0); Size: 2; Name:  'fmul dword ptr [eax]'),
 (Value: ($DC, $0D, $0, $0); Size: 6; Name:  'fmul ds:VARIABLE'),
 (Value: ($D9, $19, $0, $0); Size: 2; Name:  'fstp dword ptr [ecx]'),
 (Value: ($D9, $59, $0, $0); Size: 3; Name:  'fstp dword ptr [ecx+OFFSET]'),
 (Value: ($D9, $5C, $24, $0); Size: 4; Name: 'fstp [esp+OFFSET+OFFSET]'),
 (Value: ($D8, $1D, $0, $0); Size: 6; Name:  'fcomp ds:VARIABLE'), 
 (Value: ($DF, $E0, $0, $0); Size: 2; Name:  'fnstsw ax'),

 (Value: ($C2, $0, $0, $0); Size: 3; Name:   'retn xxx'),
 (Value: ($C3, $0, $0, $0); Size: 1; Name:   'retn'),
 (Value: ($90, $0, $0, $0); Size: 1; Name:   'nop')
 );

implementation

procedure RaiseError(Msg: PChar); overload;
begin
 MessageBox(0, Msg, 'AsmReader - Fatal Error', MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
 Halt(1);
end;

procedure RaiseError(const Msg: String); overload;
begin
 RaiseError(PChar(Msg));
end;

function GetValidCodeLength(Addr: Pointer; MinCodeLength: LongInt = 5): LongInt;
var
 L: LongInt;
 I: LongInt;
 B: Byte;

 DebugStr: String;
begin
 Result := 0;
 L := Low(Instructions);
 B := PByte(Addr)^;

 while L < High(Instructions) + 1 do
  begin
   if B = Instructions[L].Value[1] then
    for I := 1 to 3 do
     begin
      if Instructions[L].Value[I + 1] <> $0 then
       begin
        if PByte(LongInt(Addr) + I)^ <> Instructions[L].Value[I + 1] then
         Break
       end
      else
       begin
        Inc(Result, Instructions[L].Size);
        if Result >= MinCodeLength then
         Exit
        else
         begin
          Inc(LongWord(Addr), Instructions[L].Size);
          B := PByte(Addr)^;
          L := -1;
         end;
       end;
     end;
    Inc(L);
  end;

 DebugStr := 'Unreadable code for AsmReader has been found!' + #10#10 + 'Dump:' + #10;
 for I := 0 to 7 do
  DebugStr := DebugStr + IntToHex(PByte(LongInt(Addr) + I)^, 2) + ' ';

 DebugStr := DebugStr + #10 + 'Address (ModRel): $' + IntToHex(LongWord(Addr), 8);
 DebugStr := DebugStr + #10 + 'Address (SelRel): $' + IntToHex(LongWord(Addr) - LongWord(PWGame.BaseStart), 8);
 RaiseError(DebugStr);
end;

end.

