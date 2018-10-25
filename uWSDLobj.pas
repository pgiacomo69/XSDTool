unit uWSDLobj;

interface
uses
  Classes,
  uXMLTools;

type
  tLogprocedure = procedure(const s: string) of object;

type
  tParamDef = class
  private
    FType: string;
    FName: string;
    FElement: string;
  public
    constructor Create(const aName, aType, aElement: string);
    destructor destroy; override;
    property Name: string read FName;
    property _Type: string read FType;
    property Element: string read FElement;
  end;

type
  tMessageDef = class
  private
    FName: string;
    FParams: TStringlist;
  published
    constructor Create(const aName: string);
    destructor destroy; override;
    property Name: string read FName;
    property Params: TStringList read FParams;
  end;

type
  tOperationDef = class
  private
    FName: string;
    FResultType: string;
    FParamType: string;
  public
    constructor Create(const aName: string);
    destructor destroy; override;
    property Name: string read FName;
    property ParamType: string read FParamType write FParamType;
    property ResultType: string read FResultType write FResultType;
  end;

type
  tPortDef = class
  private
    FName: string;
    FOperations: TStringlist;
  public
    constructor create(const aName: string);
    destructor destroy; override;
    property Name: string read FName;
    property Operations: TStringlist read FOperations;
  end;

type
  tBindingDef = class
  private
    FAction: string;
    FName: string;
  public
    constructor create(const aName, aAction: string);
    destructor destroy; override;
    property Name: string read FName;
    property Action: string read FAction;
  end;

type
  tServiceDef = class
  private
    FBinding: string;
    FLocation: string;
  public
    constructor create(const aBinding, aLocation: string);
    destructor destroy; override;
    property Binding: string read FBinding;
    property Location: string read FLocation;
  end;

type
  tWebServiceDef = class(TStringlist)
  private
    FName: string;
    FUses: tStringlist;
    FIncludes: tStringlist;
    FMessages: TStringlist;
    FBindings: TStringlist ;
    FServices: TStringlist ;
    FTargetNamespace: string;
    FNamespacePrefix: string;
    function FindMessage(const MsgName: string): tMessageDef;
    function TranslateType(const sTypeIn: string): string;
    function MessageType(const MsgName: string): string;
    function ParamNameOf(const MsgName:string):string;
  public
    constructor Create(const aName: string);
    destructor Destroy; override;
    procedure AddUses(const aUnit: string);
    procedure AddInclude(const aAlias, aPath: string);
    procedure SaveToStream(aStream: tStream); override;
    property Messages: TStringlist read FMessages;
    property Bindings: TStringlist read FBindings;
    property Services: TStringlist read FServices;
    property Name: string read FName;
    property TargetNamespace: string read FTargetNamespace write
      FTargetNamespace;
    property NamespacePrefix: string read FNamespacePrefix write
      FNamespacePrefix;
  end;

var
  OnLogout: tLogProcedure = nil;

implementation
uses
  SysUtils,
  mylib;

procedure Logout(const s: string);
begin
  if Assigned(OnLogout) then
    OnLogout(s);
end;

{ tOperationDef }

constructor tOperationDef.Create(const aName: string);
begin
  FName := aName;
end;

destructor tOperationDef.destroy;
begin
  inherited;
end;

{ tParamDef }

constructor tParamDef.Create(const aName, aType, aElement: string);
begin
  FName := aName;
  FType := aType;
  FElement := aElement;
end;

destructor tParamDef.destroy;
begin
  inherited;
end;

{ tPortDef }

constructor tPortDef.create(const aName: string);
begin
  FName := aName;
  FOperations := TStringlist.create(True);
end;

destructor tPortDef.destroy;
begin
  FOperations.Free;
  inherited;
end;

{ tWebServiceDef }

procedure tWebServiceDef.AddInclude(const aAlias, aPath: string);
begin
  FIncludes.Add(aAlias + '=' + aPath);
end;

procedure tWebServiceDef.AddUses(const aUnit: string);
begin
  FUses.Add(aUnit);
end;

constructor tWebServiceDef.Create(const aName: string);
begin
  inherited Create(True);
  // define a web service
  FName := aName;
  FUses := tStringlist.Create;
  FIncludes := tStringlist.Create;
  FMessages := TStringlist.create(True);
  FBindings := TStringlist.create(True);
  FServices := TStringlist.create(True);
