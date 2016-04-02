unit uXSDVisitor;

interface

uses
    uXSDObj
  ;
  
type

  
  TXSDPascalGeneratorVisitor = class(TXSDVisitor)
  private 
    FStream: TStream;
  public	
    constructor Create(aStream: TStream);
    procedure Visit(aSchema: TClassDefs); override;
  end;
  
implementation


constructor TXSDPascalGeneratorVisitor.Create(aStream: TStream);
begin
  FStream := aStream;

end;
procedure TXSDPascalGeneratorVisitor.Visit(aSchema: TClassDefs);
begin
  inherited;
  // refactoring underway..
  aSchema.SaveToStream(FStream);
  
end;

end.
