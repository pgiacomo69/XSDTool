unit uXSDParser;

interface
uses
  Classes,
  JanXMLParser2,
  uXSDobj;
{#BACKUP g:\proj5\delphi32\janxmlparser2.pas }

type
  tLogProcedure = procedure(const s: string) of object;
type
  tXSDParser = class
    FCurrentClass: tClassDef;
    FFilename: string;
    procedure Logout(const s: string);
  private
    FOnLogout: tLogProcedure;
    FClassDefs: tClassDefs;
    FxsdSchemaPrefix:String;
    function TranslateType(const sType: string): string;
    procedure parseRestriction(xRest: tJanXMLNode2; const sPref: string);
    procedure parseProperties(xElement, dn: tJanXMLNode2);
    procedure parseSimpleType(xElement, xSimple: tJanXMLNode2; bInClass:
      boolean);
    procedure parseSequence(dn: tJanXMLNode2; bInClass: boolean);
    procedure parseChoice(dn: tJanXMLNode2; bInClass: boolean);
    procedure parseComplextype(xElement, xComplex: tJanXMLNode2; bInClass:
      boolean = false);
    procedure parseSimpleContent(dn: tJanXMLNode2; bInClass: boolean);
    procedure parseAttribute(xAttribute: tJanXMLNode2);
    procedure parseElement(xElement: tJanXMLNode2; bInclass: boolean);
    procedure parseImport(xn: tJanXMLNode2);
    procedure parsecomplexContent(dn: tJanXMLNode2);
    procedure parseExtension(dn: tJanXMLNode2);
  public
    constructor Create(const aFilename: string);
    destructor Destroy; override;
    procedure parseSchema(xSchema: tJanXMLNode2);
    procedure SaveToStream(aStream: tStream);
    property OnLogout: tLogProcedure read FOnLogout write FOnLogout;
    property ClassDefs: tClassDefs read FClassDefs;
  end;

implementation
uses
  SysUtils,
  UXmlTools,
  mylib;

procedure tXSDParser.Logout(const s: string);
begin
  if Assigned(FOnLogout) then
    FOnLogout(s);
end;

function tXSDParser.TranslateType(const sType: string): string;
var
  ns: string;
  s: string;
  lType: string;
  lTypeNoNS: string;
  i: integer;
begin
  lType := sType;
  i := Pos(':', lType);
  if (i > 0) then
    lTypeNoNS := lType.Substring(i)
  else
    lTypeNoNS := lType;

  if (lType = tpdecimal) or (lTypeNoNS = tpdecimalNS) then
    result := dFloat
  else if (lType = tpcurrency) or (lTypeNoNS = tpcurrencyNS) then
    result := dFloat
  else if (lType = tpdouble) or (lTypeNoNS = tpdoubleNS) then
    result := dFloat
  else if (lType = tpstring) or (lTypeNoNS = tpstringNS) then
    result := dString
  else if (lType = tpNMTOKENS) or (lTypeNoNS = tpNMTOKENSNS) then
    result := dString
  else if (lType = tpinteger) or (lType = tpint) or (lTypeNoNS = tpintegerNS) or (lTypeNoNS = tpintNS)then
    result := dInteger
  else if (lType = tpboolean) or (lTypeNoNS = tpbooleanNS) then
    result := dBoolean
  else if (lType = tpdate) or (lTypeNoNS = tpdateNS) then
    result := dDate
  else if (lType = tptime) or (lTypeNoNS = tptimeNS) then
    result := dTime
  else if (lType = tpdatetime) or (lTypeNoNS = tpdatetimeNS) then
    result := dDateTime
  else if (lType = tpunsignedbyte) or (lTypeNoNS = tpunsignedbyteNS) then
    result := dbyte
  else if (lType = tpID) or (lTypeNoNS = tpIDNS) then
    result := dString
  else if (lType = tpGuid) then
    result := dsGUID
  else if (lType = tpIDREFS) or (lTypeNoNS = tpIDREFSNS) then
    result := dString
  else if (lType = tpTimeSpan) then
    result := dInteger
  else if (lType = tpLong) or (lTypeNoNS = tpLongNS) then
    result := dLong
  else if (lType = tpUnsignedLong) or (lTypeNoNS = tpUnsignedLongNS) then
    result := dLong
  else
  begin
    result := lType;
    if pos(':', lType) > 0 then
    begin
      ns := CmdSplit(lType, ':');
      s := FClassDefs.Includes.values[ns];
      if length(s) > 0 then
      begin
        ns := CmdSplit(s, '|'); // split off the namespace uri, have unit name
        result := 'u' + s + '.t' + lType;
      end
      else
        result := 'u' + ns + '.t' + lType
    end
    else
      result := 't' + lType;
  end;
end;

procedure tXSDParser.parseRestriction(xRest: tJanXMLNode2; const sPref: string);
var
  xEnum: tJanXMLNode2;
  sVal: string;
begin
  Logout('parseRestriction');
  xEnum := xRest.getChildByName(NSName(FxsdSchemaPrefix,xsdEnumeration));
  if Assigned(xEnum) then
    Logout('xEnum: ')
  else
    Logout('xEnum=NIL');
  while Assigned(xEnum) and (xEnum.name = NSName(FxsdSchemaPrefix,xsdEnumeration)) do
  begin
    sVal := xEnum.attribute['value'];
    Logout(':' + sVal);
    FClassDefs.AddConst(sPref, sVal);
    logout('AddConst ' + sPref + ',' + sVal);
    xEnum := xEnum.NextSibling;
  end;
end;

procedure tXSDParser.parseSimpleType(xElement, xSimple: tJanXMLNode2; bInClass:
  boolean);
var
  xRest: tJanXMLNode2;
  sElement: string;
  pt: string;
  p: tProperty;
  simple: boolean;
  sNs: string;
  iMax: integer;
  iMin: integer;
begin
  Logout('// parsesimpletype');
  if Assigned(xElement) then
  begin
    sNs := xElement.attribute[xsmaxOccurs];
    if sNs = xsMunbounded then
      iMax := cUnbounded
    else
      iMax := StrToIntDef(sNs, cScalar);
    iMin := StrToIntDef(xElement.attribute[xsminOccurs], 1)
  end
  else
  begin
    iMax := cScalar;
    iMin := 1;
  end;

  if Assigned(xElement) then
    sElement := xElement.attribute[xsename]
  else if Assigned(xSimple) then
    sElement := xSimple.attribute[xsename]
  else
    sElement := '';
  xRest := xSimple.getChildByName(NSName(FxsdSchemaPrefix,xsdrestriction));
  if assigned(xRest) then
  begin
    pt := xRest.attribute[xsRsBase];
    pt := TranslateType(pt);
    simple := true;
    parseRestriction(xRest, sElement);
  end
  else
  begin
    pt := 't' + sElement;
    simple := false;
  end;

  FClassDefs.AddOrdinal(sElement, pt);
  Logout('AddOrdinal ' + sElement + ',' + pt);
  if bInClass then
  begin
    p := tProperty.Create(sElement, pt, 'E', '', iMax, iMin, simple);
    FCurrentClass.Properties.AddObject(p.name, p);
    Logout('AddProperty ' + p.name);
  end;
end;

procedure tXSDParser.parseProperties(xElement: tJanXMLNode2; dn: tJanXMLNode2);
var
  xn: tJanXMLNode2;
  sType: string;
  sName: string;
  iMax: integer;
  sns: string;
begin // procedure parseProperties(dn: tJanXMLNode2);
  Logout('// parseproperties');

  sName := xElement.attribute[xsename];
  sNs := xElement.attribute[xsmaxOccurs];
  if sNs = xsMunbounded then
    iMax := cUnbounded
  else
    iMax := StrToIntDef(sNs, cScalar);

  xn := dn.getChildByName(NSName(FxsdSchemaPrefix,xsdrestriction));
  if assigned(xn) then
  begin
    sType := xn.attribute[xsRsBase];
    sType := TranslateType(sType);

    parseRestriction(xn, sType);
  end
  else
    sType := 't' + sName;
end; // procedure parseProperties(dn: tJanXMLNode2);

procedure tXSDParser.parseSequence(dn: tJanXMLNode2; bInClass: boolean);
var
  dn2: tJanXMLNode2;
  c: integer;
  i: integer;
begin
  Logout('// parseSequence');

  c := dn.nodes.count;
  for i := 0 to c - 1 do
  begin
    dn2 := tJanXMLNode2(dn.Nodes[i]);
    if dn2.name = NSName(FxsdSchemaPrefix,xsdElement) then
      parseElement(dn2, true)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdcomplexType) then
      parseComplextype(dn, dn2, bInClass)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdchoice) then
      parseChoice(dn2, bInClass)
    else
      Logout('// --- parseSequence.node: ' + dn2.attribute[xsename]);
  end;
