unit uWSDLParser;

interface
uses
  Classes,
  JanXMLParser2,
  uXSDParser,
  uWSDLObj;

type
  tLogProcedure = procedure(const s: string) of object;
type
  tWSDLParser = class
  private
    FFilename: string;
    FOnLogout: tLogProcedure;
    xsdparser: tXSDparser;
    Defs: tWebServiceDef;
    procedure Logout(const s: string);
    procedure parseTypes(xTypes: tJanXMLNode2);
    procedure parseMessage(xMessage: tJanXMLNode2);
    procedure parsePortType(xPortType: tJanXMLNode2);
    procedure parseBinding(xBinding: tJanXMLNode2);
    procedure parseService(xService: tJanXMLNode2);
  public
    constructor Create(const filename: string);
    destructor destroy; override;
    procedure parseSchema(xSchema: tJanXMLNode2);
    procedure SaveToStream(aStream: tStream);
    property OnLogout: tLogProcedure read FOnLogout write FOnLogout;
  end;

implementation
uses
  uXMLtools,
  Sysutils;

{ tWSDLParser }

constructor tWSDLParser.Create(const filename: string);
begin
  FFilename := Filename;
  Defs := tWebServiceDef.Create(filename);
end;

destructor tWSDLParser.destroy;
begin
  FreeAndNil(Defs);
  if Assigned(xsdparser) then
    FreeAndNil(xsdparser);
  inherited;
end;

procedure tWSDLParser.Logout(const s: string);
begin
  if Assigned(FOnLogout) then
    FOnLogout(s);
end;

