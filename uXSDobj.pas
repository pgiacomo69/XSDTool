unit uXSDobj;

interface
uses
  Classes,
  uXMLTools
  ;
{#BACKUP g:\proj5\delphi32\uxmlTools.pas }

const
  cqualified = 'qualified';
  cunqualified = 'unqualified';

type

  TXSDVisitor = class; // forward
  
  tProperty = class
  private
    FBase: string;
    FType: string;
    FName: string;
    FNameSpace: string;
    FMaxOccurs: integer;
    FSimple: boolean;
    FMinOccurs: integer;
    function GetIsList: boolean;
    function GetIsOptional: boolean;
  public
    constructor Create(const aName, aType, aBase, aNSpc: string;
      aMax, aMin: integer; bSimple: boolean);
	//procedure AcceptVisitor(aVisitor: TXSDVisitor);
    property Name: string read FName;
    property _Type: string read FType;
    property Base: string read FBase;
    property NameSpace: string read FNameSpace;
    property maxOccurs: integer read FMaxOccurs;
    property minOccurs: integer read FMinOccurs;
    property simple: boolean read FSimple;
    property IsOptional: boolean read GetIsOptional;
    property IsList: boolean read GetIsList;
  end;

type
  tClassDef = class
  private
    FName: string;
    FProperties: TStringlist;
  public
    constructor Create(const aName: string);
    destructor Destroy; override;
    function NumAttributeProperties: integer;
    function NumElementProperties: integer;
    property Properties: TStringList read FProperties;
    property Name: string read FName;
  end;

type
  tClassDefs = class(TStringList)
  private
    FOrdinals: tStringlist;
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
    procedure SortClasses;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure AddUses(const aUnit: string);
    procedure AddOrdinal(const sNewType, sBasicType: string);
    procedure AddConst(const sPrefix, sValue: string);
    procedure AddInclude(const sAlias, sNamespace: string);
    procedure SaveToStream(aStream: tStream);
	
	procedure AcceptVisitor(aVisitor: TXSDVisitor);
    //
    property Ordinals: tStringlist read FOrdinals; //  write FOrdinals;
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
  
    // Abstract base defintion of Visitor pattern that can work on XSD schema in TClassdefs and subclasses
  // Concrete implementations i.e. in uXSDVisitor unit
  TXSDVisitor = class abstract(TObject);
  public
    procedure Visit(aSchema: TClassDefs); abstract; virtual;
	// procedure Visit(aClass: TClassDef);
	// procedure Visit(aProperty: TProperty);
  end;
  

{(*}
const
//  xsSchema         = 'xs:schema';
  xsSchema1        = 'schema';
//  xsElement        = 'xs:element';
  xsElement1       = 'element';
//  xsImport         = 'xs:import';
  xsImport1        = 'import';
  xseName          = 'name';
  xseType          = 'type';
  xseRef           = 'ref';
//  xsAttribute      = 'xs:attribute';
  xsAttribute1     = 'attribute';
//  xsSequence       = 'xs:sequence';
  xsSequence1      = 'sequence';
//  xsComplexType    = 'xs:complexType';
  xsComplexType1   = 'complexType';
//  xsSimpleType     = 'xs:simpleType';
  xsSimpleType1    = 'simpleType';
//  xsSimpleContent  = 'xs:simpleContent';
  xsSimpleContent1 = 'simpleContent';
//  xsExtension      = 'xs:extension';
  xsExtension1     = 'extension';
//  xsRestriction    = 'xs:restriction';
  xsRestriction1   = 'restriction';
//  xsEnumeration    = 'xs:enumeration';
  xsEnumeration1   = 'enumeration';
  xsRsBase         = 'base';
  xsminoccurs      = 'minOccurs';
  xsmaxoccurs      = 'maxOccurs';
  xsmunbounded     = 'unbounded';
//  xschoice         = 'xs:choice';
  xschoice1        = 'choice';
  xsuse            = 'use';
//  xseuse           = 'xs:use';

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
  aMax, aMin: integer; bSimple: boolean);
begin
  FName := aName;
  FType := aType;
  FBase := aBase;
  FNameSpace := aNSpc;
  FMaxOccurs := aMax;
  FMinOccurs := aMin;
  FSimple := bSimple;
end;

function tProperty.GetIsList: boolean;
begin
  result := (maxOccurs > 1) or (maxOccurs = cUnbounded);
end;

function tProperty.GetIsOptional: boolean;
begin
  result := minOccurs = 0;
end;

{ tClassDefs }

constructor tClassDefs.Create;
begin
  inherited;
  OwnsObjects := True;
  FOrdinals := tStringList.Create;
  FUses := tStringlist.Create;
  FUses.Sorted := true;
  FUses.Duplicates := dupIgnore;
  FConsts := tStringlist.Create;
  FIncludes := tStringlist.Create;
end;

destructor tClassDefs.Destroy;
begin
  inherited;

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

  procedure oute(const s: string);
  begin
    if length(s) > 0 then
      lBuilder.WriteString(s);
  end;

  procedure outline(const s: string);
  begin
    oute(s + crlf);
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
                ord(aProp.Simple)));
            aProp.FType := s;
            aProp.FSimple := true;
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
        if aProp.IsList and not aProp.simple then
          outline('  a' + aProp.name + ': t' + aProp.name + ';');
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
            if aProp.simple then
              outline('if (sn = sn' + aClass.Name + '_' + aProp.name + ') then')
            else
            begin
              outline('if (sn = sn' + aClass.Name + '_' + aProp.name + ')');
              outline('      and ((thisURI='''') or (t' + aProp.name + '._nsURI_'
                + ' = thisURI)) then');
            end;
            if aProp.IsList then
            begin
              outline('    begin');
              if aProp.simple then
              begin
                outline('      // list of simple type');
                outline('      F' + aProp.Name + '.Add(xn.text);');
              end
              else
              begin
                outline('      a' + aProp.Name + ' := t' + aProp.name +
                  '.Create(xn);');
                outline('      F' + aProp.Name + '.AddObject(''?'', a' +
                  aProp.Name + ');');
              end;
              outline('    end');
            end
            else if aProp.simple then
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
              outline('      F' + aProp.Name + ' := t' + aProp.name +
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
        if aProp.IsList or (not aProp.Simple) then
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
              if aProp.simple then
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
              if aProp.simple then
                outline('      xn.text := F' + aProp.Name + '.Strings[i];')
              else
              begin
                outline('      t' + aProp.Name + '(F' + aProp.Name +
                  '.Objects[i]).Save(xn);');
              end;
              outline('    end; // for i:=0 to ...');
            end
            else // no list
            begin
              if aProp.simple then
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

procedure tClassDefs.AcceptVisitor(aVisitor: TXSDVisitor);
begin
	aVisitor.Visit(self);
end;
    
end.

