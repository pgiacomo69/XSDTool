{$I DFS.INC}  { Standard defines for all Delphi Free Stuff components }

{------------------------------------------------------------------------------}
{ TMRUFileList v2.15                                                           }
{------------------------------------------------------------------------------}
{ A Most Recently Used (MRU) File List component for Delphi.                   }
{ Copyright 1997, Brad Stowers.  All Rights Reserved.                          }
{ This component can be freely used and distributed in commercial and          }
{ private environments, provied this notice is not modified in any way.        }
{------------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions   }
{ at bstowers@pobox.com.                                                       }
{ The latest version of this component can always be found at:                 }
{   http://www.pobox.com/~bstowers/delphi/                                     }
{ See MRUFList.txt for notes, known issues, and revision history.              }
{------------------------------------------------------------------------------}
{ Date last modified:  December 28, 1997                                       }
{------------------------------------------------------------------------------}

unit MRUFList;

interface

{$IFDEF DFS_WIN32}
  {$R MRUFList.res}
{$ELSE}
  {$R MRUFList.r16}
{$ENDIF}

uses
  Classes, SysUtils,
  {$IFDEF DFS_WIN32}
  Registry, Windows,
  {$ENDIF}
  Menus;

type
  { Registry root values }
  TRootKey = (rkClassesRoot, rkCurrentUser, rkLocalMachine, rkUsers, rkCurrentConfig, rkDynData);

const
  { Defaults for component properties }
  DEF_MAXIMUM = 5;
  DEF_REMOVEONCLICK = TRUE;
  DEF_USESUBMENU = FALSE;
  DEF_SUBMENUNAME = 'Reopen';
  DEF_MAXCAPTIONWIDTH = 200;
  {$IFDEF DFS_WIN32}
  DEF_USEREGISTRY = TRUE;
  DEF_ROOTKEY = rkCurrentUser;
  {$ELSE}
  DEF_USEREGISTRY = FALSE;
  {$ENDIF}

type
  { A simple TMenuItem descendant to be used for RTTI }
  TMRUMenuItem = class(TMenuItem)
  private
    FFullCaption: string;
  public
    ItemNumber: byte;
    constructor Create(AOwner: TComponent); override;
    property FullCaption: string read FFullCaption write FFullCaption;
  end;

  { Event procedure for MRU item click.  Passes filename for easy us }
  TMRUClick = procedure(Sender: TObject; AFilename: string) of object;

  TMRUFileList = class(TComponent)
  private
    { Property variables }
    FMaximum: byte;
    FRemoveOnClick: boolean;
    FUseSubmenu: boolean;
    FInsertSeparator: Boolean;
    FSubmenuName: string;
    FFileMenu: TMenuItem;
    FMenuItems: TStringList;
    FAutoSave: boolean;
    FAutoSaveName: string;
    FAutoSaveKey: string;
    FMaxCaptionWidth: integer;
    { Event variables }
    FOnMRUClick: TMRUClick;
    { Internal use }
    FInhibitUpdate: boolean;
    FUseRegistry: boolean;
    {$IFDEF DFS_WIN32}
    FRegistryKey: HKEY;
    {$ENDIF}
  protected
    procedure Loaded; override;
    { Property methods }
    procedure SetMaximum(Val: byte);
    procedure SetFileMenu(Val: TMenuItem);
    procedure SetUseSubmenu(Val: boolean);
    procedure SetInsertSeparator(Val: boolean);
    procedure SetSubmenuName(Val: string);
    procedure SetMaxCaptionWidth(Val: integer);
    {$IFDEF DFS_WIN32}
    procedure SetAutoSaveRootKey(Val: TRootKey);
    function GetAutoSaveRootKey: TRootKey;
    {$ENDIF}
    { MenuItem OnClick handler }
    procedure MRUClicked(Sender: TObject);
    { Method to place items on menu }
    procedure PopulateMenu; virtual;
    { We need to know if our menu item is deleted. }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    { Methods to add items to the MRU list }
    procedure InsertItem(Index: integer; aFile: string);
    procedure ReplaceItem(OldItem, NewItem: string);
    procedure AddItem(aFile: string);
    procedure AddStringList(Files: TStringList);
    procedure AddStrings(Files: TStrings);
    { Methods to load and save items. }
    function Load: boolean;
    function Save: boolean;
    { Method to remove all MRU items from the menu, but NOT from the internal }
    { list.  You probably want ClearAllItems. }
    procedure RemoveAllItems;
    { Method to clear a single item by name from the MRU items. }
    procedure ClearItem(aFile: string);
    { Method to clear all current MRU items. }
    procedure ClearAllItems;

    { The MRU Items.  Read Only. }
    property Items: TStringList read FMenuItems;
  published
    property Maximum:byte             { Maximum number of items on MRU list }
read FMaximum write SetMaximum default DEF_MAXIMUM;
    property RemoveOnClick:boolean    { Remove MRU item when selected? }
read FRemoveOnClick write FRemoveOnClick default DEF_REMOVEONCLICK;
    property UseSubmenu:boolean       { MRU items placed on a submenu? }
read FUseSubmenu write SetUseSubmenu default DEF_USESUBMENU;
    property InsertSeparator: boolean read FInsertSeparator write SetInsertSeparator default True;
    property SubmenuName: string       { Caption of submenu item, if needed }
read FSubmenuName write SetSubmenuName;
    property OnMRUItemClick:TMRUClick { Event for MRU item selection }
read FOnMRUClick write FOnMRUClick;
    property FileMenu:TMenuItem       { Menu to place MRU items on. }
read FFileMenu write SetFileMenu;
    property AutoSave:boolean         { Save and restore MRU items automatically. }
read FAutoSave write FAutoSave default TRUE;
    property AutoSaveName: string      { The filename (INI) or key (registry) to save to.}
read FAutoSaveName write FAutoSaveName;
    property AutoSaveKey: string       { The section to save to. }
read FAutoSaveKey write FAutoSavekey;
    {$IFDEF DFS_WIN32}
    property AutoSaveRootKey:TRootKey { Root registry key for AutoSaveName registry path }
read GetAutoSaveRootKey write SetAutoSaveRootKey default DEF_ROOTKEY;
    {$ENDIF}
    property MaxCaptionWidth:integer  { Maximum width of an MRU item, 0 = no maximum.}
read FMaxCaptionWidth write SetMaxCaptionWidth default DEF_MAXCAPTIONWIDTH;
    {$IFDEF DFS_WIN32}
    property UseRegistry: boolean read FUseRegistry write FUseRegistry default DEF_USEREGISTRY;
    {$ENDIF}
  end;

procedure Register;

implementation

uses
  WinTypes, WinProcs, Graphics, FileCtrl, INIFiles;

var
  MenuBmp: TBitmap;


{ Simple TMenuItem descendant mainly for RTTI, but also knows it's index     }
{ into the FMenuItems list.                                                  }
constructor TMRUMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ItemNumber := 0;
  FFullCaption := inherited Caption;
end;



{ Needs to do nothing more than initialize properties to defaults and create }
{ the list variable.                                                         }
constructor TMRUFileList.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  {$IFDEF DFS_WIN32}
  AutoSaveRootKey := rkCurrentUser;
  {$ENDIF}
  FMaximum := DEF_MAXIMUM;
  FRemoveOnClick := DEF_REMOVEONCLICK;
  FUseSubmenu := DEF_USESUBMENU;
  FInsertSeparator := True;
  SubmenuName := DEF_SUBMENUNAME;
  FMaxCaptionWidth := DEF_MAXCAPTIONWIDTH;
  FMenuItems := TStringList.Create;
  FMenuItems.Sorted := FALSE;
  FInhibitUpdate := FALSE;
  FOnMRUClick := NIL;
  FAutoSave := TRUE;
  FUseRegistry := DEF_USEREGISTRY;
  if FUseRegistry then
    FAutoSaveName := '\Software\My Application'
  else
    FAutoSaveName := 'MyINI.INI';
  FAutoSaveKey := 'MRU Items';
end;

destructor TMRUFileList.Destroy;
begin
  if not (csDesigning in ComponentState) then
    if FAutoSave then
      Save;
  { Cleanup the list variable }
  FMenuItems.Free;
  inherited Destroy;
end;

procedure TMRUFileList.Loaded;
begin
  if not (csDesigning in ComponentState) then
    if FAutoSave then
      Load;
end;

procedure TMRUFileList.SetMaximum(Val: byte);
begin
  if FMaximum = Val then
    exit;    { Value not different, do nothing. }
  if Val < FMaximum then
  begin    { If new less than old value, remove some. }
    while FMenuItems.Count > Val do { Remove extra items }
      FMenuItems.Delete(FMenuItems.Count - 1);
    PopulateMenu;                 { Redo the MRU menu. }
  end;
  { Note: an ELSE clause is not needed since if new value is more than old,  }
  {       nothing needs to be done.                                          }
  FMaximum := Val;
end;

procedure TMRUFileList.SetFileMenu(Val: TMenuItem);
begin
  RemoveAllItems;           { Remove MRU items from old menu. }
  FFileMenu := Val;
  PopulateMenu;             { Add MRU items to new menu.      }
end;

procedure TMRUFileList.SetUseSubmenu(Val: boolean);
begin
  if FUseSubmenu = Val then
    exit; { Value not different, do nothing . }
  FUseSubmenu := Val;
  PopulateMenu;                   { Redo the menu according to new value. }
end;

procedure TMRUFileList.SetInsertSeparator(Val: boolean);
begin
  if Val = FInsertSeparator then
    exit;
  FInsertSeparator := Val;
  PopulateMenu;
end;

procedure TMRUFileList.SetSubmenuName(Val: string);
begin
  if FSubmenuName = Val then
    exit; { Value not different, do nothing . }
  FSubmenuName := Val;
  if FUseSubmenu then         { Don't bother if we're not using the submenu. }
    PopulateMenu;             { Redo the menu according to new value. }
end;

procedure TMRUFileList.SetMaxCaptionWidth(Val: integer);
begin
  if Val = FMaxCaptionWidth then
    exit; { Value not different, do nothing. }
  FMaxCaptionWidth := Val;
  PopulateMenu;
end;

{$IFDEF DFS_WIN32}
procedure TMRUFileList.SetAutoSaveRootKey(Val: TRootKey);
const
  ORD_TO_VAL: array[TRootKey] of HKEY = (HKEY_CLASSES_ROOT, HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE, HKEY_USERS, HKEY_CURRENT_CONFIG, HKEY_DYN_DATA);
begin
  FRegistryKey := ORD_TO_VAL[Val];
end;

function TMRUFileList.GetAutoSaveRootKey: TRootKey;
begin
  case FRegistryKey of
    HKEY_CLASSES_ROOT:
      Result := rkClassesRoot;
    HKEY_LOCAL_MACHINE:
      Result := rkLocalMachine;
    HKEY_USERS:
      Result := rkUsers;
    HKEY_CURRENT_CONFIG:
      Result := rkCurrentConfig;
    HKEY_DYN_DATA:
      Result := rkDynData;
  else
    Result := rkCurrentUser;
  end;
end;
{$ENDIF}

procedure TMRUFileList.MRUClicked(Sender: TObject);
var
  ClickItem: string;
begin
  with Sender as TMRUMenuItem do
  begin
    if assigned(FOnMRUClick) then       { Save the clicked item's filename }
      ClickItem := FMenuItems[ItemNumber - 1];
    if FRemoveOnClick then
    begin        { Remove the item, if desired. }
      FMenuItems.Delete(ItemNumber - 1);
      PopulateMenu;
    end;
    if assigned(FOnMRUClick) then       { Call the users event handler. }
      FOnMRUClick(Sender, ClickItem);
  end;
end;

procedure TMRUFileList.InsertItem(Index: integer; aFile: string);
var
  i: integer;
begin
  i := FMenuItems.IndexOf(aFile);        { Search list for item being added. }
  if i > -1 then                         { Find it? }
    FMenuItems.Move(i, Index)            { Yes, move it to the top. }
  else
  begin
    FMenuItems.Insert(Index, aFile);     { No, add it. }
    while FMenuItems.Count > FMaximum do { Remove extra items. }
      FMenuItems.Delete(FMenuItems.Count - 1);
  end;
  if not FInhibitUpdate then             { Should we update the menu now? }
    PopulateMenu;                        { Yes, redo the menu. }
end;

procedure TMRUFileList.ReplaceItem(OldItem, NewItem: string);
var
  i: integer;
begin
  i := FMenuItems.IndexOf(OldItem);      { Search list for item being added. }
  if i = -1 then                         { Find it? }
    exit                                 { No, get out. }
  else
  begin
    FMenuItems.Delete(i);                { Yes, remove it }
    FMenuItems.Insert(i, NewItem);       { and replace with the new one. }
  end;
  if not FInhibitUpdate then             { Should we update the menu now? }
    PopulateMenu;                        { Yes, redo the menu. }
end;

procedure TMRUFileList.AddItem(aFile: string);
var
  i: integer;
begin
  i := FMenuItems.IndexOf(aFile);        { Search list for item being added. }
  if i > -1 then                         { Find it? }
    FMenuItems.Move(i, 0)                { Yes, move it to the top. }
  else
  begin
    FMenuItems.Add(aFile);         { No, add it to the top. }
    while FMenuItems.Count > FMaximum do { Remove extra items. }
      FMenuItems.Delete(0);
  end;
  if not FInhibitUpdate then             { Should we update the menu now? }
    PopulateMenu;                        { Yes, redo the menu. }
end;

procedure TMRUFileList.AddStringList(Files: TStringList);
var
  x: integer;
begin
  FInhibitUpdate := TRUE;      { Don't let AddItem method call PopulateMenu. }
  for x := 0 to Files.Count - 1 do  { Add each item. }
    AddItem(Files[x]);
  FInhibitUpdate := FALSE;     { Clear inhibit flag. }
  PopulateMenu;                { Update menu now that all are added. }
end;

procedure TMRUFileList.AddStrings(Files: TStrings);
var
  x: integer;
begin
  FInhibitUpdate := TRUE;      { Don't let AddItem method call PopulateMenu. }
  for x := 0 to Files.Count - 1 do  { Add each item. }
    AddItem(Files[x]);
  FInhibitUpdate := FALSE;     { Clear inhibit flag. }
  PopulateMenu;                { Update menu now that all are added. }
end;

procedure TMRUFileList.PopulateMenu;
var
  Offset, x: integer;
  NewItem: TMRUMenuItem;
  ParentMenu, AddMenu: TMenuItem;
begin
  if (FFileMenu = NIL) then
    exit;        { No menu assigned, nothing to do. }
  RemoveAllItems;                        { Remove all old items. }
  if (FMenuItems.Count = 0) then
    exit;   { Don't have any items, we're done. }

  { If FFileMenu is an item, insert before it.  If not, it's a submenu }
  { so just add to the end of it                                       }
  if FFileMenu.Count <> 0 then
  begin
    Offset := FFileMenu.Count;
    ParentMenu := FFileMenu;
  end
  else
  begin
{$IFDEF DFS_WIN32}
    Offset := FFileMenu.MenuIndex;
{$ELSE}
    Offset := FFileMenu.Parent.IndexOf(FFileMenu);
{$ENDIF}
    ParentMenu := FFileMenu.Parent;
  end;

  { Create separator item. }
  if FInsertSeparator then
  begin
    NewItem := TMRUMenuItem.Create(ParentMenu);
    NewItem.Caption := '-';
    ParentMenu.Insert(Offset, NewItem);
    inc(Offset);
  end;

  { Create submenu if needed }
  if FUseSubmenu then
  begin
    AddMenu := TMRUMenuItem.Create(ParentMenu);
    AddMenu.Caption := FSubmenuName;
    ParentMenu.Insert(Offset, AddMenu);
    Offset := 0;
  end
  else
    AddMenu := ParentMenu; { Don't need submenu, just set to the file menu. }

  { Create MRU items }
  for x := 0 to FMenuItems.Count - 1 do
  begin
    NewItem := TMRUMenuItem.Create(AddMenu);
    NewItem.FullCaption := '&' + IntToStr(x + 1) + ' ' + FMenuItems[x];  { Caption }
    if FMaxCaptionWidth = 0 then
      NewItem.Caption := NewItem.FullCaption
    else
      NewItem.Caption := '&' + IntToStr(x + 1) + ' ' + MinimizeName(FMenuItems[x], MenuBmp.Canvas, FMaxCaptionWidth);
    NewItem.ItemNumber := x + 1;                { Index into FMenuItems list }
    NewItem.OnClick := MRUClicked;              { Set event handler }
    AddMenu.Insert(Offset, NewItem);            { Add to the menu }
    inc(Offset);
  end;
end;

procedure TMRUFileList.RemoveAllItems;
var
  x: integer;
  DeleteItem, ParentMenu: TMenuItem;
begin
  if FFileMenu = NIL then
    exit;                { No menu, nothing to delete. }

  if FFileMenu.Count <> 0 then
    ParentMenu := FFileMenu
  else
    ParentMenu := FFileMenu.Parent;

  if ParentMenu = NIL then
    exit;                { No menu, nothing to delete. }

  { We don't know exactly which items are ours, so we have to check them all }
  for x := ParentMenu.Count - 1 downto 0 do
  begin
    { Use RTTI to determine if item is of our special descenadant type. }
    if (ParentMenu[x] is TMRUMenuItem) then
    begin
      DeleteItem := ParentMenu[x];
      ParentMenu.Delete(x);   { Yes, it is, delete it. }
      DeleteItem.Free;        { Don't forget the object, too! - RGL }
    end;
  end;
end;

procedure TMRUFileList.ClearItem(aFile: string);
var
  i: integer;
begin
  i := FMenuItems.IndexOf(aFile);        { Search list for item being removed. }
  if i > -1 then                         { Find it? }
  begin
    FMenuItems.Delete(i);                { Yes, delete it. }
    PopulateMenu;                        { redo the menu. }
  end;
end;

function TMRUFileList.Load: boolean;

  procedure StripIdents(Items: TStringList);
  var
    p: byte;
    x: integer;
  begin
    for x := 0 to Items.Count - 1 do
    begin
      p := Pos('=', Items[x]) + 1;
      Items[x] := copy(Items[x], p, Length(Items[x]) - p + 1);
    end;
  end;

var
  {$IFDEF DFS_WIN32}
  RegSettings: TRegIniFile;
  {$ENDIF}
  IniSettings: TIniFile;
begin
  Result := FALSE;
  if (FAutoSaveName = '') or (FAutoSaveKey = '') then
    exit;
  {$IFDEF DFS_WIN32}
  if FUseRegistry then
  begin
    RegSettings := TRegIniFile.Create(FAutoSaveName);
    try
      RegSettings.RootKey := FRegistryKey;
      RegSettings.OpenKey(FAutoSaveName, TRUE);
      RegSettings.ReadSectionValues(FAutoSaveKey, FMenuItems);
    finally
      RegSettings.Free;
    end;
  end
  else
  {$ENDIF}
  begin
    IniSettings := TIniFile.Create(FAutoSaveName);
    try
      IniSettings.ReadSectionValues(FAutoSaveKey, FMenuItems);
    finally
      IniSettings.Free;
    end;
  end;
  StripIdents(FMenuItems);
  PopulateMenu;
  Result := TRUE;
end;

function TMRUFileList.Save: boolean;
var
  {$IFDEF DFS_WIN32}
  RegSettings: TRegIniFile;
  {$ENDIF}
  IniSettings: TIniFile;
  x: integer;
begin
  Result := FALSE;
  if (FAutoSaveName = '') or (FAutoSaveKey = '') then
    exit;
  {$IFDEF DFS_WIN32}
  if FUseRegistry then
  begin
    RegSettings := TRegIniFile.Create(FAutoSaveName);
    try
      RegSettings.RootKey := FRegistryKey;
      RegSettings.OpenKey(FAutoSaveName, TRUE);
      RegSettings.EraseSection(FAutoSaveKey);
      for x := 0 to Items.Count - 1 do
        RegSettings.WriteString(FAutoSaveKey, 'F' + IntToStr(x), Items[x]);
      Result := TRUE;
    finally
      RegSettings.Free;
    end;
  end
  else
  {$ENDIF}
  begin
    IniSettings := TIniFile.Create(FAutoSaveName);
    try
      IniSettings.EraseSection(FAutoSaveKey);
      for x := 0 to Items.Count - 1 do
        IniSettings.WriteString(FAutoSaveKey, 'F' + IntToStr(x), Items[x]);
      Result := TRUE;
    finally
      IniSettings.Free;
    end;
  end;
end;

procedure TMRUFileList.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFileMenu) and (csDesigning in ComponentState) then
    { Our placement menu item has been deleted. }
    FFileMenu := NIL;
end;

procedure TMRUFileList.ClearAllItems;
begin
  RemoveAllItems;
  FMenuItems.Clear;
end;

procedure Register;
begin
  RegisterComponents('Freeware', [TMRUFileList]);
end;


{$IFNDEF DFS_WIN32}
procedure FreeMemoryBmp; far;
begin
  MenuBmp.Free;
end;
{$ENDIF}

var
{$IFDEF DFS_WIN32}
  NCM: TNonClientMetrics;
{$ELSE}
  LF: TLogFont;
{$ENDIF}

initialization
  MenuBmp := TBitmap.Create;
  {$IFDEF DFS_WIN32}
  NCM.cbSize := SizeOf(TNonClientMetrics);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NCM, 0);
  MenuBmp.Canvas.Font.Handle := CreateFontIndirect(NCM.lfMenuFont);
  {$ELSE}
  GetObject(GetStockObject(SYSTEM_FONT), SizeOf(TLogFont), @LF);
  MenuBmp.Canvas.Font.Handle := CreateFontIndirect(LF);
  {$ENDIF}

{$IFDEF DFS_WIN32}

finalization
  MenuBmp.Free;
{$ELSE}
  AddExitProc(FreeMemoryBmp);
{$ENDIF}

end.