procedure tWSDLParser.parseBinding(xBinding: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  c: integer;

  procedure parseOperation(xOp: tJanXMLNode2);
  var
    aName: string;
    aAction: string;
    xn: tJanXMLNode2;
  begin // procedure parseOperation(xOp:tJanXMLNode2);
    aName := xOp.attribute['name'];
    xn := xOp.getChildByName('operation');
    if assigned(xn) then
    begin
      aAction := xn.attribute['soapAction'];
      Defs.Bindings.Addobject(aName, tBindingDef.Create(aName, aAction));
    end;
  end; // procedure parseOperation(xOp:tJanXMLNode2);

begin // procedure tWSDLParser.parseBinding(xBinding: tJanXMLNode2);
  (* WSDL Bindings
    The <binding> element defines the message format and protocol details
      for each port.
  *)
  for c := 0 to xBinding.nodes.Count - 1 do
  begin
    xn := xBinding.nodes[c];
    Logout(xn.name);

    if xn.name = 'operation' then
      parseOperation(xn)
    else
      ;
  end;
end;

procedure tWSDLParser.parseService(xService: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  c: integer;

  procedure parsePort(xPort: tJanXMLNode2);
  var
    aBinding: string;
    aLocation: string;
    xn: tJanXMLNode2;
  begin
    aBinding := xPort.attribute['binding'];
    logout('binding: ' + aBinding);
    xn := xPort.getChildByName('address');
    if assigned(xn) then
    begin
      aLocation := xn.attribute['location'];
      Defs.Services.Addobject(NamePart(aBinding), tServiceDef.Create(aBinding,
        aLocation));
    end
    else
      logout('No address');
  end;

begin
  for c := 0 to xService.nodes.Count - 1 do
  begin
    xn := xService.nodes[c];
    logout('Service.' + xn.name);

    if xn.name = 'port' then
      parsePort(xn)
    else
      ;
  end;
end;

procedure tWSDLParser.parseTypes(xTypes: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  c: integer;

  procedure parseXSDschema(xXSDschema: tJanXMLNode2);
  var
    xn: tJanXMLNode2;
    c: integer;
    s: string;
  begin
    logout('=== PARSING SCHEMA ===');
    s := ChangeFileExt(ExtractFilename(FFilename), '_schema');
    xsdparser := tXSDparser.Create(s);
    xsdparser.OnLogout := FOnLogout;
    xsdparser.parseSchema(xXSDschema);
    if xsdparser.ClassDefs.Count > 0 then
      Defs.AddUses(s)
    else
      FreeAndNil(xsdparser);
    logout('=== SCHEMA DONE ===');

    for c := 0 to xXSDschema.nodes.Count - 1 do
    begin
      xn := xXSDschema.nodes[c];
      if xn.name = 'import' then
      begin
        s := xn.attribute['schemaLocation'];
        logout('add uses : ' + s);
        Defs.AddUses(ChangeFileExt(ExtractFileName(s), ''));
      end;
    end;

  end;

begin // procedure tWSDLParser.parseTypes(xTypes: tJanXMLNode2);
  (* WSDL Types
    The <types> element defines the data type that are used by the web service.
    For maximum platform neutrality, WSDL uses XML Schema syntax to define
      data types.
  *)
  for c := 0 to xTypes.nodes.Count - 1 do
  begin
    xn := xTypes.nodes[c];
    logout(xn.name);
    if xn.name = 'schema' then
      parseXSDschema(xn)
    else
      ;
  end;
end; // procedure tWSDLParser.parseTypes(xTypes: tJanXMLNode2);

procedure tWSDLParser.parseMessage(xMessage: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  c: integer;
  s: string;
  aMessageDef: tMessageDef;

  procedure parsePart(xPart: tJanXMLNode2);
  var
    aName: string;
    aType: string;
    aElement: string;
    aParam: tParamDef;
  begin
    aName := xPart.attribute['name'];
    aType := xPart.attribute['type'];
    aElement := xPart.attribute['element'];
    aParam := tParamDef.Create(aName, aType, aElement);
    aMessageDef.Params.AddObject(aName, aParam);
  end;

begin // procedure tWSDLParser.parseMessage(xMessage: tJanXMLNode2);
  (* WSDL Messages
    The <message> element defines the data elements of an operation.
    Each message can consist of one or more parts.
    The parts can be compared to the parameters of a function call
      in a traditional programming language.
  *)
  s := xMessage.attribute['name'];
  logout(s);
  aMessageDef := tMessageDef.Create(s);
  Defs.Messages.Addobject(s, aMessageDef);
  for c := 0 to xMessage.nodes.Count - 1 do
  begin
    xn := xMessage.nodes[c];
    if xn.name = 'part' then
      parsePart(xn)
    else
      ;
  end;
end; // procedure tWSDLParser.parseMessage(xMessage: tJanXMLNode2);

procedure tWSDLParser.parsePortType(xPortType: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  c: integer;
  s: string;
  aPortDef: tPortDef;

  procedure parseOperation(xOperation: tJanXMLNode2);
  var
    xn: tJanXMLNode2;
    c: integer;
    s: string;
    aOpDef: tOperationDef;

    procedure parseInput(xInput: tJanXMLNode2);
    var
      s: string;
    begin
      // define the input soap message
      s := xInput.attribute['message'];
      logout('parseInput.message: ' + s);

      aOpDef.ParamType := s;
    end;

    procedure parseOutput(xOutput: tJanXMLNode2);
    var
      s: string;
    begin
      // defines the result soap message
      s := xOutput.attribute['message'];
      logout('parseOutput.message: ' + s);

      aOpDef.ResultType := s;
    end;

  begin // procedure parseOperation
    s := xOperation.attribute['name'];
    logout('parseOperation: ' + s);

    aOpDef := tOperationDef.Create(s);
    aPortDef.Operations.AddObject(s, aOpDef);

    for c := 0 to xOperation.nodes.Count - 1 do
    begin
      xn := xOperation.nodes[c];
      if xn.name = 'input' then
        parseInput(xn)
      else if xn.name = 'output' then
        parseOutput(xn)
      else
        ;
    end;
  end; // procedure parseOperation

begin // procedure tWSDLParser.parsePortType(xPortType: tJanXMLNode2);
  (* WSDL Ports
    The <portType> element is the most important WSDL element.
    It defines a web service, the operations that can be performed,
      and the messages that are involved.
    The <portType> element can be compared to a function library
      (or a module, or a class) in a traditional programming language.
  *)
  s := xPortType.attribute['name'];
  logout('parsePortType.name: ' + s);

  aPortDef := tPortDef.Create(s);
  Defs.AddObject(s, aPortDef);

  for c := 0 to xPortType.nodes.Count - 1 do
  begin
    xn := xPortType.nodes[c];
    logout(xn.name);
    if xn.name = 'operation' then
      parseOperation(xn)
    else
      ;
  end;
end; // procedure tWSDLParser.parsePortType(xPortType: tJanXMLNode2);

procedure tWSDLParser.parseSchema(xSchema: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  c: integer;
  tns: string;
  sa: string;
  temp: string;
begin
  (* A WSDL document defines a web service using these major elements:
     Element    Defines
     <portType> The operations performed by the web service
     <message> 	The messages used by the web service
     <types> 	The data types used by the web service
     <binding> 	The communication protocols used by the web service
  *)
  tns := xSchema.attribute['targetNamespace'];
  if tns <> '' then
  begin
    Defs.targetNameSpace := tns;
    // now find the namespace prefix xmlns:...="tns"
    for c := 0 to xSchema.attributecount - 1 do
    begin
      sa := xSchema.attributename[c];
      if pos('xmlns:', sa) = 1 then
      begin
        temp := copy(sa, 7, length(sa));
        if tns = xSchema.attribute[c] then
          Defs.NamespacePrefix := temp
        else
        begin
          Defs.AddInclude(temp, xSchema.attribute[c]);
          Logout('AddInclude ' + temp + ',' + xSchema.attribute[c]);
        end;
      end;
    end;
  end;

  logout('tWSDLparser.parseSchema');
  for c := 0 to xSchema.nodes.Count - 1 do
  begin
    xn := xSchema.nodes[c];
    logout(xn.name);
    if xn.name = 'types' then
      parseTypes(xn)
    else if xn.name = 'message' then
      parseMessage(xn)
    else if xn.name = 'portType' then
      parsePortType(xn)
    else if xn.name = 'binding' then
      parseBinding(xn)
    else if xn.name = 'service' then
      parseService(xn)
    else
      ;
  end;
end; // procedure tWSDLParser.parseSchema(xSchema: tJanXMLNode2);

procedure tWSDLParser.SaveToStream(aStream: tStream);
begin
  if Assigned(xsdparser) then
  begin
    aStream.Write('(*'#13#10, 4);
    xsdparser.SaveToStream(aStream);
    aStream.Write('*)'#13#10, 4);
  end;
  Defs.SaveToStream(aStream);
end;

end.

