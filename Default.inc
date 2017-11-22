{$DEFINE Debug}
{.$DEFINE Release}

{$DEFINE ASM}

{$Extension dll}

{$Align 4}
{$BoolEval OFF}
{$ExtendedSyntax ON}
{$ImportedData OFF}
{$IOChecks OFF}
{$LongStrings ON}
{$MethodInfo OFF}
{$MinEnumSize 1}
{$ObjExportAll OFF}
{$Optimization ON}
{$OverflowChecks OFF}
{$RangeChecks OFF}
{$RealCompatibility OFF}
{$SafeDivide OFF}
{$StackFrames OFF}
{$TypeInfo OFF}
{$TypedAddress OFF}
{$VarStringChecks ON}
{$WriteableConst OFF}

{$Hints ON}
{$Warnings ON}

{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

{$IFDEF MSWINDOWS}
 {$MinStackSize $4000}
 {$MaxStackSize $100000}
{$ENDIF}

{$IFDEF LINUX}
 {$MESSAGE FATAL 'This project must be compiled under MS Windows.'}
{$ENDIF}

{$IF CompilerVersion >= 17}
 {$IF CompilerVersion >= 19}
  {$DEFINE Unicode}                                
 {$ELSE}
  {$UNDEF Unicode}
 {$IFEND}
 {$DEFINE Inline}
{$ELSE}
 {$UNDEF Inline}
 {$UNDEF Unicode}
{$IFEND}

{$IF SizeOf(Char) <> SizeOf(Byte)}
 {$MESSAGE FATAL 'This project does not support Delphi 2009 or higher.'}
{$IFEND}

{$IFDEF Unicode}
 {$MESSAGE FATAL 'This project does not support Delphi 2009 or higher.'}
{$ENDIF}

{$IF SizeOf(Boolean) <> 1}
 {$MESSAGE FATAL 'Invalid "Boolean" type size.'}
{$ELSE}
 {$IF SizeOf(Byte) <> 1}
  {$MESSAGE FATAL 'Invalid "Byte" type size.'}
 {$ELSE}
  {$IF SizeOf(Char) <> 1}
   {$MESSAGE FATAL 'Invalid "Char" type size.'}
  {$ELSEIF}
   {$IF SizeOf(Word) <> 2}
    {$MESSAGE FATAL 'Invalid "Word" type size.'}
   {$ELSE}
    {$IF SizeOf(LongWord) <> 4}
     {$MESSAGE FATAL 'Invalid "LongWord" type size.'}
    {$ELSE}
     {$IF SizeOf(Pointer) <> 4}
      {$MESSAGE FATAL 'Invalid "Pointer" type size.'}
     {$IFEND}
    {$IFEND}
   {$IFEND}
  {$IFEND}
 {$IFEND}
{$IFEND}

{$IFDEF Debug}
 {$ImageBase $1000000}
 {$DebugInfo ON}
 {$DefinitionInfo ON}
 {$LocalSymbols ON}
{$ELSE}
 {$ImageBase $C00000}
 {$DebugInfo OFF}
 {$DefinitionInfo OFF}
 {$LocalSymbols OFF}
{$ENDIF}