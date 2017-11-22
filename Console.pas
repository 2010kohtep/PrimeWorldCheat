unit Console;

interface

uses
 SysUtils, Windows;

procedure StringFromVarRec(const Data: array of const; var S: String); overload;
function StringFromVarRec(const Data: array of const): String; overload;

procedure InitConsoleModule;
procedure SetBackgroundColor;
procedure DeleteLastLine;
procedure ClearConsole;
function GetConsolePositionCenter: TCoord;
function GetLinePositionCenter: TCoord;
function GetLinePositionBottom: TCoord;
procedure PutConsoleCursor(C: TCoord); overload;
procedure PutConsoleCursor(X, Y: LongWord); overload;
procedure SetConsoleTextColor(Color: LongWord);

const
 COLOR_BLACK          = 0;
 COLOR_GREY           = FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED;
 COLOR_WRITE          = FOREGROUND_INTENSITY or COLOR_GREY;
 COLOR_BLUE_INTENS    = FOREGROUND_INTENSITY or FOREGROUND_BLUE;
 COLOR_GREEN_INTENS   = FOREGROUND_INTENSITY or FOREGROUND_GREEN;
 COLOR_RED_INTENT     = FOREGROUND_INTENSITY or FOREGROUND_RED;
 COLOR_CYAN           = FOREGROUND_BLUE or FOREGROUND_GREEN;
 COLOR_CYAN_INTENS    = FOREGROUND_INTENSITY or COLOR_CYAN;
 COLOR_MAGENTA        = FOREGROUND_RED or FOREGROUND_BLUE;
 COLOR_MAGENTA_INTENS = FOREGROUND_INTENSITY or COLOR_MAGENTA;
 COLOR_YELLOW         = FOREGROUND_RED or FOREGROUND_GREEN;
 COLOR_YELLOW_INTENS  = FOREGROUND_INTENSITY or COLOR_YELLOW;

const
 PRINT_DEFAULT_INTERVAL = 15;

var
 hConsole: THandle = 0;

procedure PrintLn(Value: array of const; LineBreak: Boolean = True; Interval: LongWord = PRINT_DEFAULT_INTERVAL); overload;
procedure PrintLn(const Value: String; LineBreak: Boolean = True; Interval: LongWord = PRINT_DEFAULT_INTERVAL); overload;
procedure Print(const Value: String; Interval: LongWord = PRINT_DEFAULT_INTERVAL); overload;
procedure PrintInLineCenter(Value: array of const; Interval: LongWord = PRINT_DEFAULT_INTERVAL);
procedure PrintInConsoleCenter(Value: array of const);

implementation

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
 sSuperTrashLine = sTrashLine + sTrashLine + sTrashLine + sTrashLine + sTrashLine;

procedure StringFromVarRec(const Data: array of const; var S: String);
const
 LookupTable: array[Boolean] of String = ('False', 'True');
var
 I: Longint;
begin
S := '';
for I := Low(Data) to High(Data) do
 with Data[I] do
  case VType of
   vtInteger: S := S + IntToStr(VInteger);
   vtBoolean: S := S + LookupTable[VBoolean];
   vtChar: S := S + VChar;
   vtExtended: S := S + FloatToStr(VExtended^);
   vtString: S := S + VString^;
   vtPointer: S := S + IntToHex(Cardinal(VPointer), 8);
   vtPChar: S := S + VPChar;
   vtObject: S := S + VObject.ClassName;
   vtClass: S := S + VClass.ClassName;
   vtWideChar: S := S + AnsiChar(VWideChar);
   vtPWideChar: S := S + PAnsiChar(VPWideChar);
   vtAnsiString: S := S + AnsiString(VAnsiString);
   vtCurrency: S := S + CurrToStr(VCurrency^);
   vtWideString: S := S + AnsiString(WideString(VWideString));
   vtInt64: S := S + IntToStr(VInt64^);
  else
   S := S + ' <unknown type> ';
  end;
end;

procedure InitConsoleModule;
begin
 hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
end;

function StringFromVarRec(const Data: array of const): String;
begin
Cardinal(Result) := 0;
StringFromVarRec(Data, Result);
end;

procedure SetBackgroundColor;
var
 L: LongInt;
 OldConsoleInfo: TConsoleScreenBufferInfo;
 Coord: TCoord;
begin
 GetConsoleScreenBufferInfo(hConsole, OldConsoleInfo);

 Coord.X := 0;
 Coord.Y := 0;
 SetConsoleCursorPosition(hConsole, Coord);
 SetConsoleTextAttribute(hConsole, BACKGROUND_GREEN);
 for L := 0 to 99 do
  WriteLn(sSuperTrashLine);

 SetConsoleCursorPosition(hConsole, Coord);
 SetConsoleTextAttribute(hConsole, OldConsoleInfo.wAttributes);