end;

procedure tXSDParser.parseChoice(dn: tJanXMLNode2; bInClass: boolean);
var
  dn2: tJanXMLNode2;
  c: integer;
  i: integer;
begin
  Logout('// parseChoice');

  c := dn.nodes.count;
  for i := 0 to c - 1 do
  begin
    dn2 := tJanXMLNode2(dn.Nodes[i]);
    if dn2.name = NSName(FxsdSchemaPrefix,xsdsequence) then
      parseSequence(dn2, true)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdElement) then
      parseElement(dn2, true)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdcomplexType) then
      parseComplextype(dn, dn2, bInClass)
    else
      Logout('// --- parseChoice.node: ' + dn2.attribute[xsename]);
  end;
end;

procedure tXSDParser.parseExtension(dn: tJanXMLNode2);
begin
  FCurrentClass.IsExtensionOf := dn.attribute['base'];

end;

procedure tXSDParser.parsecomplexContent(dn: tJanXMLNode2);
var
  i: integer;
  dn2: TjanXMLNode2;
  Extname: string;
begin
  for i := 0 to dn.nodes.count - 1 do
  begin
    dn2 := tJanXMLNode2(dn.Nodes[i]);
    if dn2.name = NSName(FxsdSchemaPrefix,xsdExtension) then
      parseExtension(dn2)