end;

destructor tWebServiceDef.Destroy;
begin
  FServices.Free;
  FBindings.Free;
  FMessages.Free;
  FIncludes.Free;
  FUses.Free;
  inherited;
end;

function tWebServiceDef.FindMessage(const MsgName: string): tMessageDef;
var
  aName: string;
  aPrefix: string;
  i: integer;
  m: tMessageDef;
begin
  result := nil;

  aName := MsgName;
  if pos(':', aName) > 0 then
    aPrefix := CmdSplit(aName, ':');

  for i := 0 to FMessages.Count - 1 do
  begin
    m := tMessageDef(FMessages.Objects[i]);
    if m.name = aName then
    begin
      // found message with required name
      result := m;
      exit;
    end;
  end;
end;

function tWebServiceDef.MessageType(const MsgName: string): string;
var
  m: tMessageDef;
  pa: tParamDef;
begin
  m := FindMessage(MsgName);
  if Assigned(m) then
  begin
    // found message with required name
    if m.Params.Count > 1 then // we have a message class
      result := 't' + MsgName
    else if m.Params.Count = 1 then // one parameter only
    begin
      pa := tParamDef(m.Params.Objects[0]);
      if pa._type = '' then
        result := TranslateType(pa.Element) //
      else
        result := TranslateType(pa._type); // local type
    end
    else // no params ?
      result := 't' + MsgName;
  end;
end;

function tWebServiceDef.ParamNameOf(const MsgName:string):string;
var
  m: tMessageDef;
  pa: tParamDef;
begin
  m := FindMessage(MsgName);
  if Assigned(m) then
  begin
    // found message with required name
    if m.Params.Count > 1 then // we have a message class
      result := 't' + MsgName
    else if m.Params.Count = 1 then // one parameter only
    begin
      pa := tParamDef(m.Params.Objects[0]);
      result := pa.Element;
    end
    else // no params ?
      result := 't' + MsgName;
  end;
end;

procedure tWebServiceDef.SaveToStream(aStream: tStream);

  procedure outline(const s: string);
  const
    CRLF = #13#10;
  begin
    aStream.Write(pChar(s)^, length(s));
    aStream.Write(CRLF, 2);
  end;

var
  i: integer;
  p: tPortDef;
  j: integer;
  o: tOperationdef;
  m: tMessageDef;
  pa: tParamDef;
  i_b: integer;
  b: tBindingDef;
  i_s: integer;
  sv: tServiceDef;
  stype: string;
