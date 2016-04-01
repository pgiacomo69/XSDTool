unit uXSDtool;
// -------------------------------------------------------------------
// XSDTool is a utility to create Class-definitions from an XSD file.
// it is based on JanXMLParser which can be found at
// http://www.jansfreeware.com
//   I had to slightly modify the parser because it had a memory leak.
//   the corrected version is part of this archive.
// I also used MRUFileList from Brad Stowers.
//   unfortunately hist delphi-free-stuff pages are no longer available.
//   the unit therefore is included here.
//
// XSDobj and XSDparser are mine and can be used freely for everybody.
// XMLTools is mine and can also be used freely.
// Mylib is a collection of usefull and not so useful routines, but
//   included in almost all my projects. See what you can do with it.
// -------------------------------------------------------------------
// (c) 2005 Thomas Kerkmann
// email: thkerkmann@t-online.de
// -------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, xpDialogs,
  JanXMLParser2, ImgList, ActnList, ToolWin, MRUFList, System.ImageList, System.Actions;
//  , SynEditHighlighter,
//  SynHighlighterXML, SynEdit, SynMemo, SynHighlighterPas;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    f: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Fullexpand1: TMenuItem;
    Fullcollapse1: TMenuItem;
    Parse1: TMenuItem;
    test1: TMenuItem;
    debug1: TMenuItem;
    PageControl1: TPageControl;
    tsTree: TTabSheet;
    tree: TTreeView;
    tsXML: TTabSheet;
    tsCode: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ActionList1: TActionList;
    acOpen: TAction;
    acExit: TAction;
    ImageList1: TImageList;
    acExpand: TAction;
    acCollapse: TAction;
    acCreateClass: TAction;
    acSave: TAction;
    ToolButton9: TToolButton;
    Options1: TMenuItem;
    Save1: TMenuItem;
    askoverride1: TMenuItem;
    promptaftersave1: TMenuItem;
    tsLog: TTabSheet;
    mmLog: TMemo;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    acWordwrap: TAction;
    FindDialog1: TFindDialog;
    acFind: TAction;
    ToolButton12: TToolButton;
//    SynXMLSyn1: TSynXMLSyn;
    mmXML: TMemo;
    mmCode: TMemo;
    XOpenDialog1: TOpenDialog;