//    else if dn2.name = xsrestriction then
//      parseRestriction(dn2)
    else
      Logout('// --- parseSequence.node: ' + dn2.attribute[xsename]);
  end;

end;


procedure tXSDParser.parseSimpleContent(dn: tJanXMLNode2;
  bInClass: boolean);
var
  xExt: tJanXMLNode2;
  pt: string;
  p: tProperty;
  c: integer;
  dn2: tJanXMLNode2;
begin
  Logout('// parse SimpleContent');
  xExt := dn.getChildByName(NSName(FxsdSchemaPrefix,xsdExtension));
  if assigned(xExt) then
  begin
    pt := xExt.attribute[xsRsBase];
    pt := TranslateType(pt);
    // we need to create default property "value" of the current declaration
    p := tProperty.Create('Value', pt, 'S', '', cScalar, 1, true);
    FCurrentClass.Properties.AddObject(p.name, p);

    for c := 0 to xExt.nodes.Count - 1 do
    begin
      dn2 := tJanXMLNode2(xExt.Nodes[c]);
      if dn2.name = NSName(FxsdSchemaPrefix,xsdattribute) then
        parseattribute(dn2)
      else if dn2.name = NSName(FxsdSchemaPrefix,xsdExtension) then
        parseExtension(dn2);


    end;
  end;
end;

procedure tXSDParser.parseComplextype(xElement, xComplex: tJanXMLNode2;
  bInClass:
  boolean = false);