begin
  outline('unit u' + ChangeFileExt(ExtractFileName(Name), '') + ';');
  outline('');
  outline('Interface');
  outline('uses');
  for i := 0 to FUses.Count - 1 do
    outline('  u' + FUses[i] + ',');
  outline('  uXMLTools,');
  outline('  uWSDLtool;');
  outline('');
  outline('// targetNameSpace: ' + targetNameSpace);
  outline('// NameSpacePrefix: ' + NameSpacePrefix);
  // outline('// Date of Schema : ' + FXSDTimeStamp);
  outline('// Translationdate: ' + FormatDateTime('c', Now));
  outline('//');
  for i := 0 to FIncludes.Count - 1 do
    outline('// includes: ' + FIncludes[i]);
  outline('');

  // define messages
  for i := 0 to FMessages.Count - 1 do
  begin
    m := tMessageDef(FMessages.Objects[i]);
    outline('type');
    if m.Params.Count > 1 then
    begin
      outline('  t' + m.name + ' = class');
      for j := 0 to m.Params.Count - 1 do
      begin
        pa := tParamDef(m.Params.Objects[j]);
        outline('  property ' + pa.name + ':' + TranslateType(pa._type));
      end;
      outline('end;');
      outline('');
    end
    else if m.Params.Count = 1 then
    begin
      pa := tParamDef(m.Params.Objects[0]);
      if pa._type = '' then
        outline('  t' + m.name + ' = ' + TranslateType(pa.Element) + ';')
      else
        outline('  t' + m.name + ' = ' + TranslateType(pa._type) + ';');
    end;
  end;
  outline('');

  // write webservice definition
  for i := 0 to Count - 1 do
  begin
    p := tPortDef(Objects[i]);
    outline('type');
    outline('  t' + p.Name + ' = class(tWebServiceInterface)');
    for j := 0 to p.Operations.Count - 1 do
    begin
      o := tOperationDef(p.Operations.Objects[j]);
      outline('    function ' + o.Name + '(DataIn:' +
        MessageType(o.ParamType) + '):'
        + MessageType(o.ResultType) + ';');
    end;
    outline('  end;');
    outline('');
  end;

  outline('Implementation');
  outline('uses');
  outline('  Sysutils,');
  outline('  uSoapEnvelope,');
  outline('  JanXMLParser2;');
  outline('');

  for i := 0 to Count - 1 do // PortDefinitions -> functions
  begin
    p := tPortDef(Objects[i]);
    for j := 0 to p.Operations.Count - 1 do
    begin
      o := tOperationDef(p.Operations.Objects[j]);
      outline('function t' + p.Name + '.' + o.Name + '(DataIn:' +
        MessageType(o.ParamType) + '):' + MessageType(o.ResultType) + ';');

      if Bindings.Count > 0 then
      begin
        outline('const');
        for i_b := 0 to Bindings.Count - 1 do
        begin
          b := tBindingDef(Bindings.Objects[i_b]);
          if b.name = o.name then
          begin
            outline('  defAction = ''' + b.Action + ''';');
            for i_s := 0 to Services.Count - 1 do
            begin
              sv := tServiceDef(Services.Objects[i_s]);
              outline('  defSoapURL = ''' + sv.Location + ''';');
            end;
          end;
        end; // for ib := 0 to Bindings.Count - 1 do
      end;

      outline('var');
      outline('  request: tJanXMLNode2;');
      outline('  doc: tJanXMLParser2;');
      outline('  xn: tJanXMLNode2;');
      outline('  Soap: tSoapEnvelope;');
      outline('begin');
      outline('  result := NIL;');
      outline('  if soapURL='''' then');
      outline('    soapURL := defSoapURL;');
      outline('');
      outline('  request := tJanXMLNode2.Create;');
      // test for ordinal types
      sType := MessageType(o.ParamType);
      if  (sType = 'string') or (sType = 'sGUID') then
      begin
        outline('  request.name := ''' + NamePart(ParamNameOf(o.ParamType)) + ''';');
        outline('  request.text := DataIn;');
        outline('  request.attribute[''xmlns''] := '
          + MessageType(o.ResultType) + '._nsURI_;');
      end
      else if (sType = 'integer') or (sType='int64') or (sType='byte') then
      begin
        outline('  request.name := ''' + ParamNameOf(o.ParamType) + ''';');
        outline('  request.text := IntToStr(DataIn);');
      end
      else if (sType='extended') or (sType='real') then
      begin
        outline('  request.name := ''' + ParamNameOf(o.ParamType) + ''';');
        outline('  request.text := FloatToStr(DataIn);');
      end
      else if (sType='tDate') then
      begin
        outline('  request.name := ''' + ParamNameOf(o.ParamType) + ''';');
        outline('  request.text := DateToXMLDatetime(DataIn);');
      end
      else if (sType='tTime') then
      begin
        outline('  request.name := ''' + ParamNameOf(o.ParamType) + ''';');
        outline('  request.text := TimeToXMLDatetime(DataIn);');
      end
      else if (sType='tDateTime') then
      begin
        outline('  request.name := ''' + ParamNameOf(o.ParamType) + ''';');
        outline('  request.text := DateTimeToXMLDatetime(DataIn);');
      end
      else // must be a complex type
      begin
        outline('  DataIn.Save(request)');
        outline('  request.attribute[''xmlns''] := DataIn._nsURI_;');
      end;
      outline('  Soap := tSoapEnvelope.Create;');
      outline('  Soap.SetMessageNode(request); // request is consumed here!!!');
      outline('  Soap.ServerAddress := soapURL;');
      outline('  Soap.SoapAction := defAction;');
      outline('  Soap.Username := Username;');
      outline('  Soap.Password := Password;');
      outline('  Soap.Send;');
      outline('  if Soap.Result = 200 then');
      outline('  begin');
      outline('    doc := tJanXMLParser2.Create;');
      outline('    doc.xml := Soap.ResultData;');
      outline('    Logout(Soap.ResultData);');
      outline('    xn := doc.getChildByName(''Body'', true); // get the soap body');
      outline('    if assigned(xn) then');
      outline('    begin');
      outline('      xn := xn.FirstChild; // this is our result type');
      outline('      if assigned(xn) then');
      outline('        result := ' + MessageType(o.ResultType) +
        '.Create(xn);');
      outline('    end;');
      outline('    doc.free;');
      outline('  end');
      outline('  else');
      outline('    Logout(''Result: '' + IntToStr(Soap.Result));');
      outline('  Soap.Free');
      outline('end;');
      outline('');
    end;
  end;
  outline('end.');
end;

function tWebServiceDef.TranslateType(const sTypeIn: string): string;
var
  p: integer;
  m: tMessageDef;
  pa: tParamDef;
  sType: string;
  sAlias: string;
  sUnit: string;
  sPas: string;
  stm: tFileStream;
begin
  logout('translate type: ' + sTypeIn);
  p := pos(':', sTypeIn);
  if p > 0 then
  begin
    sType := copy(sTypeIn, p + 1, length(sTypeIn));
    sAlias := copy(sTypeIn, 1, p - 1);
  end
  else
    sType := sTypeIn;

  if sAlias <> '' then
  begin
    // internal alias
    if sAlias = NamespacePrefix then
      result := 't' + sType
    else
    begin
      Logout('  find unit');
      // find the unit that belongs to the alias
      sUnit := FIncludes.Values[sAlias];
      if sUnit <> '' then
      begin
        logout('  unit=' + sunit);
        p := LastDelimiter('/', sUnit);
        if p > 0 then
          system.delete(sUnit, 1, p);
        sUnit := ChangeFileExt(sUnit, '');
        result := 'u' + sUnit + '.t' + sType;
        // now we should have a look into the unit to find out
        // if it is a class type or a simple one, and in that case
        // we need the simple type.
        sPas := 'u' + sUnit + '.pas'; // default translation
        logout('  lookup ' + sPas);
        if FileExists(ExtractFilePath(FName) + sPas) then
        begin
          logout('  found unit');
          stm := tFileStream.Create(ExtractFilePath(FName) + sPas, fmOpenRead);
          SetLength(sPas, stm.size);
          stm.Read(pChar(sPas)^, stm.size);
          p := pos('t' + sType + ' ', sPas);
          if p > 0 then
          begin
            system.Delete(sPas, 1, p - 1); // 'txxxx = zzzz....'
            sPas := CmdSplit(sPas, CR);
            logout(sPas);
            sUnit := CmdSplit(sPas, '=');
            sUnit := StrSplit(sPas);
            if pos('class', sUnit) <> 1 then
              result := CmdSplit(sUnit, ';');
          end
          else
            logout(' type not in unit');
          stm.Free;
        end;
      end
      else // can not find it - some kind of error
        result := '(' + sAlias + ')' + '.t' + sType;
    end
  end
  else
    result := 't' + sType;

  for p := 0 to FMessages.Count - 1 do
  begin
    m := tMessageDef(FMessages.Objects[p]);
    if sType = m.name then
    begin
      if m.Params.Count = 1 then
      begin
        pa := tParamDef(m.Params.Objects[0]);
        if pa._Type = '' then
          result := 't' + pa.Element
        else
          result := 't' + pa._Type;
      end
      else
        result := 't' + m.Name;
      break;
    end
  end;
end;

{ tMessageDef }

constructor tMessageDef.Create(const aName: string);
begin
  FName := aName;
  FParams := TStringlist.Create(True);
end;

destructor tMessageDef.destroy;
begin
  FParams.Free;
  inherited;
end;

{ tBindingDef }

constructor tBindingDef.create(const aName, aAction: string);
begin
  FName := aName;
  FAction := aAction;
end;

destructor tBindingDef.destroy;
begin
  inherited;
end;

{ tServiceDef }

constructor tServiceDef.create(const aBinding, aLocation: string);
begin
  FBinding := aBinding;
  FLocation := aLocation;
end;

destructor tServiceDef.destroy;
begin
  inherited;
end;

end.