unit uXSDobj;

interface
uses
  Classes,
  uXMLTools;
{#BACKUP g:\proj5\delphi32\uxmlTools.pas }


const
  cqualified = 'qualified';
  cunqualified = 'unqualified';

type

  tPropertyType=(ptSimple,ptComplex,ptEnum);
  tClassDefs=class;
  TWriteClasses=Procedure(classdef:tClassDefs;aStream: tStream);
  tProperty = class
  private
    FBase: string;
    FType: string;
    FName: string;
    FNameSpace: string;
    FMaxOccurs: integer;
    FPropertyType: tPropertyType;
    FMinOccurs: integer;
    function GetIsList: boolean;
    function GetIsOptional: boolean;
  public
    constructor Create(const aName, aType, aBase, aNSpc: string;
      aMax, aMin: integer; bPropertyType: tPropertyType);
    procedure setPropertyType(avalue:tPropertyType);
    property Name: string read FName;
    property _Type: string read FType write FType;
    property Base: string read FBase;
    property NameSpace: string read FNameSpace write FNameSpace;
    property maxOccurs: integer read FMaxOccurs;
    property minOccurs: integer read FMinOccurs;
    property PropertyType: tPropertyType read FPropertyType;
    property IsOptional: boolean read GetIsOptional;
    property IsList: boolean read GetIsList;
  end;


  tClassDef = class
  private
    FName: string;
    FProperties: TStringlist;
    FIsExtensionOf: string;
  public
    constructor Create(const aName: string);
    destructor Destroy; override;
    function NumAttributeProperties: integer;
    function NumElementProperties: integer;
    property Properties: TStringList read FProperties;
    property Name: string read FName;
    property IsExtensionOf: string read FIsExtensionOf write FIsExtensionOf;
  end;


  tEnumElement = class
  private
    FValue: string;
    FDocumentation: String;
  public
    constructor Create(const aValue,aDocumentation: string);
    property Value: String read FValue;
    property Documentation: String read FDocumentation;
  end;


  tEnumDef = class
  private
    FName: string;
    FNullValue: string;
    FNullValueName: string;
    FNullValueDoc: string;

    FElements: TStringList;
    fDocumented:Boolean;

  public
    constructor Create(const aName: string);
    destructor Destroy; override;
    function AddElement(const aValue,aDocumentation: string):TEnumElement;
    property Elements: TStringList read FElements;
    property Name: string read FName;
    property Documented:Boolean read fDocumented;
    property NullValue: string read FNullValue ;
    property NullValueName: string read FNullValueName;
    property NullValueDoc: string read FNullValueDoc;


  end;



  tClassDefs = class(TStringList)
  private
    FOrdinals: tStringlist;
    FEnums: tStringlist;
    FConsts: tStringlist;
    FUses: tStringlist;
    FIncludes: tStringlist;
    FbDebug: boolean;
    FtargetNameSpace: string;
    FNameSpacePrefix: string;
    Felementsqualified: boolean;
    Fattributesqualified: boolean;
    FXSDTimestamp: string;
    FXSDFilename: string;

  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure SortClasses;
    procedure AddUses(const aUnit: string);
    procedure AddOrdinal(const sNewType, sBasicType: string);
    procedure AddConst(const sPrefix, sValue: string);
    Function  AddEnum(const sName: string):tEnumDef;
    procedure AddInclude(const sAlias, sNamespace: string);
    procedure SaveToStream(aStream: tStream);
    //
    property Ordinals: tStringlist read FOrdinals; //  write FOrdinals;
    property Enums: tStringlist read FEnums; //  write FOrdinals;
    property Usess: tStringlist read FUses; //  write FOrdinals;
    property Consts: tStringlist read FConsts; //  write FConsts;
    property Includes: tStringlist read FIncludes;
    property bDebug: boolean read FbDebug write FbDebug;
    property targetNameSpace: string read FtargetNameSpace write
      FtargetNameSpace;
    property NameSpacePrefix: string read FNameSpacePrefix write
      FNameSpacePrefix;
    property elementsqualified: boolean read Felementsqualified write
      Felementsqualified;
    property attributesqualified: boolean read Fattributesqualified write
      Fattributesqualified;
    property XSDTimestamp: string read FXSDTimestamp write FXSDTimestamp;
    property XSDFilename: string read FXSDFilename write FXSDFilename;
  end;

{(*}
const
  xsdSchemaURI     = 'http://www.w3.org/2001/XMLSchema';
  xsdSchema        = 'schema';
  xsdElement        = 'element';
  xsdImport         = 'import';
  xsdAttribute      = 'attribute';
  xsdSequence       = 'sequence';
  xsdComplexType    = 'complexType';
  xsdSimpleType     = 'simpleType';
  xsdSimpleContent  = 'simpleContent';
  xsdComplexContent = 'complexContent';
  xsdExtension      = 'extension';
  xsdRestriction    = 'restriction';
  xsdEnumeration    = 'enumeration';
  xsdAnnotation     = 'annotation';
  xsdDocumentation  = 'documentation';
  xsdchoice         = 'choice';
  xsdeuse           = 'use';
 (* xsSchema         = 'schema';
  xsElement        = 'element';
  xsImport         = 'import';
  xsAttribute      = 'attribute';
  xsSequence       = 'sequence';
  xsComplexType    = 'complexType';
  xsSimpleType     = 'simpleType';
  xsSimpleContent  = 'simpleContent';
  xsComplexContent  = 'complexContent';
  xsExtension      = 'extension';
  xsRestriction    = 'restriction';
  xsEnumeration    = 'enumeration';
  xschoice         = 'choice';
  xseuse           = 'use'; *)
  xseName          = 'name';
  xseType          = 'type';
  xseRef           = 'ref';
  xsRsBase         = 'base';
  xsminoccurs      = 'minOccurs';
  xsmaxoccurs      = 'maxOccurs';
  xsmunbounded     = 'unbounded';
  xsuse            = 'use';

const // xml datatypes
  tpString       = 'xs:string';
  tpDecimal      = 'xs:decimal';
  tpCurrency     = 'xs:currency';
  tpdouble       = 'xs:double';
  tpInteger      = 'xs:integer';
  tpInt          = 'xs:int';
  tpUnsignedLong = 'xs:unsignedLong';
  tpLong         = 'xs:long';
  tpboolean      = 'xs:boolean';
  tpdate         = 'xs:date';
  tptime         = 'xs:time';
  tpdatetime     = 'xs:dateTime';
  tpunsignedbyte = 'xs:unsignedByte';
  tpId           = 'xs:ID';
  tpIdRefs       = 'xs:IDREFS';
  tpNMTOKENS     = 'xs:NMTOKENS';

  tpStringNS       = 'string';
  tpDecimalNS      = 'decimal';
  tpCurrencyNS     = 'currency';
  tpdoubleNS       = 'double';
  tpIntegerNS      = 'integer';
  tpIntNS          = 'int';
  tpUnsignedLongNS = 'unsignedLong';
  tpLongNS         = 'long';
  tpbooleanNS      = 'boolean';
  tpdateNS         = 'date';
  tptimeNS         = 'time';
  tpdatetimeNS     = 'dateTime';
  tpunsignedbyteNS = 'unsignedByte';
  tpIdNS           = 'ID';
  tpIdRefsNS       = 'IDREFS';
  tpNMTOKENSNS     = 'NMTOKENS';


  tpGUID         = 'msnettypes:guid';
  tptimespan     = 'msnettypes:timespan';

const // delphi types
  dString   = 'string';
  dsGUID    = 'sGUID';
  dFloat    = 'extended';
  dInteger  = 'integer';
  dLong     = 'int64';
  dboolean  = 'boolean';
  dDate     = 'TDate';
  dTime     = 'TTime';
  dDateTime = 'TDateTime';
  dbyte     = 'byte';

const
  cunbounded = -2;
  cscalar    = 1;
{*)}

implementation
uses
  SysUtils,
  Mylib;

const
  tabConst = 'const';
  tabType = 'type';
  tabClass = '  ';
  tabPrivate = '  private';
  tabPublic = '  public';
  tabConstrN = '    constructor Create(aRoot:tJanXMLNode2); overload;';
  tabConstrC = '    constructor Create; overload;';
  tabDestr = '    destructor Destroy; override;';
  tabSave = '    procedure Save(aNode:tJanXMLNode2);';
  tabProp = '    property ';
  tabF = '    F';
  tabC = '  c';
  tabt = '  t';
  tabEnd = '  end;';

function CheckPascalReserved(const aPropName: string): string;
const
  sReserved = '-type-unit-program-uses-';
var
  s: string;
begin
  s := '-' + lowercase(aPropName) + '-';
  if pos(s, sReserved) > 0 then
    result := '_' + aPropName
  else
    result := aPropName;
end;

function RemoveSpaces(const aString: string): string;
const
  Alpha = ['A'..'Z', 'a'..'z', '_'];
  AlphaNumeric = Alpha + ['0'..'9'];
var
  i: integer;
begin
  // IsValidIdent
  result := trim(aString);
  for i := length(result) downto 1 do
  begin
    if i = 1 then
    begin
      if not (result[i] in Alpha) then
        system.delete(result, i, 1);
    end
    else
    begin
      if not (result[i] in AlphaNumeric) then
        system.delete(result, i, 1);
    end;
  end;
end;

{ tClassDef }

constructor tClassDef.Create(const aName: string);
begin
  FName := aName;
  FProperties := TStringlist.Create(True);
end;

destructor tClassDef.destroy;
begin
  FProperties.Free;
  inherited;
end;


constructor tEnumElement.Create(const aValue,aDocumentation: string);
begin
  FValue:=aValue;
  FDocumentation:=aDocumentation;
end;


constructor tEnumDef.Create(const aName: string);
begin
  FName := aName;
  fDocumented:=False;
  FElements := TStringlist.Create(True);
  fnullvalue:='_NullValue_';
  fnullvalueName:='te'+fname+'_NullValue_';
  FNullValueDoc:=fname+ ' Null';
  FElements.AddObject(fnullvalueName,tEnumElement.Create(fnullvalue,fnullvalueDoc));

end;

destructor tEnumDef.Destroy;
begin
  FElements.Free;
  inherited;
end;
function tEnumDef.AddElement(const aValue,aDocumentation: string):TEnumElement;
begin

 result:=tEnumElement.Create(aValue,aDocumentation);
 FElements.AddObject('te'+fname+Avalue,result);
 fDocumented:=fDocumented or (aDocumentation<>'');
end;


function tClassDef.NumAttributeProperties: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to Properties.Count - 1 do
    if tProperty(Properties.Objects[i]).Base = 'A' then
      inc(result);
end;

function tClassDef.NumElementProperties: integer;
begin
  result := Properties.Count - NumAttributeProperties;
end;

{ tProperty }

constructor tProperty.Create(const aName, aType, aBase, aNSpc: string;
  aMax, aMin: integer; bPropertyType: tPropertyType);
begin
  FName := aName;
  FType := aType;
  FBase := aBase;
  FNameSpace := aNSpc;
  FMaxOccurs := aMax;
  FMinOccurs := aMin;
  FPropertyType := bPropertyType;
end;

function tProperty.GetIsList: boolean;
begin
  result := (maxOccurs > 1) or (maxOccurs = cUnbounded);
end;

function tProperty.GetIsOptional: boolean;
begin
  result := minOccurs = 0;
end;

procedure tProperty.setPropertyType(avalue:tPropertyType);

begin
 FPropertyType:=aValue;
end;

{ tClassDefs }

constructor tClassDefs.Create;
begin
  inherited;
  OwnsObjects := True;
  FOrdinals := tStringList.Create;
  FEnums := tStringList.Create;
  FUses := tStringlist.Create;
  FUses.Sorted := true;
  FUses.Duplicates := dupIgnore;
  FConsts := tStringlist.Create;
  FIncludes := tStringlist.Create;
end;

destructor tClassDefs.Destroy;
begin
  inherited;
  FEnums.Free;
  FOrdinals.Free;
  FUses.Free;
  FConsts.Free;
  FIncludes.Free;
end;

procedure tClassDefs.Clear;
begin
  FOrdinals.Clear;
  FUses.Clear;
  FConsts.Clear;
  FTargetNameSpace := '';
  FNameSpacePrefix := '';

  inherited;
end;

procedure tClassDefs.AddOrdinal(const sNewType, sBasicType: string);
var
  s: string;
begin
  s := 't' + sNewType + '=' + sBasicType;
  if FOrdinals.IndexOf(s) < 0 then
    FOrdinals.Add(s);
end;

Function tClassDefs.AddEnum(const sName: string):tEnumDef;
var s:string;
    i:integer;
begin
 s := sName;
 i:=FEnums.IndexOf(s);
 if i<0 then
  begin
   result:=Tenumdef.Create(sname);
   Fenums.AddObject(s,result);
  end else result:= tEnumDef(FEnums.Objects[i]);

end;


procedure tClassDefs.Addconst(const sPrefix, sValue: string);
begin
  FConsts.Add(sPrefix + '_' + RemoveSpaces(sValue) + '=''' + sValue + '''');
end;

procedure tClassDefs.AddUses(const aUnit: string);
begin
  FUses.Add(aUnit);
end;

procedure tClassDefs.AddInclude(const sAlias, sNamespace: string);
begin
  FIncludes.Values[sAlias] := sNamespace;
end;

procedure tClassDefs.SortClasses;
var
  iClass: integer;
  aClass: tClassDef;
  jClass: integer;
  bClass: tClassDef;
  iProp: integer;
  aProp: tProperty;
  srcList: tList;
  dstList: tList;
  bDone: boolean;
  bMoved: boolean;
  ix: integer;

  function FindInList(const aType: string; aList: tList): boolean;
  var
    i: integer;
  begin
    result := false;
    for i := 0 to aList.Count - 1 do
    begin
      if (('t' + tClassDef(aList[i]).name) = aType) then
      begin
        result := true;
        exit;
      end;
    end;
  end;

begin // procedure tClassDefs.SortClasses;
  // copy list
  srcList := tList.Create;
  for iClass := 0 to Count - 1 do
    srcList.Add(Objects[iClass]);

  // sortieren durch einfügen
  dstList := tList.Create;
  while srcList.Count > 0 do
  begin
    bMoved := false;
    for iClass := srcList.Count - 1 downto 0 do
    begin
      ix := iClass;
      aClass := tClassDef(srcList[iClass]);
      // test if any property is satisfied by srclist
      bDone := true; // assume we can move it
      for iProp := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.objects[iProp]);
        bDone := not FindInList(aProp._type, srcList);
        if not bDone then
          break;
      end; // for iProp := 0 to aClass.Properties.Count - 1 do
      if bDone then
      begin
        // move from srclist to dstlist
        dstList.add(srcList[ix]);
        srcList.Delete(ix);
        bMoved := true; // anyone moved
        break;
      end;
    end; // for iClass := 0 to srcList.Count - 1 do
    if not bMoved then
    begin
      // if we do not move any class during one turn around
      // there is something wrong.
      break;
    end;
  end;

  // move result back to original list
  for iClass := 0 to dstList.Count - 1 do
  begin
    Objects[iClass] := dstList[iClass];
    Strings[iClass] := tClassDef(dstList[iClass]).Name;
  end;

  dstList.Free;
  srcList.Free;
end;

procedure tClassDefs.SaveToStream(aStream: tStream);
var
  aClass: tClassDef;
  aProp: tProperty;
  c: integer;
  p: integer;
  bInIf: boolean;
  s: string;
  s1: string;
  i: integer;
  bCallSimpleConstructor: boolean;
  bQualified: boolean;
  lBuilder: TStringStream;
  lIsInheritedClass: boolean;

  procedure oute(const s: string);
  begin
    if length(s) > 0 then
      lBuilder.WriteString(s);
  end;

  procedure outline(const s: string);
  begin
    oute(s + crlf);
  end;

  procedure writeEnums;
  var s:string;
      e:TenumDef;
      el:tEnumElement;
      c,j:integer;
  begin
    if FEnums.Count > 0 then
    begin
      outline('// enumerations');
      outline(TabType);
      for c := 0 to FEnums.Count - 1 do
      begin
        e:=TEnumDef(fenums.Objects[c]);
        s:=tabt+e.Name+' = (';
        for j:= 0 to e.Elements.Count-1 do
          begin
            el:=tenumelement(e.elements[j]);
            s:=s+e.Elements[j];
            if j<e.Elements.Count-1 then   s:=s+',';


          end;
        s:=s+');';
        outline(s);

      end;

      outline('');
    end;
  end;

begin
  // =====================
  // WRITE THE UNIT HEADER
  // =====================

  lBuilder := TStringStream.Create;
  try

    outline('unit u' + ChangeFileExt(ExtractFilename(FXSDFilename), ';'));
    outline('');
    outline('Interface');
    outline('uses');
    outline('  Classes,');
    outline('  JanXMLParser2,');
    for c := 0 to FUses.Count - 1 do
      outline('  u' + FUses[c] + ',');
    outline('  uXMLTools;');
    outline('');
    outline('// targetNameSpace: ' + targetNameSpace);
    outline('// NameSpacePrefix: ' + NameSpacePrefix);
    outline('// Date of Schema : ' + FXSDTimeStamp);
    outline('// Translationdate: ' + FormatDateTime('c', Now));
    outline('//');
    for c := 0 to Includes.Count - 1 do
    begin
      s := Includes.Strings[c];
      s1 := CmdSplit(s, '|');
      if s = '' then
        outline('//   includes ' + s1)
      else
        outline('//   includes ' + s1 + ' in ' + QuotedStr(s + '.pas'));
    end;
    outline('');

    SortClasses;

    // if bDebug then
    if FOrdinals.count > 0 then
    begin
      outline('// ordinal types');
      outline(tabtype);
      for c := 0 to FOrdinals.Count - 1 do
        outline('  ' + StringReplace(FOrdinals[c], '=', ' = ', []) + ';');
      outline('');
    end;
    WriteEnums;

    if FConsts.Count > 0 then
    begin
      outline('// constants for enumerations');
      outline(tabconst);
      for c := 0 to FConsts.Count - 1 do
        outline(tabC + ReplaceStr(FConsts[c], '=''', ' = ''') + ';');

      outline('');
    end;

    for c := 0 to Count - 1 do
    begin
      aClass := tClassDef(Objects[c]);
      outline(tabconst);
      outline('  sn' + aClass.Name + ' = ''' + aClass.Name + ''';');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'A' then // Attribute
        begin
          oute('  an');
          bQualified := FAttributesQualified;
        end
        else // Element
        begin
          oute('  sn');
          bQualified := FElementsQualified;
        end;

        if FALSE {bQualified} then
        begin
          if aProp.NameSpace = '' then
            aProp.FNameSpace := Self.NameSpacePrefix;

          if aProp.NameSpace = '' then // error
            outline(aClass.Name + '_' + aProp.Name + ' = ''' + aProp.NameSpace
              + ':' + aProp.Name + '''; // missing Namespace')
          else
            outline(aClass.Name + '_' + aProp.Name + ' = ''' + aProp.NameSpace
              + ':' + aProp.Name + ''';');
        end
        else
        begin
          // unqualified
          outline(aClass.Name + '_' + aProp.Name + ' = ''' + aProp.Name +
            ''';');
        end
      end;

      // ==========================
      // WRITE THE CLASS DEFINITION
      // ==========================

      outline('');
      outline(tabtype);
      lIsInheritedClass := not aClass.IsExtensionOf.IsEmpty;
      if lIsInheritedClass then
        outline(tabClass + 'T' + aClass.Name + ' = class(' + aClass.IsExtensionOf + ')')
      else
        outline(tabClass + 'T' + aClass.Name + ' = class');





      // =======================
      // write private variables
      // =======================

      outline(tabprivate);
      outline('    F_NameSpaceAlias: string;');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList then
        begin
          // max set or unbounded -> create a list
          outline(tabF + aProp.Name + ': TStringList; // of ' +
            aProp._Type + '(' + aProp.Base + ')');
        end
        else if (aProp.maxOccurs = cScalar) then
        begin
          // adjust properties of transcoded ordinal type
          s := Ordinals.Values[aProp._Type];
          if s <> '' then
          begin
            if bDebug then
              outline('//  ' + aProp._Type + ' = ' + s + ' / simple = ' + IntToStr(
                ord(aProp.PropertyType)));
            aProp.FType := s;
            // gp aProp.FSimple := true;
          end;
          outline(tabF + aProp.Name + ': ' + aProp._Type + '; // '
            + '(' + aProp.Base + ')');

          if aProp.IsOptional then
            outline(tabF + aProp.Name + '_IsSet_' + ': boolean;');
        end;
      end;

      // write getter setter function headers for optional parameters
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if not aProp.IsList and aProp.IsOptional then
          outline('    procedure Set' + aProp.Name + '(value:' + aProp._Type +
            ');');
      end;

      outline(tabpublic);

      outline(tabConstrC);
      outline(tabConstrN);
      outline(tabdestr);
      outline('    class function _nsURI_:string;');
      outline(tabSave);
      outline(tabProp + '_NameSpaceAlias: string read F_NameSpaceAlias write F_NameSpaceAlias;');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList then
          outline(tabProp + aProp.Name + ': TStringList' + ' read F' +
            aProp.Name + ' write F' + aProp.Name + '; // of ' + aProp._Type)
        else if (aProp.maxOccurs = cScalar) then
        begin
          if aProp.IsOptional then
          begin
            outline(tabProp + CheckPascalReserved(aProp.Name) + ': ' + aProp._Type
              + ' read F' + aProp.Name + ' write Set' + aProp.Name + ';');
            outline(tabProp + aProp.Name + '_IsSet_' + ':boolean read F' +
              aProp.Name + '_IsSet_;');
          end
          else
            outline(tabProp + CheckPascalReserved(aProp.Name) + ': ' + aProp._Type
              + ' read F' + aProp.Name + ' write F' + aProp.Name + ';');
        end;
      end;
      outline(tabend);
      outline('');
    end;

    outline('implementation');
    outline('uses');
    outline('  SysUtils ');
//    outline('  mylib;');
    outline(';');
    outline('');
    outline(tabConst);
    outline('  thisNamespaceURI = ''' + targetNamespace + ''';');
    outline('  defNamespaceAlias = ''' + NameSpacePrefix + ''';');
    outline('');

    for c := 0 to Count - 1 do
    begin
      aClass := tClassDef(Objects[c]);
      outline('{ T' + aClass.Name + ' }');
      outline('');
      // ----------------------------------------------------------------
      // create class function to read the NamespaceURI
      outline('class function t' + aClass.Name + '._nsURI_;');
      outline('begin');
      outline('  result := thisNameSpaceURI;');
      outline('end; // class function _nsURI_');
      outline('');

      // ----------------------------------------------------------------
      // create simple constructor first
      bCallSimpleConstructor := false;
      outline('constructor T' + aClass.Name + '.Create;');
      outline('begin');
      outline('  _NamespaceAlias := defNamespaceAlias;');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base <> 'A' then
          if aProp.IsList then
          begin
            bCallSimpleConstructor := true;
            outline('  F' + aProp.Name + ' := TStringlist.Create(True);');
          end;
      end;
      outline('end; // constructor ...');
      outline('');

      // ----------------------------------------------------------------
      // create contructor from Node now
      outline('constructor t' + aClass.Name + '.Create(aRoot:tJanXMLNode2);');
      outline('var');
      outline('  xn: tJanXMLNode2;');
      outline('  sn: string;');
      outline('  i: integer;');
      outline('  thisURI: string;');
      // create variables for list elements
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList and  (aProp.PropertyType=ptComplex) then
          outline('  a' + aProp.name + ': ' + aProp._type + ';');
      end;
      outline('begin');
      if bCallSimpleConstructor then
      begin
        outline('  Create;');
        outline('');
      end;
      outline('  F_NameSpaceAlias := aRoot.NameSpace;');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'S' then
        begin
          // simple content
          outline('');
          outline('  F' + aProp.Name + ' := aRoot.text; // simple content');
          outline('');
          break; // only one allowed
        end;
      end;

      // create attributes
      if aClass.NumAttributeProperties > 0 then
      begin
        outline('  for i:=0 to aRoot.attributecount -1 do');
        outline('  begin');
        outline('    sn := NamePart(aRoot.attributeName[i]);');
        for p := 0 to aClass.Properties.Count - 1 do
        begin
          aProp := tProperty(aClass.Properties.Objects[p]);
          if aProp.Base = 'A' then // Attributes
          begin
            outline('    if sn = an' + aClass.Name + '_' + aProp.Name +
              ' then');
            if aProp._Type = dInteger then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := StrToIntDef(aRoot.attribute[i], 0);')
            else if aProp._Type = dLong then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := StrToInt64Def(aRoot.attribute[i], 0);')
            else if aProp._Type = dFloat then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := DefStrToFloat(aRoot.attribute[i], 0);')
            else if aProp._Type = dBoolean then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := (aRoot.attribute[i] = ''true'');')
            else if aProp._Type = dDate then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := DateFromXMLDateTime(aRoot.attribute[i]);')
            else if aProp._Type = dTime then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := TimeFromXMLDateTime(aRoot.attribute[i]);')
            else if aProp._Type = dDateTime then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := DateTimeFromXMLDateTime(aRoot.attribute[i]);')
            else if aProp._Type = dByte then
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := StrToIntDef(aRoot.attribute[i], 0);')
            else
              outline('      ' + CheckPascalReserved(aProp.Name) +
                ' := aRoot.attribute[i]; // ' + aProp._Type);
          end; // if aProp.Base = 'A' then
        end;
        outline('  end;');
        outline('');
      end;

      if aClass.NumElementProperties > 0 then
      begin
        // create elements
        outline('  xn := aRoot.FirstChild;');
        outline('  while Assigned(xn) do');
        outline('  begin');
        outline('    sn := NamePart(xn.name);');
        outline('    thisURI := xn.namespaceURI;');
        bInIf := false;
        for p := 0 to aClass.Properties.Count - 1 do
        begin
          aProp := tProperty(aClass.Properties.Objects[p]);
          if (aProp.Base = 'E') or (aProp.Base = 'X') then // Element or Reference
          begin
            if bInIf then
              oute('    else ')
            else
              oute('    ');
            if aProp.PropertyType=ptSimple then
              outline('if (sn = sn' + aClass.Name + '_' + aProp.name + ') then')
            else
            begin
              outline('if (sn = sn' + aClass.Name + '_' + aProp.name + ')');
              outline('      and ((thisURI='''') or (' + aProp._type + '._nsURI_'
                + ' = thisURI)) then');
            end;
            if aProp.IsList then
            begin
              outline('    begin');
              if aProp.PropertyType=ptSimple then
              begin
                outline('      // list of simple type');
                outline('      F' + aProp.Name + '.Add(xn.text);');
              end
              else
              begin
                outline('      a' + aProp.Name + ' := ' + aProp._type +
                  '.Create(xn);');
                outline('      F' + aProp.Name + '.AddObject(''?'', a' +
                  aProp.Name + ');');
              end;
              outline('    end');
            end
            else if aProp.PropertyType=ptSimple then
            begin
              if aProp._Type = dInteger then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'StrToIntDef(xn.text, 0)')
              else if aProp._Type = dLong then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'StrToInt64Def(xn.text, 0)')
              else if aProp._Type = dFloat then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'DefStrToFloat(xn.text, 0)')
              else if aProp._Type = dBoolean then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  '(xn.text = ''true'')')
              else if aProp._Type = dDate then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'DateFromXMLDateTime(xn.text) // ' + aProp._Type)
              else if aProp._Type = dTime then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'TimeFromXMLDateTime(xn.text) // ' + aProp._Type)
              else if aProp._Type = dDateTime then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'DateTimeFromXMLDateTime(xn.text) // ' + aProp._Type)
              else if aProp._Type = dByte then
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                  'StrToIntDef(xn.text, 0)')
              else
                outline('      ' + CheckPascalReserved(aProp.Name) + ' := ' + ' xn.text // ' +
                  aProp._Type)
            end // if aProp.simple then
            else
              outline('      F' + aProp.Name + ' := ' + aProp._type +
                '.Create(xn)');

            bInIf := true;
          end; // if aProp.Base = 'E' then
        end; // for p := 0 to aClass.Properties.Count - 1 do

        if bInIf then
          outline('    else;');

        outline('    xn := xn.NextSibling;');
        outline('  end; // while Assigned(xn) do ...');
      end;
      outline('end; // constructor ...');
      outline('');

      // ----------------------------------------------------------------
      // destructor
      outline('destructor t' + aClass.name + '.Destroy;');
      outline('begin');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList or (aProp.PropertyType=ptComplex) then
          outline('  F' + aProp.Name + '.Free;')
      end;
      outline('  inherited;');
      outline('end; // destructor ...');
      outline('');

      // ----------------------------------------------------------------
      // property Setters
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if not aProp.IsList and aProp.IsOptional then
        begin
          outline('procedure t' + aClass.name + '.Set' + aProp.Name + '(value:' +
            aProp._Type + ');');
          outline('begin');
          outline('  F' + aProp.Name + ' := value;');
          outline('  F' + aProp.Name + '_IsSet_ := true;');
          outline('end;');
          outline('');
        end;
      end;

      // ----------------------------------------------------------------
      // procedure Save
      outline('procedure t' + aClass.name + '.Save(aNode:tJanXMLNode2);');
      outline('var');
      outline('  xn: tJanXMLNode2;');
      outline('  i: integer;');
      outline('begin');
      outline('  if aNode.name = '''' then');
      outline('    aNode.name := nsName(_NameSpaceAlias, ''' + aClass.name +
        ''')');
      outline('  else if pos(colon, aNode.name) = 0 then');
      outline('    aNode.name := nsName(_NameSpaceAlias, aNode.name);');
      outline('');
      outline('  if _NameSpaceAlias <> '''' then');
      outline('  begin');
      outline('    xn := aNode;');
      outline('    while Assigned(xn.ParentNode) do');
      outline('      xn := xn.ParentNode;');
      outline('    xn.attribute[''xmlns:'' + _NameSpaceAlias] := thisNameSpaceURI;');
      outline('  end;');
      outline('');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'S' then
        begin
          // simple content
          outline('  aNode.text := F' + aProp.Name + '; // simple content');
          outline('');
          break; // only one allowed
        end;
      end;

      // save attributes
      if aClass.NumAttributeProperties > 0 then
      begin
        for p := 0 to aClass.Properties.Count - 1 do
        begin
          aProp := tProperty(aClass.Properties.Objects[p]);
          if aProp.Base = 'A' then // Attribute
          begin
            if aProp.IsOptional then
            begin
              outline('  if ' + aProp.Name + '_IsSet_ then');
              oute('  ');
            end;
            if aProp._Type = dInteger then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := ' + 'IntToStr(F' + aProp.Name + ');')
                // ???
  // outline(Format('  aNode.attribute[an%s_%s] := IntToStr(F%s);',
  //   aClass.Name, aProp.Name, aProp.Name));
            else if aProp._Type = dLong then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := '
                + 'IntToStr(F' + aProp.Name + ');')
            else if aProp._Type = dFloat then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := '
                + 'MyFloatToStr(F' + aProp.Name + ');')
            else if aProp._Type = dBoolean then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := '
                + 'BoolToStr(F' + aProp.Name + ');')
            else if aProp._Type = dDate then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name
                + '] := '
                + 'DateToXMLDateTime(F' + aProp.Name + ');')
            else if aProp._Type = dTime then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := '
                + 'TimeToXMLDateTime(F' + aProp.Name + ');')
            else if aProp._Type = dDateTime then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := '
                + 'DateTimeToXMLDateTime(F' + aProp.Name + ');')
            else if aProp._Type = dByte then
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name +
                '] := '
                + 'IntToStr(F' + aProp.Name + ');')
            else
              outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name
                + '] := ' + 'F' + aProp.Name + ';');
          end; // if aProp.Base = 'A' then
        end; // for p := 0 to aClass.Properties.Count - 1 do
        outline('');
      end;

      // save elements
      if aClass.NumElementProperties > 0 then
      begin
        for p := 0 to aClass.Properties.Count - 1 do
        begin
          aProp := tProperty(aClass.Properties.Objects[p]);
          if (aProp.Base = 'E') or (aProp.Base = 'X') then
          begin
            if aProp.IsList then
            begin
              outline('  // element "' + aProp.Name +
                '" is TStringlist');
              if aProp.PropertyType=ptSimple then
                outline('  // but of simple elements');
              outline('  if Assigned(F' + aProp.Name + ') then');
              outline('    for i:=0 to F' + aProp.Name + '.Count - 1 do');
              outline('    begin');
              if aProp.Base = 'E' then
                outline('      xn := aNode.addChildByName(nsName(_NameSpaceAlias, '
                  + 'sn' + aClass.Name + '_' + aProp.name + '));')
              else
                outline('      xn := aNode.addChildByName('
                  + 'sn' + aClass.Name + '_' + aProp.name + ');');
              if aProp.PropertyType=ptSimple then
                outline('      xn.text := F' + aProp.Name + '.Strings[i];')
              else
              begin
                outline('      ' + aProp._type + '(F' + aProp.Name +
                  '.Objects[i]).Save(xn);');
              end;
              outline('    end; // for i:=0 to ...');
            end
            else // no list
            begin
              if aProp.PropertyType=ptSimple then
              begin
                if aProp.IsOptional then
                begin
                  outline('  if ' + aProp.Name + '_IsSet_ then');
                  outline('  begin');
                  outline('    xn := aNode.addChildByName(nsName(_NameSpaceAlias, '
                    + 'sn' + aClass.Name + '_' + aProp.name + '));');
                  oute('  ');
                end
                else
                  outline('  xn := aNode.addChildByName(nsName(_NameSpaceAlias, '
                    + 'sn' + aClass.Name + '_' + aProp.name + '));');

                if (aProp._Type = dString) then
                  outline('  xn.text := ' + 'F' + aProp.Name + ';')
                else if aProp._Type = dDate then
                  outline('  xn.text := ' + 'DateToXMLDateTime(F' + aProp.Name +
                    ');')
                else if aProp._Type = dDateTime then
                  outline('  xn.text := ' + 'DateTimeToXMLDateTime(F' +
                    aProp.Name + ');')
                else if aProp._Type = dInteger then
                  outline('  xn.text := ' + 'IntToStr(F' + aProp.Name + ');')
                else if aProp._Type = dLong then
                  outline('  xn.text := ' + 'IntToStr(F' + aProp.Name + ');')
                else if aProp._Type = dFloat then
                  outline('  xn.text := ' + 'MyFloatToStr(F' + aProp.Name + ');')
                else if aProp._Type = dBoolean then
                  outline('  xn.text := ' + 'BoolToStr(F' + aProp.Name + ');')
                else if aProp._Type = dTime then
                  outline('  xn.text := ' + 'TimeToXMLDateTime(F' + aProp.Name
                    + ');')
                else if (aProp._Type = dDatetime) then
                  outline('  xn.text := ' + 'DateTimeToXMLDateTime(F' +
                    aProp.Name + ');')
                else if (aProp._Type = dDate) then
                  outline('  xn.text := ' + 'DateToXMLDateTime(F' + aProp.Name
                    + ');')
                else if aProp._Type = dByte then
                  outline('  xn.text := ' + 'IntToStr(F' + aProp.Name + ');')
                else if aProp._Type = dString then
                  outline('  xn.text := ' + 'F' + aProp.Name + ';')
                else if aProp._Type = 'uxs.tnormalizedString' then
                  outline('  xn.text := ' + 'F' + aProp.Name + ';')
                else if aProp._Type = 'uxs.tbase64Binary' then
                  outline('  xn.text := ' + 'F' + aProp.Name + ';')
                else
                 outline('  xn.text := ' + 'F' + aProp.Name + ';');


                if aProp.IsOptional then
                  outline('  end;');
              end // if aProp.simple then
              else
              begin
                outline('  if Assigned(F' + aProp.Name + ') then');
                outline('  begin');
                outline('    xn := aNode.addChildByName('
                  + 'sn' + aClass.Name + '_' + aProp.name + ');');
                outline('    F' + aProp.Name + '.Save(xn);');
                outline('  end;');
              end
            end;
          end; // if aProp.Base = 'E' then
        end; // for p := 0 to aClass.Properties.Count - 1 do
      end;
      outline('end; // procedure save');
      outline('');
    end;

    outline('end.');

    lBuilder.Position := 0;
    lBuilder.SaveToStream(aStream);
  finally
    lBuilder.Free;
  end;
end;

end.