var
  dn2: tJanXMLNode2;
  c: integer;
  i: integer;
  sName: string;
  sNs: string;
  iMax: integer;
  iMin: integer;
  old: tClassDef;
  p: tProperty;
  b: string;
begin
  Logout('// parseComplextype');
  c := xComplex.nodes.count;

  if bInClass then
    Logout('  (*');

  // complex type needs to create a class header
  if Assigned(xElement) then
  begin
    sName := xElement.attribute[xseName];
    sNs := xElement.attribute[xsmaxOccurs];
    imin := StrToIntDef(xElement.attribute[xsminOccurs], 1);
    b := 'E';
  end
  else
  begin
    sName := xComplex.attribute[xseName];
    sNs := xComplex.attribute[xsmaxOccurs];
    imin := StrToIntDef(xComplex.attribute[xsminOccurs], 1);
    b := 'A';
  end;
  if sNs = xsMunbounded then
    iMax := cUnbounded
  else
    iMax := StrToIntDef(sNs, cScalar);

  old := FCurrentClass;
  FCurrentClass := tClassDef.Create(sName);
  FClassDefs.AddObject(FCurrentClass.name, FCurrentClass);
  Logout('AddClass ' + FCurrentClass.Name);

  for i := 0 to c - 1 do
  begin
    dn2 := tJanXMLNode2(xComplex.Nodes[i]);
    if dn2.name = NSName(FxsdSchemaPrefix,xsdsequence) then
      parseSequence(dn2, bInClass)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdchoice) then
      parseChoice(dn2, bInClass)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdsimpleContent) then
      parseSimplecontent(dn2, bInClass)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdattribute) then
      parseattribute(dn2)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdcomplexContent) then
      parsecomplexcontent(dn2)
    else
      ;
  end;

  FCurrentClass := old;

  if bInClass then
  begin
    Logout('  *)');

    // we need to create a property of the current declaration
    p := tProperty.Create(sName, 'T' + sName, b, '', iMax, iMin, false);
    FCurrentClass.Properties.AddObject(p.name, p);
  end;
end;

procedure tXSDParser.parseAttribute(xAttribute: tJanXMLNode2);
var
  xn: tJanXMLnode2;
  sName: string;
  sType: string;
  p: tProperty;
  iMin: integer;
begin
  Logout('// parseAttribute');
  sName := xAttribute.attribute[xsename];
  sType := xAttribute.attribute[xsetype];
  if xAttribute.attribute[xsuse]='required' then
    iMin := 1
  else
    iMin := 0; // default optional
  if sType = '' then
  begin
    xn := xAttribute.getChildByName(NSName(FxsdSchemaPrefix,xsdrestriction), true);
    if assigned(xn) then
    begin
      sType := xn.attribute[xsRsBase];
      parseRestriction(xn, sName);
    end;
  end;
  sType := translateType(sType);

  p := tProperty.Create(sName, sType, 'A', '', cScalar, iMin, true);
  FCurrentClass.properties.AddObject(p.name, p);
end;

procedure tXSDParser.parseElement(xElement: tJanXMLNode2; bInClass: boolean);
var
  dn2: tJanXMLNode2;
  c: integer;
  i: integer;
  sElement: string;
  sType: string;
  sRef: string;
  sNs: string;
  iMax: integer;
  iMin: integer;
  old: tClassDef;
  p: tProperty;

  procedure ReferencedType;
  var
    p: tProperty;
    b: string;
    sns: string;
  begin
    // referenced type
    if pos(':', sRef) > 0 then // Namespace -> external reference ?
      sns := CmdSplit(sRef, ':');
    if sns = FClassDefs.NameSpacePrefix then
      b := 'E'
    else
      b := 'X';
    p := tProperty.Create(sRef, 'T' + sRef, b, sns, iMax, iMin, false);
    FCurrentClass.Properties.AddObject(p.name, p);
  end;

