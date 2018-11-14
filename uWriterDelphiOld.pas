unit uWriterDelphiOld;


interface
uses
  Classes,
  uXSDobj,
  uWriterGen,
  uXMLTools;

type

 TDelphiClassWriter=class(TClassWriterGen)
                      private
                       FclassDefs:tClassDefs;
                     end;



procedure SaveToStreamDelphi(FclassDefs:tClassDefs;aStream: tStream;UseTXMLDocument:Boolean);

implementation
  uses mylib,
  SysUtils;




const
  tabConst = 'const';
  tabType = 'type';
  tabClass = '  ';
  tabPrivate = '  private';
  tabPublic = '  public';
  tabConstrN = '    constructor Create(aRoot:tJanXMLNode2); overload;';
  tabConstrC = '    constructor Create; overload;';
  tabDestr = '    destructor Destroy; override;';
  tabSav = '    procedure Save(aNode:tJanXMLNode2);';
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




procedure SaveToStreamDelphi(FclassDefs:tClassDefs;aStream: tStream;UseTXMLDocument:Boolean);



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
  var
   arrayDecl:TStringList;

   procedure AddArrayElement(base,value,doc:string;last:boolean);
   const maxstrlen=80;
   var
    s:String;
    l:integer;
   begin
     s:=base+'(';
     l:=length(s);
       while length(value)>maxstrlen do
        begin
          s:=s+quotedstr(copy(value,1,maxstrlen))+'+';
          delete(value,1,maxstrlen);
          arrayDecl.Add(s);
          s:=StringOfChar(' ',l);
      end;
     s:=s+quotedstr(Value)+',';
     l:=length(s);
       while length(doc)>maxstrlen do
        begin
          s:=s+quotedstr(copy(doc,1,maxstrlen))+'+';
          delete(doc,1,maxstrlen);
          arrayDecl.Add(s);
          s:=StringOfChar(' ',l);
        end;
     s:=s+quotedstr(Doc)+')';
     if not last then
            begin
             s:=s+',';
            end
            else
            begin
             s:=s+');';
            end;
     arrayDecl.Add(s);
   end;

   var s,sa,sArrayDecl,sArrayDeclBase:string;
      e:TenumDef;
      el:tEnumElement;
      c,ca,j:integer;
      lenADeclbase:Integer;


  begin
    if FclassDefs.Enums.Count > 0 then
    begin
      arrayDecl:=TStringList.create;
      outline('// enumerations');
      outline(TabType);
      outline(tabc+'EnumPropIndexer=(tePiValue,tePiDoc);');
      for c := 0 to FclassDefs.Enums.Count - 1 do

      begin
        e:=TEnumDef(FclassDefs.Enums.Objects[c]);
        s:=tabt+e.Name+' = (';
        // TJobTipoS:TJobTipoStrings=('Nullo','R','M','S','S3U','S3I','GCE','GCS','BKD','EP','EXP','IMP');
        sArrayDeclbase:=tabc+e.Name+'Strings:t'+e.name+'Strings=(';
        lenADeclbase:=length(sArrayDeclBase);
        for j:= 0 to e.Elements.Count-1 do
          begin
            el:=tenumelement(e.elements.Objects[j]);
            s:=s+e.Elements[j];
            if j=0 then sArrayDecl:=sArrayDeclBase
                   else sArrayDecl:=StringOfChar(' ',lenADeclbase);
            AddArrayElement(sArrayDecl,el.Value,el.Documentation,j>=e.Elements.Count-1);
            if j<e.Elements.Count-1 then
             s:=s+','
            else
             s:=s+');';

          end;

        outline(s);
        sa:=tabt+e.Name+'Strings=array['+e.Elements[0]+'..'+e.Elements[e.Elements.Count-1]+',tePiValue..tePiDoc] of String;';
        outline(sa);
        outline('');
        arrayDecl.Add('');


      end;
      outline('');
      outline(tabConst);
      for c:=0 to arrayDecl.Count-1 do
        begin
          outline(arraydecl[c]);
        end;

    end;
  end;

  Procedure writeEnumsClassIntf;
  var  i:integer;
       e:TenumDef;
       sName:String;
  begin
   if FclassDefs.Enums.Count > 0 then
    begin
    outline('');
    outline(tabtype);
     for i:=0 to FclassDefs.Enums.Count-1 do
      begin
        sname:=FclassDefs.Enums[i];
        e:=TenumDef(FclassDefs.Enums.Objects[i]);
        outline( tabT + e.Name + 'helper = record helper for t' + e.Name);
        outline('   private');
        outline('    procedure setAsString (value:String);');
        outline('    function getAsString : string;');
        outline('    function getDocumentation : string;');
        outline('   public');
        outline('    function GetListValues:TStringList;');
        outline('    function GetListDocs:TStringList;');
        outline('    property AsString:String read getASstring write setAsString;');
        outline('    property Documentation:String read getDocumentation;');
        outline('   end;');
        outline('');
      end;
    end;
  end;


  Procedure writeEnumsClassImpl;
  var  i:integer;
       e:TenumDef;
       sName:String;
  begin
   if FclassDefs.Enums.Count > 0 then
    begin
    outline('');

     for i:=0 to FclassDefs.Enums.Count-1 do
      begin
        sname:=FclassDefs.Enums[i];
        e:=TenumDef(FclassDefs.Enums.Objects[i]);
      outline('{ T' + Sname + ' }');
      outline('');
      // ----------------------------------------------------------------
      // create class function to read the NamespaceURI
      outline('procedure t'+sname+'Helper.setAsString(value:String);');
      outline(' var v:t'+sname+';');
      outline('     i:t'+sname+';');
      outline('     found:Boolean;');
      outline('begin');
      outline('  v := '+e.NullValueName+';');
      outline('  i := '+e.NullValueName+';');
      outline('  repeat');
      outline('   inc(i);');
      outline('   if c'+sname+'Strings[i,tePivalue]=value then');
      outline('    v:=i;');
      outline('  until (v<>'+e.NullValueName+') or (i=high(t'+sname+'));');
      outline('  self:=v;');
      outline('end; // procedure setAsString');
      outline('');

      outline('function t'+sname+'Helper.getAsString:String;');
      outline('');
      outline('begin');
      outline('  result:=c'+sname+'Strings[self,tePivalue];');
      outline('end; // function getAsString');
      outline('');

      outline('function t'+sname+'Helper.getDocumentation:string;');
      outline('');
      outline('begin');
      outline('  result:=c'+sname+'Strings[self,tePiDoc];');
      outline('end; // function getDocumentation');
      outline('');

      outline('function t'+sname+'Helper.GetListValues:TStringList;');
      outline(' var i:t'+sname+';');
      outline('begin');
      outline('  result:=TStringList.create;');
      outline('  for i:=low(t'+sname+') to high(t'+sname+') do');
      outline('  result.add (c'+sname+'Strings[i,tePivalue]);');
      outline('end; // procedure GetListValues');
      outline('');

      outline('function t'+sname+'Helper.GetListDocs:TStringList;');
      outline(' var i:t'+sname+';');
      outline('begin');
      outline('  result:=TStringList.create;');
      outline('  for i:=low(t'+sname+') to high(t'+sname+') do');
      outline('  result.add (c'+sname+'Strings[i,tePiDoc]);');
      outline('end; // procedure GetListDocs');
      outline('');