//    SynPasSyn1: TSynPasSyn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure debug1Click(Sender: TObject);
    procedure acOpenExecute(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure acExpandExecute(Sender: TObject);
    procedure acCollapseExecute(Sender: TObject);
    procedure acCreateClassExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure acSaveExecute(Sender: TObject);
    procedure askoverride1Click(Sender: TObject);
    procedure promptaftersave1Click(Sender: TObject);
    procedure mmCodeChange(Sender: TObject);
    procedure MRUMRUItemClick(Sender: TObject; AFilename: string);
    procedure acWordwrapExecute(Sender: TObject);
    procedure acFindExecute(Sender: TObject);
  private
    { Private-Deklarationen }
    dom: tJanXMLParser2;
    fn_xsd: string;
    fn_time: string;
    bChanged: boolean;
    findpos: integer;
    procedure DoOpen(const aFilename: string);
    procedure SetActiveActions;
    procedure ParseTree;
    procedure ParseTreeNode(node: TTreeNode; dnode: TjanXMLNode2);
    procedure parsedef;
    procedure parsewsdl(xSchema: tJanXMLNode2);
    procedure parseSchema(xSchema: tJanXMLNode2);
    procedure Logout(const s: string);
    procedure loadpos;
    procedure savepos;
    procedure loadreg;
    procedure savereg;
    procedure FindXML(Sender: tObject);
    procedure FindCode(Sender: tObject);
  protected
    procedure WMDropFiles(var msg: tMessage); message WM_DROPFILES;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation
uses
  Registry,
  shellapi,
  uXMLtools,
  uXSDobj,
  uXSDParser,
  uWSDLobj,
  uWSDLParser;

const
  RegKeyName = 'Software\XSDTool';

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
  fn: string;
begin
  Application.Title := Caption;
  loadreg;
  loadpos;
  mmCode.Lines.Clear;
  mmXML.Lines.Clear;
  dom := tJanXMLParser2.Create;
  bChanged := false;
  pagecontrol1.ActivePageIndex := 0;

  DragAcceptFiles(handle, true);

  SetActiveActions;

  if ParamCount > 0 then
  begin
    fn := ParamStr(1);
    if FileExists(fn) then
      DoOpen(fn);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dom.free;
  savepos;
end;

procedure TForm1.debug1Click(Sender: TObject);
begin
  debug1.checked := not debug1.checked;
  tsLog.TabVisible := debug1.checked;
  savereg;
end;

procedure TForm1.askoverride1Click(Sender: TObject);
begin
  askoverride1.checked := not askoverride1.checked;
  savereg;
end;

procedure TForm1.promptaftersave1Click(Sender: TObject);
begin
  promptaftersave1.checked := not promptaftersave1.checked;
  savereg;
end;

procedure TForm1.Logout(const s: string);
begin
  mmLog.Lines.Add(s);
end;

// ------------------------------------------------------------------
// read into treeview

procedure TForm1.ParseTreeNode(node: TTreeNode; dnode: TjanXMLNode2);
var
  n2: TTreenode;
  dn2: TjanXMLNode2;
  i, c: integer;
  nodename: string;
begin
  c := dnode.nodes.Count;
  if c = 0 then
    exit;
  for i := 0 to c - 1 do
  begin
    dn2 := TjanXMLNode2(dnode.Nodes[i]);
    nodename := dn2.name;
    n2 := tree.items.AddChildObject(node, nodename, dn2);
    parsetreenode(n2, dn2);
  end;
end;

procedure TForm1.ParseTree;
var
  n: TTreeNode;
  dn: TjanXMLNode2;
  nodename: string;
begin
  dn := dom;
  nodename := dn.name;
  n := tree.Items.AddObject(nil, nodename, dn);
  parsetreenode(n, dn);
end;

// ------------------------------------------------------------------
// XSD parsing

procedure TForm1.parseSchema(xSchema: tJanXMLNode2);
var
  Parser: tXSDParser;
  m: tMemoryStream;
begin // procedure parseSchema(dn:tJanXMLNode2)
  Parser := tXSDParser.Create(fn_xsd);
  if debug1.checked then
    Parser.OnLogout := Logout;

  Parser.parseSchema(xSchema);

  m := tMemoryStream.Create;
  Parser.SaveToStream(m);
  m.Position := 0;

  PageControl1.ActivePage := tsCode;
  mmCode.Lines.LoadFromStream(m);
  bChanged := true;
  m.free;

  Parser.Free;

  SetActiveActions;
end; // procedure parseSchema(dn:tJanXMLNode2)

procedure TForm1.parsedef;
var
  i: integer;
begin
  mmCode.Lines.Clear;
  if (dom.name = xsschema) or (dom.name = xsschema1) then
    parseSchema(dom)
  else if Namepart(dom.name) = 'definitions' then
    parseWSDL(dom)
  else
    messagedlg('No schema!', mtError, [mbOk], 0);
end;

// ------------------------------------------------------------------
// actions

procedure TForm1.acOpenExecute(Sender: TObject);
begin
  if XOpenDialog1.Execute then
    DoOpen(XOpenDialog1.Filename);
end;

procedure TForm1.MRUMRUItemClick(Sender: TObject; AFilename: string);
begin
  if FileExists(aFilename) then
    DoOpen(aFilename)
  else
    MessageDlg('File no longer available: ' + aFilename, mtError, [mbOk], 0);
end;

procedure TForm1.DoOpen(const aFilename: string);
begin
  Caption := Application.Title + ' [' + aFilename + ']';
  fn_xsd := aFilename;
  fn_Time := FormatDateTime('c', FileDateToDateTime(FileAge(fn_xsd)));

  tree.items.BeginUpdate;
  tree.items.clear;

  dom.LoadXML(fn_xsd);
  mmXML.Text := dom.xml;
  mmCode.Lines.Clear;
  bChanged := false;

  parsetree;

  tree.items.EndUpdate;
  tree.FullExpand;

  PageControl1.ActivePage := tsXML;
  SetActiveActions;
end;

procedure TForm1.acExitExecute(Sender: TObject);
begin
  close;
end;

procedure TForm1.acExpandExecute(Sender: TObject);
begin
  tree.FullExpand;
end;

procedure TForm1.acCollapseExecute(Sender: TObject);
begin
  tree.FullCollapse;
end;

procedure TForm1.acCreateClassExecute(Sender: TObject);
begin
  parsedef;
  // bchanged := true;
  PageControl1.ActivePage := tsCode;
  SetActiveActions;
end;

procedure TForm1.acSaveExecute(Sender: TObject);
var
  fn_pas: string;
  s: string;
begin
  // build destination file name
  fn_pas := ExtractFilePath(fn_xsd) + 'u' +
    ChangeFileExt(ExtractFileName(fn_xsd), '.pas');

  if FileExists(fn_pas) and askoverride1.checked then
    if MessageDlg(fn_pas + ' already exists. Do you want to override?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      exit;

  mmCode.Lines.SaveToFile(fn_pas);
  bChanged := false;
  SetActiveActions;

  s := 'Delphi class definition was saved to ' + fn_pas;
  if promptaftersave1.checked then
    MessageDlg(s, mtInformation, [mbOk], 0);
  Statusbar1.SimpleText := s;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin
  SetActiveActions;
end;

procedure TForm1.SetActiveActions;
begin
  acCreateClass.Enabled := (tree.Items.Count > 0);

  acExpand.Enabled := (Pagecontrol1.Activepage = tsTree)
    and (tree.Items.Count > 0);
  acCollapse.Enabled := (Pagecontrol1.Activepage = tsTree)
    and (tree.Items.Count > 0);

  acSave.Enabled := (PageControl1.ActivePage = tsCode)
    and (mmCode.Lines.Count > 0) and bChanged;

  acWordwrap.enabled := (PageControl1.ActivePage = tsXML);
  acFind.Enabled := (PageControl1.ActivePage = tsXML) or
    (PageControl1.ActivePage = tsCode);
end;

// ------------------------------------------------------------------
// options

procedure TForm1.loadpos;
var
  reg: tRegInifile;
begin
  reg := tRegIniFile.Create(RegKeyName);
  with reg do
  begin
    left := ReadInteger('Position', 'left', left);
    top := ReadInteger('Position', 'top', top);
    width := ReadInteger('Position', 'width', width);
    height := ReadInteger('Position', 'height', height);
  end;
  reg.Free;
end;

procedure TForm1.savepos;
var
  reg: tRegInifile;
begin
  reg := tRegIniFile.Create(RegKeyName);
  with reg do
  begin
    WriteInteger('Position', 'left', left);
    WriteInteger('Position', 'top', top);
    WriteInteger('Position', 'width', width);
    WriteInteger('Position', 'height', height);
  end;
  reg.Free;
end;

procedure TForm1.loadreg;
var
  reg: tRegInifile;
begin
  reg := tRegIniFile.Create(RegKeyName);
  with reg do
  begin
    debug1.checked := ReadBool('Options', 'Debug', false);
    tsLog.TabVisible := debug1.checked;
    askoverride1.checked := Readbool('Options', 'AskBeforeOverride', true);
    promptaftersave1.checked := ReadBool('Options', 'PromptAfterSave', false);
  end;
  reg.Free;
end;

procedure TForm1.savereg;
var
  reg: tRegInifile;
begin
  reg := tRegIniFile.Create(RegKeyName);
  with reg do
  begin
    WriteBool('Options', 'Debug', debug1.checked);
    Writebool('Options', 'AskBeforeOverride', askoverride1.checked);
    WriteBool('Options', 'PromptAfterSave', promptaftersave1.checked);
  end;
  reg.Free;
end;

procedure TForm1.mmCodeChange(Sender: TObject);
begin
  // in case we allow editing, which is not allowed by now.
  bChanged := true;
  SetActiveActions;
end;

procedure TForm1.parsewsdl(xSchema: tJanXMLNode2);
var
  Parser: tWSDLParser;
  m: tMemoryStream;
begin
  pageControl1.ActivePage := tsLog;
  Parser := tWSDLParser.Create(fn_xsd);
  if debug1.checked then
  begin
    Parser.OnLogout := Logout;
    uWSDLobj.OnLogout := Logout;
  end;
  Parser.parseSchema(xSchema);

  m := tMemoryStream.Create;
  Parser.SaveToStream(m);
  m.Position := 0;

  PageControl1.ActivePage := tsCode;
  mmCode.Lines.LoadFromStream(m);
  bChanged := true;
  m.free;

  Parser.free;
  SetActiveActions;
end;

procedure TForm1.WMDropFiles(var msg: tMessage);
var
  cnt: UINT;
  buffer: array[0..512] of char;
  dHandle: DWORD;
  i: UINT;
  res: UINT;
begin
  dHandle := msg.wParam;
  cnt := DragQueryFile(dHandle, Cardinal(-1), buffer, sizeof(buffer));
  for i := 0 to cnt - 1 do
  begin
    res := DragQueryFile(dHandle, i, buffer, sizeof(buffer));
    if FileExists(StrPas(buffer)) then
    begin
      DoOpen(StrPas(Buffer));
      break; // only 1 file at a time
    end;
  end;
  msg.result := 0;
end;

procedure TForm1.acWordwrapExecute(Sender: TObject);
const
  scrollers: array[false..true] of tScrollStyle = (ssBoth, ssVertical);
begin
  acWordwrap.checked := not acWordwrap.Checked;
  // mmXML.WordWrap := acWordwrap.Checked;
  mmXML.ScrollBars := scrollers[acWordwrap.Checked];
end;

procedure TForm1.acFindExecute(Sender: TObject);
begin
  findpos := 0;
  if PageControl1.ActivePage = tsXML then
    FindDialog1.OnFind := FindXML
  else
    FindDialog1.OnFind := FindCode;
  FindDialog1.Execute;
end;

procedure TForm1.FindCode(Sender: tObject);
var
  TextLength: integer;
  sPos: integer;
  sLen: integer;
  SelPos: integer;
  SearchString: string;
begin
  with FindDialog1 do
  begin
    TextLength := Length(mmCode.Lines.Text);

    SPos := mmCode.SelStart;
    SLen := mmCode.SelLength;

    SearchString := Copy(mmCode.Lines.Text,
      SPos + SLen + 1,
      TextLength - SLen + 1);
    if (frMatchCase in FindDialog1.Options) then
      SelPos := Pos(FindText, SearchString)
    else
      SelPos := Pos(lowercase(FindText), lowercase(SearchString));
    if SelPos > 0 then
    begin
      mmCode.SelStart := (SelPos - 1) + (SPos + SLen);
//      mmCode.SelEnd := mmCode.SelStart + Length(FindText);
       mmCode.SelLength := Length(FindText);
      mmCode.SetFocus;
    end
    else
      MessageDlg('Not found!', mtInformation, [mbOk], 0);
  end;
end;

procedure TForm1.FindXML(Sender: tObject);
var
  TextLength: integer;
  sPos: integer;
  sLen: integer;
  SelPos: integer;
  SearchString: string;
begin
  with FindDialog1 do
  begin
    TextLength := Length(mmXML.Lines.Text);

    SPos := mmXML.SelStart;
    SLen := mmXML.SelLength;

    SearchString := Copy(mmXML.Lines.Text,
      SPos + SLen + 1,
      TextLength - SLen + 1);
    if (frMatchCase in FindDialog1.Options) then
      SelPos := Pos(FindText, SearchString)
    else
      SelPos := Pos(lowercase(FindText), lowercase(SearchString));
    if SelPos > 0 then
    begin
      mmXML.SelStart := 1 + {}(SelPos - 1) + (SPos + SLen);
//      mmXML.SelEnd := mmXML.SelStart + Length(FindText);
       mmXML.SelLength := Length(FindText);
      mmXML.SetFocus;
    end
    else
      MessageDlg('Not found!', mtInformation, [mbOk], 0);
  end;
end;

end.