begin // procedure parseElement(dn: tJanXMLNode2);
  sElement := xElement.attribute[xsename];
  sType := xElement.attribute[xsetype];
  sRef := xElement.attribute[xseref];
  sNs := xElement.attribute[xsmaxOccurs];
  if sNs = xsMunbounded then
    iMax := cUnbounded
  else
    iMax := StrToIntDef(sNs, cScalar);
  iMin := StrToIntDef(xElement.attribute[xsminOccurs], 1);

  Logout(Format('// parseElement: %s(%s)%s [%d,%d]',
    [sElement, sType, sRef, iMin, iMax]));

  dn2 := xElement.getChildByName(NSName(FxsdSchemaPrefix,xsdSimpleType));
  if assigned(dn2) then
    parseSimpleType(xElement, dn2, bInClass)
  else
  begin
    dn2 := xElement.getChildByName(NSName(FxsdSchemaPrefix,xsdcomplexType));
    if assigned(dn2) then
      parseComplextype(xElement, dn2, bInClass)
    else
    begin
      if (sElement = '') and (sRef <> '') then
        ReferencedType
      else
      begin
        if not bInClass then
        begin
          Logout('// standallone --------------');
          if sType <> '' then
          begin
            sType := TranslateType(sType);
            FClassDefs.AddOrdinal(sElement, sType);
            Logout('AddOrdinal ' + sElement + ',' + sType);
          end
          else
          begin
            old := FCurrentClass;
            FCurrentClass := tClassDef.Create(sElement);
            FClassDefs.AddObject(FCurrentClass.Name, FCurrentClass);
            Logout('AddClass ' + FCurrentClass.name);

            c := xElement.nodes.count;
            for i := 0 to c - 1 do
            begin
              dn2 := tJanXMLNode2(xElement.Nodes[i]);
              if dn2.name = NSName(FxsdSchemaPrefix,xsdcomplexType) then
                parseComplextype(xElement, dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdsequence) then
                parseSequence(dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdchoice) then
                parseChoice(dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdSimpleType) then
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdattribute) then
                parseAttribute(dn2)
                  ;
              //parseProperties(sElement, dn2);
            end;
            FCurrentClass := old;
          end;
        end // if bStandallone
        else
        begin
          Logout('// in class --------------');
          if sType <> '' then
          begin
            sType := TranslateType(sType);

            p := tProperty.Create(sElement, sType, 'E', '', iMax, iMin, true);
            FCurrentClass.Properties.AddObject(p.name, p);
          end
          else
          begin
            Logout('//   parsing nodelist');
            c := xElement.nodes.count;
            for i := 0 to c - 1 do
            begin
              dn2 := tJanXMLNode2(xElement.Nodes[i]);
              if dn2.name = NSName(FxsdSchemaPrefix,xsdcomplexType) then
                parseComplextype(xElement, dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdsequence) then
                parseSequence(dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdchoice) then
                parseChoice(dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdSimpleType) then
                parseSimpleType(xElement, dn2, bInClass)
              else if dn2.name = NSName(FxsdSchemaPrefix,xsdattribute) then
                parseAttribute(dn2)
                  ;
              //parseProperties(sElement, dn2);
            end;
          end;
        end; // if bStandallone .. else
      end; // if referenced type .. else
    end; // if complextype .. else
  end; // procedure parseElement(dn: tJanXMLNode2);
end;

procedure tXSDParser.ParseImport(xn: tJanXMLNode2);
var
  sUnit: string;
  sNs: string;
  s: string;
  i: integer;
begin
  sUnit := xn.attribute['schemaLocation'];
  sNs := xn.attribute['namespace'];
  sUnit := ExtractFileName(ExpandFileName(sUnit));
  sUnit := ChangeFileExt(sUnit, '');
  FClassDefs.AddUses(sUnit);
  Logout('AddUses ' + sUnit);
  // find namespace in includes and add schemalocation
  for i := 0 to FClassDefs.Includes.Count - 1 do
  begin
    s := FClassDefs.Includes.Strings[i];
    if pos('|', s) = 0 then // avoid duplication
      if pos('=' + sNs, s) > 0 then
      begin
        s := s + '|' + sUnit;
        FClassDefs.Includes.Strings[i] := s;
        break;
      end;
  end;
