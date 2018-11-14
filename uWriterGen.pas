unit uWriterGen;

interface
uses
  Classes,
  uXSDobj,
  uXMLTools;
type
 TOutputUnit=class
               index:Integer;
               unitName:String;
               unitFIleName:String;
               aStream: TStringStream;
              end;
 TOutputUnits=Array of TOutputUnit;
 TClassWriterGen=class
                  protected
                   FclassDefs:tClassDefs;
                   FOutputs:TOutputUnits;
                   FInterfOut:TOutputUnit;
                   fImplOut:TOutputUnit;
                   function getBaseFileExtension:String; virtual; Abstract;
                   function GetNewOutput(const unitname,filename:String):TOutputUnit;
                   procedure oute(const o: TOutputUnit; const s: string); overload;
                   procedure oute(const i: Integer; const s: string); overload;
                   procedure outline(const o: TOutputUnit; const s: string); overload;
                   procedure outline(const i: Integer; const s: string); overload;
                   procedure WriteInterface; virtual; abstract;
                   procedure WriteImplementation; virtual; abstract;
                  public
                   constructor create(const aClassDefs:tClassDefs);
                   function Execute:TOutputUnits;
                   Property BaseFileExtension:String read getBaseFileExtension;
                 end;

implementation

uses mylib,
  SysUtils;

{ TClassWriterGen }

function TClassWriterGen.Execute: TOutputUnits;
var i:integer;
begin
 FclassDefs.SortClasses;
 WriteInterface;
 WriteImplementation;
 for i:=0 to length(FOutputs)-1 do FOutputs[i].aStream.Position := 0;
 result:=FOutputs;
end;

function TClassWriterGen.GetNewOutput(const unitname,filename:String): TOutputUnit;
var
 i:integer;

begin
 i:=length(FOutputs);
 setlength(FOutputs,i+1);
 result:=TOutputUnit.Create;
 result.index:=i;
 result.unitName:=unitname;
 result.unitFIleName:=filename;
 result.aStream:=TStringStream.Create;
 FOutputs[i]:=result;
end;


constructor TClassWriterGen.create(const aClassDefs:tClassDefs);

 begin
  FclassDefs:=aClassDefs;
  FInterfOut:=GetNewOutput(ChangeFileExt(ExtractFilename(FclassDefs.XSDFilename),''),ChangeFileExt(ExtractFilename(FclassDefs.XSDFilename),BaseFileExtension));
  fImplOut:=FInterfOut;
 end;

procedure TClassWriterGen.oute(const o: TOutputUnit; const s: string);
 begin
  if length(s) > 0 then
    o.aStream.WriteString(s);
 end;

procedure TClassWriterGen.oute(const i: Integer; const s: string);
 begin
  oute(FOutputs[i],s);
 end;

procedure TClassWriterGen.outline(const o: TOutputUnit; const s: string);
 begin
   oute(o,s + crlf);
 end;

procedure TClassWriterGen.outline(const i: Integer; const s: string);
 begin
   oute(i,s + crlf);
 end;




end.
