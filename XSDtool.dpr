program XSDtool;

uses
  Forms,
  janstrings in 'janstrings.pas',
  JanXMLParser2 in 'JanXMLParser2.pas',
  janXPathTokenizer in 'janXPathTokenizer.pas',
  msnettypes in 'msnettypes.pas',
  mylib in 'mylib.pas',
  uWSDLobj in 'uWSDLobj.pas',
  uWSDLParser in 'uWSDLParser.pas',
  uXMLTools in 'uXMLTools.pas',
  uXSDobj in 'uXSDobj.pas',
  uXSDParser in 'uXSDParser.pas',
  uXSDtool in 'uXSDtool.pas' {Form1},
  MRUFLIST in 'MRUFLIST.PAS',
  uWriterDelphiOld in 'uWriterDelphiOld.pas',
  uWriterGen in 'uWriterGen.pas',
  uWriterDelphi in 'uWriterDelphi.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