end;

procedure tXSDParser.parseSchema(xSchema: tJanXMLNode2);

procedure SetCOmplexProperties;
var i,j:integer;
    c:tClassDef;
    p:tProperty;
    n:integer;
    t:String;
begin
for i:=0 to  ClassDefs.Count-1 do
    begin

     if assigned(classdefs.objects[i]) then

      begin

        if classdefs.objects[i] is tclassdef then
         begin
          c:=tclassdef(classdefs.objects[i]);
          for j:=0 to c.properties.Count-1 do
          begin
            if c.Properties.Objects[j]<>nil then
             begin
              if c.Properties.Objects[j] is tproperty then
               begin
                p:=tproperty(c.Properties.Objects[j]);
                t:=p._Type;
                if t<>'' then
                 begin
                  if t[1]='t' then
                    begin
                     delete(t,1,1);
                     n:=0;
                     if ClassDefs.indexof(t)>=0 then
                      p.SetIsComplex;
                    end;
                 end;
               end;
             end;

          end;
         end;
      end;
    end;

end;

var
  c: integer;
  i: integer;
  dn2: tJanXMLNode2;
  tns: string;
  sa: string;
  temp: string;
  attr:String;
begin // procedure parseSchema(dn:tJanXMLNode2)
  FClassDefs.Clear;
  FCurrentClass := nil;

  temp := xSchema.attribute['elementFormDefault'];
  FClassDefs.elementsqualified := temp = cqualified;

  temp := xSchema.attribute['attributeFormDefault'];
  FClassDefs.attributesqualified := temp = cqualified;
  FxsdSchemaPrefix:='';
  tns := xSchema.attribute['targetNamespace'];
  if tns <> '' then
  begin
    FClassDefs.targetNameSpace := tns;
    // now find the namespace prefix xmlns:...="tns"
    for i := 0 to xSchema.attributecount - 1 do
    begin
      sa := xSchema.attributename[i];
      attr:=xSchema.attribute[i];
      if pos('xmlns:', sa) = 1 then
      begin
        temp := copy(sa, 7, length(sa));
        if attr=xsdSchemaURI then
         FxsdSchemaPrefix:=temp;
        if tns = attr then
          FClassDefs.NamespacePrefix := temp
        else
        begin
          FClassDefs.AddInclude(temp, attr);
          Logout('AddInclude ' + temp + ',' + attr);
        end;
      end;
    end;
  end;

  c := xSchema.nodes.count;
  for i := 0 to c - 1 do
  begin
    dn2 := TjanXMLNode2(xSchema.Nodes[i]);
    Logout('// xs:schema ' + dn2.name + ' ' + dn2.text);
{ TODO : Add AttributeGroup handling }
    if dn2.name = NSName(FxsdSchemaPrefix,xsdElement) then
      parseElement(dn2, false)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdcomplexType) then
      parseComplextype(nil, dn2)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdimport) then
      parseImport(dn2)
    else if dn2.name = NSName(FxsdSchemaPrefix,xsdSimpleType) then
      parseSimpleType(nil, dn2, false)
        ;
  end;
  SetComplexProperties;
end; // procedure parseSchema(dn:tJanXMLNode2)

constructor tXSDParser.Create(const aFilename: string);
begin
  FClassDefs := tClassDefs.Create;
  FFilename := aFilename;
end;

destructor tXSDParser.Destroy;
begin
  FClassDefs.Free;
  inherited;
end;

procedure tXSDParser.SaveToStream(aStream: tStream);
begin
  FClassDefs.XSDFilename := FFilename;
  if FileExists(FFilename) then
    FClassDefs.XSDTimeStamp := FormatDateTime('c',
      FileDateToDateTime(FileAge(FFilename)));
  FClassDefs.SaveToStream(aStream);
end;

end.