end;

procedure DeleteLastLine;
var
 SBInfo: _CONSOLE_SCREEN_BUFFER_INFO;
begin
 GetConsoleScreenBufferInfo(hConsole, SBInfo);
 SBInfo.dwCursorPosition.X := 0;
 Dec(SBInfo.dwCursorPosition.Y);
 SetConsoleCursorPosition(hConsole, SBInfo.dwCursorPosition);

 Write(sSuperTrashLine);
 SetConsoleCursorPosition(hConsole, SBInfo.dwCursorPosition);
end;

procedure ClearConsole;
var
 L: LongInt;
 Coord: TCoord;
begin
 Coord.X := 0;
 Coord.Y := 0;
 SetConsoleCursorPosition(hConsole, Coord);

 for L := 0 to 63 do
  WriteLn(sSuperTrashLine);

 SetConsoleCursorPosition(hConsole, Coord);
end;

function GetConsolePositionCenter: TCoord;
var
 SBInfo: _CONSOLE_SCREEN_BUFFER_INFO;
begin
 GetConsoleScreenBufferInfo(hConsole, SBInfo);
 Result.X := SBInfo.srWindow.Right div 2;
 Result.Y := SBInfo.srWindow.Bottom div 2;
end;

function GetLinePositionCenter: TCoord;
var
 SBInfo: _CONSOLE_SCREEN_BUFFER_INFO;
begin
 GetConsoleScreenBufferInfo(hConsole, SBInfo);
 Result.X := SBInfo.srWindow.Right div 2;
 Result.Y := SBInfo.dwCursorPosition.Y;
end;

function GetLinePositionBottom: TCoord;
var
 SBInfo: _CONSOLE_SCREEN_BUFFER_INFO;
begin
 GetConsoleScreenBufferInfo(hConsole, SBInfo);
 Result.X := SBInfo.dwCursorPosition.X;
 Result.Y := SBInfo.srWindow.Bottom;
end;

procedure PutConsoleCursor(C: TCoord);
begin
 SetConsoleCursorPosition(hConsole, C);
end;

procedure PutConsoleCursor(X, Y: LongWord);
var
 C: Coord;
begin
 C.X := X;
 C.Y := Y;
 SetConsoleCursorPosition(hConsole, C);
end;

procedure PrintLn(Value: array of const; LineBreak: Boolean = True; Interval: LongWord = PRINT_DEFAULT_INTERVAL);
begin
 PrintLn(StringFromVarRec(Value), LineBreak, Interval);
end;

procedure PrintLn(const Value: String; LineBreak: Boolean = True; Interval: LongWord = PRINT_DEFAULT_INTERVAL);
var
 L: LongInt;
begin
 for L := 1 to Length(Value) do
  begin
   Write(Value[L]);
   Sleep(Interval);
  end;
 WriteLn;

 if LineBreak then
  WriteLn;
end;

procedure Print(const Value: String; Interval: LongWord = PRINT_DEFAULT_INTERVAL);
var
 L: LongInt;
begin
 for L := 1 to Length(Value) do
  begin
   Write(Value[L]);
   Sleep(Interval);
  end;
end;

procedure PrintInLineCenter(Value: array of const; Interval: LongWord = PRINT_DEFAULT_INTERVAL);
var
 C: TCoord;
 S: String;
 SBInfo: _CONSOLE_SCREEN_BUFFER_INFO;
 I, L: LongInt;
 R: Real;

 CurS: String;
begin
 GetConsoleScreenBufferInfo(hConsole, SBInfo);
 C := SBInfo.dwCursorPosition;
 S := StringFromVarRec(Value);
 L := Length(S);

 CurS := '';
 for I := 1 to L do
  begin
   CurS := CurS + S[I];
   C := GetLinePositionCenter;
   R := I / 2;
   C.X := C.X - Round(R);
   PutConsoleCursor(C);
   Write(CurS);
   Sleep(Interval);
  end;
end;

procedure PrintInConsoleCenter(Value: array of const);
var
 C: TCoord;
 S: String;
 L: LongInt;
begin
 SetConsoleCursorPosition(hConsole, GetConsolePositionCenter);
 PrintInLineCenter(Value);
end;

procedure SetConsoleTextColor(Color: LongWord);
begin
 SetConsoleTextAttribute(hConsole, Color);
end;

end.