(*
  tttEstHelper = record helper for tttEst
                  private
                   procedure setAsString (value:String);
                   function getAString : string;
                  public
                   function Documentation:String;
                   function Values:TStringList;
                   function GetDocumentations:TStringList;
                   property AsString:String read getAString write setAsString;
                 end;
*)
      end;
    end;
  end;


begin
  // =====================
  // WRITE THE UNIT HEADER
  // =====================

  lBuilder := TStringStream.Create;
  try

    outline('unit u' + ChangeFileExt(ExtractFilename(FclassDefs.XSDFilename), ';'));
    outline('');
    outline('Interface');
    outline('uses');
    outline('  Classes,');
    outline('  JanXMLParser2,');
    for c := 0 to FclassDefs.Usess.Count - 1 do
      outline('  u' + FclassDefs.Usess[c] + ',');
    outline('  uXMLTools;');
    outline('');
    outline('// targetNameSpace: ' + FclassDefs.targetNameSpace);
    outline('// NameSpacePrefix: ' + FclassDefs.NameSpacePrefix);
    outline('// Date of Schema : ' + FclassDefs.XSDTimeStamp);
    outline('// Translationdate: ' + FormatDateTime('c', Now));
    outline('//');
    for c := 0 to FclassDefs.Includes.Count - 1 do
    begin
      s := FclassDefs.Includes.Strings[c];
      s1 := CmdSplit(s, '|');
      if s = '' then
        outline('//   Includes ' + s1)
      else
        outline('//   Includes ' + s1 + ' in ' + QuotedStr(s + '.pas'));
    end;
    outline('');

    FclassDefs.SortClasses;

    // if bDebug then
    if FclassDefs.Ordinals.count > 0 then
    begin
      outline('// ordinal types');
      outline(tabtype);
      for c := 0 to FclassDefs.Ordinals.Count - 1 do
        outline('  ' + StringReplace(FclassDefs.Ordinals[c], '=', ' = ', []) + ';');
      outline('');
    end;


    if FclassDefs.Consts.Count > 0 then
    begin
      outline('// constants for enumerations');
      outline(tabconst);
      for c := 0 to FclassDefs.Consts.Count - 1 do
        outline(tabC + ReplaceStr(FclassDefs.Consts[c], '=''', ' = ''') + ';');

      outline('');
    end;
    WriteEnums;
    writeEnumsClassIntf;
    for c := 0 to FclassDefs.Count - 1 do
    begin
      aClass := tClassDef(FclassDefs.Objects[c]);
      outline(tabconst);
      outline('  sn' + aClass.Name + ' = ''' + aClass.Name + ''';');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'A' then // Attribute
        begin
          oute('  an');
          bQualified := FclassDefs.AttributesQualified;
        end
        else // Element
        begin
          oute('  sn');
          bQualified := FclassDefs.ElementsQualified;
        end;

        if FALSE {bQualified} then
        begin
          if aProp.NameSpace = '' then
            aProp.NameSpace := FclassDefs.NameSpacePrefix;

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
          s := FclassDefs.Ordinals.Values[aProp._Type];
          if s <> '' then
          begin
            if FclassDefs.bDebug then
              outline('//  ' + aProp._Type + ' = ' + s + ' / simple = ' + IntToStr(
                ord(aProp.PropertyType)));
            aProp._Type := s;
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
      outline(tabSav);
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
    outline('  thisNamespaceURI = ''' + FclassDefs.targetNamespace + ''';');
    outline('  defNamespaceAlias = ''' + FclassDefs.NameSpacePrefix + ''';');
    outline('');
    writeEnumsClassImpl;
    for c := 0 to FclassDefs.Count - 1 do
    begin
      aClass := tClassDef(FclassDefs.Objects[c]);
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
           case aprop.PropertyType of
                      ptSimple:begin
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
                               end;
                        ptEnum:begin
                                 outline('      ' + CheckPascalReserved(aProp.Name) +
                                    '.AsString := aRoot.attribute[i]; // ' + aProp._Type);
                               end;
                      ptComplex:raise(exception.Create('Complex Attribute not expected here (Create)'));
                  end; // case
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
            if aProp.PropertyType<>ptComplex then
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
            else
            case aProp.PropertyType of
                 ptSimple:begin
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
                          end; // ptsimple
                ptCOmplex:outline('      F' + aProp.Name + ' := ' + aProp._type +'.Create(xn)');
                   ptEnum:outline('      ' + CheckPascalReserved(aProp.Name)+'.AsString' + ' := ' + ' xn.text // ' +aProp._Type);
             end;
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
            case aprop.PropertyType of
                 ptSimple:Begin
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
                           End;
                    ptEnum:begin
                            outline('  aNode.attribute[an' + aClass.Name + '_' + aProp.Name
                                + '] := ' + 'F' + aProp.Name + '.AsString;');
                           end;
                    ptComplex:raise(exception.Create('Complex Attribute not expected here (Save)'));
                  end; // Case
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
              if aProp.PropertyType<>ptComplex then
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
                case aprop.PropertyType of
                  ptSimple:begin
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
                           end ;
                  ptComplex:raise(exception.Create('Complex Property not expected here (Save)'));
                  ptEnum:outline('  xn.text := ' + 'F' + aProp.Name + '.AsString;');
                end;



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