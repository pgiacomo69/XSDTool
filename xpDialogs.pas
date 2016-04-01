unit xpDialogs;

interface
uses
  Classes,
  Dialogs;

type
  //Common dialogs with Windows 2000 style support
  TXOpenDialog = class(TOpenDialog)
  public
    function Execute: Boolean; override;
  end;

  TXSaveDialog = class(TSaveDialog)
  public
    function Execute: Boolean; override;
  end;

procedure Register;

implementation
uses
  Windows, Sysutils, CommDlg, Shlobj, Forms;

type
  TOpenFileNameEx = packed record
    // Size of the structure in bytes.
    lStructSize: DWORD;
    // Handle that is the parent of the dialog.
    hWndOwner: HWND;
    // Application instance handle.
    hInstance: HINST;
    // String containing filter information.
    lpstrFilter: PAnsiChar;
    // Will hold the filter chosen by the user.
    lpstrCustomFilter: PAnsiChar;
    // Size of lpstrCustomFilter, in bytes.
    nMaxCustFilter: DWORD;
    // Index of the filter to be shown.
    nFilterIndex: DWORD;
    // File name to start with (and retrieve).
    lpstrFile: PAnsiChar;
    // Size of lpstrFile, in bytes.
    nMaxFile: DWORD;
    // File name without path will be returned.
    lpstrFileTitle: PAnsiChar;
    // Size of lpstrFileTitle, in bytes.
    nMaxFileTitle: DWORD;
    // Starting directory.
    lpstrInitialDir: PansiChar;
    // Title of the open dialog.
    lpstrTitle: PAnsiChar;
    // Controls user selection options.
    Flags: DWORD;
    // Offset of file name in filepath=lpstrFile.
    nFileOffset: Word;
    // Offset of extension in filepath=lpstrFile.
    nFileExtension: Word;
    // Default extension if no extension typed.
    lpstrDefExt: PAnsiChar;
    // Custom data to be passed to hook.
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM;
      lParam: LPARAM): UINT stdcall; // Hook.
    // Template dialog, if applicable.
    lpTemplateName: PAnsiChar;
    // Extended structure starts here.
    pvReserved: Pointer; // Reserved, use nil.
    dwReserved: DWORD; // Reserved, use 0.
    FlagsEx: DWORD; // Extended Flags.
  end;

  GetOpenFileNameExProc = function(var OpenFile: TOpenFilenameEx): Bool;
  stdcall;
  GetSaveFileNameExProc = function(var SaveFile: TOpenFileNameEx): bool;
  stdcall;

var
  CommHandle: tHandle = 0;
  GetOpenFileNameEx: GetOpenFileNameExProc = nil;
  GetSaveFileNameEx: GetSaveFileNameExProc = nil;

procedure Register;
begin
  RegisterComponents('Dialoge', [tXOpenDialog, tXSaveDialog]);
end;

function OpenInterceptor(var DialogData: TOpenFileName):
  Bool; stdcall;
var
  DialogDataEx: TOpenFileNameEx;
begin
  Move(DialogData, DialogDataEx, SizeOf(DialogData));
  DialogDataEx.FlagsEx := 0;
  DialogDataEx.lStructSize := SizeOf(TOpenFileNameEx);
  Result := GetOpenFileNameEx(DialogDataEx);
  Move(DialogDataEx, DialogData, SizeOf(DialogData));
end;

function SaveInterceptor(var DialogData: TOpenFileName):
  Bool; stdcall;
var
  DialogDataEx: TOpenFileNameEx;
begin
  Move(DialogData, DialogDataEx, SizeOf(DialogData));
  DialogDataEx.FlagsEx := 0;
  DialogDataEx.lStructSize := SizeOf(TOpenFileNameEx);
  Result := GetSaveFileNameEx(DialogDataEx);
  Move(DialogDataEx, DialogData, SizeOf(DialogData));
end;

{ TXOpenDialog }

function TXOpenDialog.Execute: Boolean;
begin
  if (Win32MajorVersion >= 5) and (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    Result := DoExecute(@OpenInterceptor);
  end
  else
    Result := inherited Execute;
end;

{ TXSaveDialog }

function TXSaveDialog.Execute: Boolean;
begin
  if (Win32MajorVersion >= 5) and (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    Result := DoExecute(@SaveInterceptor);
  end
  else
    Result := inherited Execute;
end;

initialization
  CommHandle := Windows.LoadLibrary('comdlg32.dll');
  if CommHandle <> 0 then
  begin
    GetOpenFileNameEx := GetProcAddress(CommHandle, PChar('GetOpenFileNameA'));
    GetSaveFileNameEx := GetProcAddress(CommHandle, PChar('GetSaveFileNameA'));
  end;

finalization
  if CommHandle <> 0 then
    FreeLibrary(CommHandle);
end.

