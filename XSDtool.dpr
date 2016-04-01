program XSDtool;

uses
  Forms,
  uXSDtool in 'uXSDtool.pas' {Form1},
  uXSDobj in 'uXSDobj.pas',
  uXSDParser in 'uXSDParser.pas',
  uWSDLParser in 'uWSDLParser.pas',
  uWSDLobj in 'uWSDLobj.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
