{******************************************************************************}
{* Delphi Free Stuff Include File.  This file is used for all my components   *}
{* to create some standard defines.  This will help reduce headaches when new *}
{* versions of Delphi and C++Builder are released, among other things.        *}
{******************************************************************************}
{* Brad Stowers: bstowers@pobox.com                                           *}
{* Delphi Free Stuff: http://www.pobox.com/~bstowers/delphi/                  *}
{* December 27, 1997                                                          *}
{******************************************************************************}

{$DEFINE DELPHI_FREE_STUFF}

  {$DEFINE DFS_DELPHI_3}
  {$DEFINE DFS_DELPHI}
  {$DEFINE DFS_WIN32}
  {$DEFINE DFS_USEDEFSHLOBJ} { Only Delphi 3 and C++B have no errors in SHLOBJ }
  {$DEFINE DFS_NO_COM_CLEANUP}
{$IFDEF VER100}
  {$DEFINE DFS_DELPHI_3}
  {$DEFINE DFS_DELPHI}
  {$DEFINE DFS_WIN32}
  {$DEFINE DFS_USEDEFSHLOBJ} { Only Delphi 3 and C++B have no errors in SHLOBJ }
  {$DEFINE DFS_NO_COM_CLEANUP}
{$ELSE}{$IFDEF VER93}
  {$DEFINE DFS_CPPB_1}
  {$DEFINE DFS_CPPB}
  {$DEFINE DFS_WIN32}
  {$DEFINE DFS_USEDEFSHLOBJ} { Only Delphi 3 and C++B have no errors in SHLOBJ }
{$ELSE}{$IFDEF VER90}
  {$DEFINE DFS_DELPHI_2}
  {$DEFINE DFS_DELPHI}
  {$DEFINE DFS_WIN32}
{$ELSE}{$IFDEF VER80}
  {$DEFINE DFS_DELPHI_1}
  {$DEFINE DFS_DELPHI}
{$ELSE}
  { Don't know what the hell it is.  Could be new version, or could be old BP. }
  {$DEFINE DFS_UNKNOWN_COMPILER}
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}


