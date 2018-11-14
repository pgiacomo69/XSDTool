unit uWriterDelphi;

interface

uses
  Classes,
  uXSDobj,
  uWriterGen,
  uXMLTools;

type
 TDelphiClassWriter=class(TClassWriterGen)
                      protected
                       function getBaseFileExtension:String; Override;
                       procedure WriteInterface; override;
                       procedure WriteImplementation; override;
                      private
                       fUseTXMLDocument:Boolean;
                       fNodeClass:String;
                       fNodeNameSpace:String;
                       fNodeFirstChild:String;
                       fNodeLocalname:String;
                       fNodeAddChild:String;
                       fNodeAttributes:String;
                       fNodeAttributeNodesCount:String;
                       fNodeAttributeNodeNames:String;
                       fTabConstr:String;
                       fTabSave:String;
                       procedure  IntfWriteUnitHeader(fOut:TOutputUnit;usesL:TStringList);
                       procedure  IntfWriteOrdinals;
                       procedure  IntfWriteConsts;
                       procedure  IntfWriteEnums(fOut:TOutputUnit);
                       procedure  IntfwriteEnumsHelpers(fOut:TOutputUnit);
                       procedure  IntfWriteClasses;
                       procedure  ImplWriteUnitHeader(fOut:TOutputUnit);
                       procedure  ImplwriteEnumsHelpers(fOut:TOutputUnit);
                       procedure  ImplWriteClasses(fOut:TOutputUnit);
                       Procedure InitKeywords;
                       function CheckPascalReserved(const aPropName: string): string;

                      public
                       constructor create(const aClassDefs:tClassDefs;const UseTXMLDocument:Boolean);

                     end;


implementation
 uses mylib,
  SysUtils;

{ TDelphiClassWriter }

const
 cNodeClass='IXMLNode';
 cNodeClassJ='tJanXMLNode2';
 cNodeNameSpace='NamespaceURI';
 cNodeNameSpaceJ='NameSpace';
 cNodeFirstChild='ChildNodes.First';
 cNodeFirstChildJ='FirstChild';
 cNodeLocalname='xn.LocalName';
 cNodeLocalnameJ='NamePart(xn.name)';
 cNodeAddChild='addChild';
 cNodeAddChildJ='addChildByName';
 cNodeAttributes='attributes';
 cNodeAttributesJ='attribute';
 cNodeAttributeNodesCount='AttributeNodes.Count';
 cNodeAttributeNodesCountJ='attributecount';
 cNodeAttributeNodeNames='AttributeNodes[i].NodeName';
 cNodeAttributeNodeNamesJ='attributeName[i]';
 cNodeAttributeNodeValues='AttributeNodes[i].NodeValue';
 cNodeAttributeNodeValuesJ='attributes[i]';

 cTabConstr = '    constructor Create(aRoot:IXMLNode); overload;';
 cTabConstrJ = '    constructor Create(aRoot:tJanXMLNode2); overload;';
 cTabSave = '    procedure Save(aNode:IXMLNode);';
 cTabSaveJ = '    procedure Save(aNode:tJanXMLNode2);';

 cTabConst = 'const';
 cTabType = 'type';
 cTabClass = '  ';
 cTabPrivate = '  private';
 cTabPublic = '  public';
 cTabConstrC = '    constructor Create; overload;';
 cTabDestr = '    destructor Destroy; override;';
 cTabProp = '    property ';
 cTabF = '    F';
 cTabC = '  c';
 cTabt = '  t';
 cTabEnd = '  end;';


constructor TDelphiClassWriter.create(const aClassDefs: tClassDefs;
  const UseTXMLDocument: Boolean);
begin
 inherited create(aClassDefs);
 fUseTXMLDocument:=UseTXMLDocument;
 InitKeywords;
end;


function TDelphiClassWriter.getBaseFileExtension: String;
begin
  result:='.pas';
end;


procedure TDelphiClassWriter.InitKeywords;
begin
 if fUseTXMLDocument then
  begin
    fNodeClass:=cNodeClass;
    fTabConstr:=cTabConstr;
    fTabSave:=cTabSave;
    fNodeNameSpace:=CNodeNameSpace;
    fNodeFirstChild:=cNodeFirstChild;
    fNodeLocalname:=cNodeLocalname;
    fNodeAddChild:=cNodeAddChild;
    fNodeAttributes:=cNodeAttributes;
    fNodeAttributeNodesCount:=cNodeAttributeNodesCount;
    fNodeAttributeNodeNames:=cNodeAttributeNodeNames;

  end
 else
  begin
    fNodeClass:=cNodeClassJ;
    fTabConstr:=cTabConstrJ;
    fTabSave:=cTabSaveJ;
    fNodeNameSpace:=CNodeNameSpaceJ;
    fNodeFirstChild:=cNodeFirstChildJ;
    fNodeLocalname:=cNodeLocalnameJ;
    fNodeAddChild:=cNodeAddChildJ;
    fNodeAttributes:=cNodeAttributesJ;
    fNodeAttributeNodesCount:=cNodeAttributeNodesCountJ;
    fNodeAttributeNodeNames:=cNodeAttributeNodeNamesJ;
  end;
end;

function TDelphiClassWriter.CheckPascalReserved(const aPropName: string): string;
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

procedure  TDelphiClassWriter.IntfWriteUnitHeader(fOut:TOutputUnit;usesL:TStringList);
var c:integer;
    s,s1:String;
begin
    outline(fOut,'unit u' + fOut.unitName + ';');
    outline(fOut,'');
    outline(fOut,'Interface');
    outline(fOut,'uses');
    outline(fOut,'  Classes,');
    if fUseTXMLDocument then
      begin
       outline(fOut,'  Xml.xmldom,');
       outline(fOut,'  Xml.XMLIntf,');
       outline(fOut,'  Xml.XMLDoc,');
      end
     else
      begin
       outline(fOut,'  JanXMLParser2,');
      end;
    for c := 0 to usesL.Count - 1 do
      outline(fOut,'  u' + usesL[c] + ',');
    outline(fOut,'  uXMLTools;');
    outline(fOut,'');
    outline(fOut,'// targetNameSpace: ' + FclassDefs.targetNameSpace);
    outline(fOut,'// NameSpacePrefix: ' + FclassDefs.NameSpacePrefix);
    outline(fOut,'// Date of Schema : ' + FclassDefs.XSDTimeStamp);
    outline(fOut,'// Translationdate: ' + FormatDateTime('c', Now));
    outline(fOut,'//');
    for c := 0 to FclassDefs.Includes.Count - 1 do
    begin
      s := FclassDefs.Includes.Strings[c];
      s1 := CmdSplit(s, '|');
      if s = '' then
        outline(fOut,'//   Includes ' + s1)
      else
        outline(fOut,'//   Includes ' + s1 + ' in ' + QuotedStr(s + '.pas'));
    end;
    outline(fOut,'');
end;

procedure  TDelphiClassWriter.IntfWriteOrdinals;
var
 c:integer;
begin
 // if bDebug then
 if FclassDefs.Ordinals.count > 0 then
  begin
   outline(FInterfOut,'// ordinal types');
   outline(FInterfOut,cTabType);
   for c := 0 to FclassDefs.Ordinals.Count - 1 do
     outline(FInterfOut,'  ' + StringReplace(FclassDefs.Ordinals[c], '=', ' = ', []) + ';');
    outline(FInterfOut,'');
  end;
end;


procedure  TDelphiClassWriter.IntfWriteConsts;
var
 c:integer;
begin
 if FclassDefs.Consts.Count > 0 then
    begin
      outline(FInterfOut,'// constants for enumerations');
      outline(FInterfOut,cTabconst);
      for c := 0 to FclassDefs.Consts.Count - 1 do
        outline(FInterfOut,cTabC + ReplaceStr(FclassDefs.Consts[c], '=''', ' = ''') + ';');
      outline(FInterfOut,'');
    end;
end;

procedure  TDelphiClassWriter.IntfwriteEnums(fOut:TOutputUnit);
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
      outline(fOut,'// enumerations');
      outline(fout,cTabType);
      outline(fout,cTabc+'EnumPropIndexer=(tePiValue,tePiDoc);');
      for c := 0 to FclassDefs.Enums.Count - 1 do

      begin
        e:=TEnumDef(FclassDefs.Enums.Objects[c]);
        s:=cTabt+e.Name+' = (';
        // TJobTipoS:TJobTipoStrings=('Nullo','R','M','S','S3U','S3I','GCE','GCS','BKD','EP','EXP','IMP');
        sArrayDeclbase:=cTabc+e.Name+'Strings:t'+e.name+'Strings=(';
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

        outline(fout,s);
        sa:=cTabt+e.Name+'Strings=array['+e.Elements[0]+'..'+e.Elements[e.Elements.Count-1]+',tePiValue..tePiDoc] of String;';
        outline(fout,sa);
        outline(fOut,'');
        arrayDecl.Add('');


      end;
      outline(fOut,'');
      outline(fOut,cTabConst);
      for c:=0 to arrayDecl.Count-1 do
        begin
          outline(fOut,arraydecl[c]);
        end;

    end;
  end;

procedure  TDelphiClassWriter.IntfwriteEnumsHelpers(fOut:TOutputUnit);
  var  i:integer;
       e:TenumDef;
       sName:String;
  begin
   if FclassDefs.Enums.Count > 0 then
    begin
    outline(fOut,'');
    outline(fOut,cTabtype);
     for i:=0 to FclassDefs.Enums.Count-1 do
      begin
        sname:=FclassDefs.Enums[i];
        e:=TenumDef(FclassDefs.Enums.Objects[i]);
        outline(fOut,cTabT + e.Name + 'helper = record helper for t' + e.Name);
        outline(fOut,'   private');
        outline(fOut,'    procedure setAsString (value:String);');
        outline(fOut,'    function getAsString : string;');
        outline(fOut,'    function getDocumentation : string;');
        outline(fOut,'   public');
        outline(fOut,'    function GetListValues:TStringList;');
        outline(fOut,'    function GetListDocs:TStringList;');
        outline(fOut,'    property AsString:String read getASstring write setAsString;');
        outline(fOut,'    property Documentation:String read getDocumentation;');
        outline(fOut,'   end;');
        outline(fOut,'');
      end;
    end;
  end;

procedure TDelphiClassWriter.IntfWriteClasses;
var c,p:integer;
    bQualified: boolean;
    lIsInheritedClass: boolean;
    aClass : tClassDef;
    aProp : tProperty;
    s:String;
begin
  for c := 0 to FclassDefs.Count - 1 do
    begin
      aClass := tClassDef(FclassDefs.Objects[c]);
      outLine(fInterfOut,cTabconst);
      outLine(fInterfOut,'  sn' + aClass.Name + ' = ''' + aClass.Name + ''';');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'A' then // Attribute
        begin
          oute(fInterfOut,'  an');
          bQualified := FclassDefs.AttributesQualified;
        end
        else // Element
        begin
          oute(fInterfOut,'  sn');
          bQualified := FclassDefs.ElementsQualified;
        end;

        if FALSE {bQualified} then
        begin
          if aProp.NameSpace = '' then
            aProp.NameSpace := FclassDefs.NameSpacePrefix;

          if aProp.NameSpace = '' then // error
            outLine(fInterfOut,aClass.Name + '_' + aProp.Name + ' = ''' + aProp.NameSpace
              + ':' + aProp.Name + '''; // missing Namespace')
          else
            outLine(fInterfOut,aClass.Name + '_' + aProp.Name + ' = ''' + aProp.NameSpace
              + ':' + aProp.Name + ''';');
        end
        else
        begin
          // unqualified
          outLine(fInterfOut,aClass.Name + '_' + aProp.Name + ' = ''' + aProp.Name +
            ''';');
        end
      end;

      // ==========================
      // WRITE THE CLASS DEFINITION
      // ==========================

      outLine(fInterfOut,'');
      outLine(fInterfOut,cTabtype);
      lIsInheritedClass := not aClass.IsExtensionOf.IsEmpty;
      if lIsInheritedClass then
        outLine(fInterfOut,cTabClass + 'T' + aClass.Name + ' = class(' + aClass.IsExtensionOf + ')')
      else
        outLine(fInterfOut,cTabClass + 'T' + aClass.Name + ' = class');





      // =======================
      // write private variables
      // =======================

      outLine(fInterfOut,cTabprivate);
      outLine(fInterfOut,'    F_NameSpaceAlias: string;');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList then
        begin
          // max set or unbounded -> create a list
          outLine(fInterfOut,cTabF + aProp.Name + ': TStringList; // of ' +
            aProp._Type + '(' + aProp.Base + ')');
        end
        else if (aProp.maxOccurs = cScalar) then
        begin
          // adjust properties of transcoded ordinal type
          s := FclassDefs.Ordinals.Values[aProp._Type];
          if s <> '' then
          begin
            if FclassDefs.bDebug then
              outLine(fInterfOut,'//  ' + aProp._Type + ' = ' + s + ' / simple = ' + IntToStr(
                ord(aProp.PropertyType)));
            aProp._Type := s;
            // gp aProp.FSimple := true;
          end;
          outLine(fInterfOut,cTabF + aProp.Name + ': ' + aProp._Type + '; // '
            + '(' + aProp.Base + ')');

          if aProp.IsOptional then
            outLine(fInterfOut,cTabF + aProp.Name + '_IsSet_' + ': boolean;');
        end;
      end;

      // write getter setter function headers for optional parameters
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if not aProp.IsList and aProp.IsOptional then
          outLine(fInterfOut,'    procedure Set' + aProp.Name + '(value:' + aProp._Type +
            ');');
      end;

      outLine(fInterfOut,cTabpublic);

      outLine(fInterfOut,cTabConstrC);
      outLine(fInterfOut,fTabConstr);
      outLine(fInterfOut,cTabdestr);
      outLine(fInterfOut,'    class function _nsURI_:string;');
      outLine(fInterfOut,fTabSave);
      outLine(fInterfOut,cTabProp + '_NameSpaceAlias: string read F_NameSpaceAlias write F_NameSpaceAlias;');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList then
          outLine(fInterfOut,cTabProp + aProp.Name + ': TStringList' + ' read F' +
            aProp.Name + ' write F' + aProp.Name + '; // of ' + aProp._Type)
        else if (aProp.maxOccurs = cScalar) then
        begin
          if aProp.IsOptional then
          begin
            outLine(fInterfOut,cTabProp + CheckPascalReserved(aProp.Name) + ': ' + aProp._Type
              + ' read F' + aProp.Name + ' write Set' + aProp.Name + ';');
            outLine(fInterfOut,cTabProp + aProp.Name + '_IsSet_' + ':boolean read F' +
              aProp.Name + '_IsSet_;');
          end
          else
            outLine(fInterfOut,cTabProp + CheckPascalReserved(aProp.Name) + ': ' + aProp._Type
              + ' read F' + aProp.Name + ' write F' + aProp.Name + ';');
        end;
      end;
      outLine(fInterfOut,cTabend);
      outLine(fInterfOut,'');
    end;

end;


procedure TDelphiClassWriter.WriteInterface;
var c:integer;

 begin
    IntfWriteUnitHeader(FinterfOut,FclassDefs.Usess);
    IntfWriteOrdinals;
    IntfWriteConsts;
    IntfWriteEnums(FinterfOut);
    IntfwriteEnumsHelpers(FinterfOut);
    IntfWriteClasses;

end;

procedure  TDelphiClassWriter.ImplWriteUnitHeader(fOut:TOutputUnit);
begin
  outline(fOut,'implementation');
  outline(fOut,'uses');
  outline(fOut,'  SysUtils ');
//    outline('  mylib;');
  outline(fOut,';');
  outline(fOut,'');
  if fOut=fImplOut then
   begin
    outline(fOut,cTabConst);
    outline(fOut,'  thisNamespaceURI = ''' + FclassDefs.targetNamespace + ''';');
    outline(fOut,'  defNamespaceAlias = ''' + FclassDefs.NameSpacePrefix + ''';');
    outline(fOut,'');
   end;
end;

procedure  TDelphiClassWriter.ImplWriteEnumsHelpers(fOut:TOutputUnit);
 var  i:integer;
       e:TenumDef;
       sName:String;
  begin
   if FclassDefs.Enums.Count > 0 then
    begin
    outLine(fOut,'');

     for i:=0 to FclassDefs.Enums.Count-1 do
      begin
        sname:=FclassDefs.Enums[i];
        e:=TenumDef(FclassDefs.Enums.Objects[i]);
      outLine(fOut,'{ T' + Sname + ' }');
      outLine(fOut,'');
      // ----------------------------------------------------------------
      // create class function to read the NamespaceURI
      outLine(fOut,'procedure t'+sname+'Helper.setAsString(value:String);');
      outLine(fOut,' var v:t'+sname+';');
      outLine(fOut,'     i:t'+sname+';');
      outLine(fOut,'     found:Boolean;');
      outLine(fOut,'begin');
      outLine(fOut,'  v := '+e.NullValueName+';');
      outLine(fOut,'  i := '+e.NullValueName+';');
      outLine(fOut,'  repeat');
      outLine(fOut,'   inc(i);');
      outLine(fOut,'   if c'+sname+'Strings[i,tePivalue]=value then');
      outLine(fOut,'    v:=i;');
      outLine(fOut,'  until (v<>'+e.NullValueName+') or (i=high(t'+sname+'));');
      outLine(fOut,'  self:=v;');
      outLine(fOut,'end; // procedure setAsString');
      outLine(fOut,'');

      outLine(fOut,'function t'+sname+'Helper.getAsString:String;');
      outLine(fOut,'');
      outLine(fOut,'begin');
      outLine(fOut,'  result:=c'+sname+'Strings[self,tePivalue];');
      outLine(fOut,'end; // function getAsString');
      outLine(fOut,'');

      outLine(fOut,'function t'+sname+'Helper.getDocumentation:string;');
      outLine(fOut,'');
      outLine(fOut,'begin');
      outLine(fOut,'  result:=c'+sname+'Strings[self,tePiDoc];');
      outLine(fOut,'end; // function getDocumentation');
      outLine(fOut,'');

      outLine(fOut,'function t'+sname+'Helper.GetListValues:TStringList;');
      outLine(fOut,' var i:t'+sname+';');
      outLine(fOut,'begin');
      outLine(fOut,'  result:=TStringList.create;');
      outLine(fOut,'  for i:=low(t'+sname+') to high(t'+sname+') do');
      outLine(fOut,'  result.add (c'+sname+'Strings[i,tePivalue]);');
      outLine(fOut,'end; // procedure GetListValues');
      outLine(fOut,'');

      outLine(fOut,'function t'+sname+'Helper.GetListDocs:TStringList;');
      outLine(fOut,' var i:t'+sname+';');
      outLine(fOut,'begin');
      outLine(fOut,'  result:=TStringList.create;');
      outLine(fOut,'  for i:=low(t'+sname+') to high(t'+sname+') do');
      outLine(fOut,'  result.add (c'+sname+'Strings[i,tePiDoc]);');
      outLine(fOut,'end; // procedure GetListDocs');
      outLine(fOut,'');
      end;
    end;
  end;

procedure  TDelphiClassWriter.ImplWriteClasses(fOut:TOutputUnit);

var c,p:integer;
    aClass : tClassDef;
    bCallSimpleConstructor:Boolean;
    bInIf:Boolean;
    aProp:tProperty;

begin
  for c := 0 to FclassDefs.Count - 1 do
    begin
      aClass := tClassDef(FclassDefs.Objects[c]);
      outLine(fOut,'{ T' + aClass.Name + ' }');
      outLine(fOut,'');
      // ----------------------------------------------------------------
      // create class function to read the NamespaceURI
      outLine(fOut,'class function t' + aClass.Name + '._nsURI_;');
      outLine(fOut,'begin');
      outLine(fOut,'  result := thisNameSpaceURI;');
      outLine(fOut,'end; // class function _nsURI_');
      outLine(fOut,'');

      // ----------------------------------------------------------------
      // create simple constructor first
      bCallSimpleConstructor := false;
      outLine(fOut,'constructor T' + aClass.Name + '.Create;');
      outLine(fOut,'begin');
      outLine(fOut,'  _NamespaceAlias := defNamespaceAlias;');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base <> 'A' then
          if aProp.IsList then
          begin
            bCallSimpleConstructor := true;
            outLine(fOut,'  F' + aProp.Name + ' := TStringlist.Create(True);');
          end;
      end;
      outLine(fOut,'end; // constructor ...');
      outLine(fOut,'');

      // ----------------------------------------------------------------
      // create contructor from Node now
      outLine(fOut,'constructor t' + aClass.Name + '.Create(aRoot:'+fnodeclass+');');
      outLine(fOut,'var');
      outLine(fOut,'  xn: '+fnodeclass+';');
      outLine(fOut,'  sn: string;');
      outLine(fOut,'  i: integer;');
      outLine(fOut,'  thisURI: string;');
      // create variables for list elements
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList and  (aProp.PropertyType=ptComplex) then
          outLine(fOut,'  a' + aProp.name + ': ' + aProp._type + ';');
      end;
      outLine(fOut,'begin');
      if bCallSimpleConstructor then
      begin
        outLine(fOut,'  Create;');
        outLine(fOut,'');
      end;

      outLine(fOut,'  F_NameSpaceAlias := aRoot.'+fNodeNameSpace+';');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'S' then
        begin
          // simple content
          outLine(fOut,'');
          outLine(fOut,'  F' + aProp.Name + ' := aRoot.text; // simple content');
          outLine(fOut,'');
          break; // only one allowed
        end;
      end;

      // create attributes
      if aClass.NumAttributeProperties > 0 then
      begin
        outLine(fOut,'  for i:=0 to aRoot.'+fNodeAttributeNodesCount+' -1 do');
        outLine(fOut,'  begin');
        outLine(fOut,'    sn := NamePart(aRoot.'+fNodeAttributeNodeNames+');');
        for p := 0 to aClass.Properties.Count - 1 do
        begin
          aProp := tProperty(aClass.Properties.Objects[p]);
          if aProp.Base = 'A' then // Attributes
          begin
           case aprop.PropertyType of
                      ptSimple:begin
                                outLine(fOut,'    if sn = an' + aClass.Name + '_' + aProp.Name +
                                  ' then');
                                if aProp._Type = dInteger then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := StrToIntDef(aRoot.'+fNodeAttributes+'[i], 0);')
                                else if aProp._Type = dLong then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := StrToInt64Def(aRoot.'+fNodeAttributes+'[i], 0);')
                                else if aProp._Type = dFloat then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := DefStrToFloat(aRoot.'+fNodeAttributes+'[i], 0);')
                                else if aProp._Type = dBoolean then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := (aRoot.'+fNodeAttributes+'[i] = ''true'');')
                                else if aProp._Type = dDate then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := DateFromXMLDateTime(aRoot.'+fNodeAttributes+'[i]);')
                                else if aProp._Type = dTime then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := TimeFromXMLDateTime(aRoot.'+fNodeAttributes+'[i]);')
                                else if aProp._Type = dDateTime then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := DateTimeFromXMLDateTime(aRoot.'+fNodeAttributes+'[i]);')
                                else if aProp._Type = dByte then
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := StrToIntDef(aRoot.'+fNodeAttributes+'[i], 0);')
                                else
                                  outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    ' := aRoot.'+fNodeAttributes+'[i]; // ' + aProp._Type);
                               end;
                        ptEnum:begin
                                 outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) +
                                    '.AsString := aRoot.'+fNodeAttributes+'[i]; // ' + aProp._Type);
                               end;
                      ptComplex:raise(exception.Create('Complex Attribute not expected here (Create)'));
                  end; // case
          end; // if aProp.Base = 'A' then
        end;
        outLine(fOut,'  end;');
        outLine(fOut,'');
      end;

      if aClass.NumElementProperties > 0 then
      begin
        // create elements
        outLine(fOut,'  xn := aRoot.'+fNodeFirstChild+';');
        outLine(fOut,'  while Assigned(xn) do');
        outLine(fOut,'  begin');
        outLine(fOut,'    sn := '+fNodeLocalname+';');
        outLine(fOut,'    thisURI := xn.'+fNodeNameSpace+';');
        bInIf := false;
        for p := 0 to aClass.Properties.Count - 1 do
        begin
          aProp := tProperty(aClass.Properties.Objects[p]);
          if (aProp.Base = 'E') or (aProp.Base = 'X') then // Element or Reference
          begin
            if bInIf then
              oute(fOut,'    else ')
            else
              oute(fOut,'    ');
            if aProp.PropertyType<>ptComplex then
              outLine(fOut,'if (sn = sn' + aClass.Name + '_' + aProp.name + ') then')
            else
            begin
              outLine(fOut,'if (sn = sn' + aClass.Name + '_' + aProp.name + ')');
              outLine(fOut,'      and ((thisURI='''') or (' + aProp._type + '._nsURI_'
                + ' = thisURI)) then');
            end;
            if aProp.IsList then
            begin
              outLine(fOut,'    begin');
              if aProp.PropertyType=ptSimple then
              begin
                outLine(fOut,'      // list of simple type');
                outLine(fOut,'      F' + aProp.Name + '.Add(xn.text);');
              end
              else
              begin
                outLine(fOut,'      a' + aProp.Name + ' := ' + aProp._type +
                  '.Create(xn);');
                outLine(fOut,'      F' + aProp.Name + '.AddObject(''?'', a' +
                  aProp.Name + ');');
              end;
              outLine(fOut,'    end');
            end
            else
            case aProp.PropertyType of
                 ptSimple:begin
                            if aProp._Type = dInteger then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'StrToIntDef(xn.text, 0)')
                            else if aProp._Type = dLong then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'StrToInt64Def(xn.text, 0)')
                            else if aProp._Type = dFloat then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'DefStrToFloat(xn.text, 0)')
                            else if aProp._Type = dBoolean then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                '(xn.text = ''true'')')
                            else if aProp._Type = dDate then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'DateFromXMLDateTime(xn.text) // ' + aProp._Type)
                            else if aProp._Type = dTime then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'TimeFromXMLDateTime(xn.text) // ' + aProp._Type)
                            else if aProp._Type = dDateTime then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'DateTimeFromXMLDateTime(xn.text) // ' + aProp._Type)
                            else if aProp._Type = dByte then
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' +
                                'StrToIntDef(xn.text, 0)')
                            else
                              outLine(fOut,'      ' + CheckPascalReserved(aProp.Name) + ' := ' + ' xn.text // ' +
                                aProp._Type)
                          end; // ptsimple
                ptCOmplex:outLine(fOut,'      F' + aProp.Name + ' := ' + aProp._type +'.Create(xn)');
                   ptEnum:outLine(fOut,'      ' + CheckPascalReserved(aProp.Name)+'.AsString' + ' := ' + ' xn.text // ' +aProp._Type);
             end;
            bInIf := true;
          end; // if aProp.Base = 'E' then
        end; // for p := 0 to aClass.Properties.Count - 1 do

        if bInIf then
          outLine(fOut,'    else;');

        outLine(fOut,'    xn := xn.NextSibling;');
        outLine(fOut,'  end; // while Assigned(xn) do ...');
      end;
      outLine(fOut,'end; // constructor ...');
      outLine(fOut,'');

      // ----------------------------------------------------------------
      // destructor
      outLine(fOut,'destructor t' + aClass.name + '.Destroy;');
      outLine(fOut,'begin');
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.IsList or (aProp.PropertyType=ptComplex) then
          outLine(fOut,'  F' + aProp.Name + '.Free;')
      end;
      outLine(fOut,'  inherited;');
      outLine(fOut,'end; // destructor ...');
      outLine(fOut,'');

      // ----------------------------------------------------------------
      // property Setters
      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if not aProp.IsList and aProp.IsOptional then
        begin
          outLine(fOut,'procedure t' + aClass.name + '.Set' + aProp.Name + '(value:' +
            aProp._Type + ');');
          outLine(fOut,'begin');
          outLine(fOut,'  F' + aProp.Name + ' := value;');
          outLine(fOut,'  F' + aProp.Name + '_IsSet_ := true;');
          outLine(fOut,'end;');
          outLine(fOut,'');
        end;
      end;

      // ----------------------------------------------------------------
      // procedure Save
      outLine(fOut,'procedure t' + aClass.name + '.Save(aNode:'+fnodeclass+');');
      outLine(fOut,'var');
      outLine(fOut,'  xn: '+fnodeclass+';');
      outLine(fOut,'  i: integer;');
      outLine(fOut,'begin');
      if fUseTXMLDocument then oute(fout,'(*');
      outLine(fOut,'  if aNode.name = '''' then');
      outLine(fOut,'    aNode.name := nsName(_NameSpaceAlias, ''' + aClass.name +''')');
      outLine(fOut,'  else if pos(colon, aNode.name) = 0 then');
      outLine(fOut,'    aNode.name := nsName(_NameSpaceAlias, aNode.name);');
      if fUseTXMLDocument then oute(fout,'*) // Must chet to see if it is necessary with TXMLDocument');
      outLine(fOut,'');
      outLine(fOut,'  if _NameSpaceAlias <> '''' then');
      outLine(fOut,'  begin');
      outLine(fOut,'    xn := aNode;');
      outLine(fOut,'    while Assigned(xn.ParentNode) do');
      outLine(fOut,'      xn := xn.ParentNode;');
      outLine(fOut,'    xn.'+fNodeAttributes+'[''xmlns:'' + _NameSpaceAlias] := thisNameSpaceURI;');
      outLine(fOut,'  end;');
      outLine(fOut,'');

      for p := 0 to aClass.Properties.Count - 1 do
      begin
        aProp := tProperty(aClass.Properties.Objects[p]);
        if aProp.Base = 'S' then
        begin
          // simple content
          outLine(fOut,'  aNode.text := F' + aProp.Name + '; // simple content');
          outLine(fOut,'');
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
              outLine(fOut,'  if ' + aProp.Name + '_IsSet_ then');
              oute(fOut,'  ');
            end;
            case aprop.PropertyType of
                 ptSimple:Begin
                            if aProp._Type = dInteger then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := ' + 'IntToStr(F' + aProp.Name + ');')
                                // ???
                  // outLine(fOut,Format('  aNode.attribute[an%s_%s] := IntToStr(F%s);',
                  //   aClass.Name, aProp.Name, aProp.Name));
                            else if aProp._Type = dLong then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := '
                                + 'IntToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dFloat then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := '
                                + 'MyFloatToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dBoolean then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := '
                                + 'BoolToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dDate then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name
                                + '] := '
                                + 'DateToXMLDateTime(F' + aProp.Name + ');')
                            else if aProp._Type = dTime then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := '
                                + 'TimeToXMLDateTime(F' + aProp.Name + ');')
                            else if aProp._Type = dDateTime then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := '
                                + 'DateTimeToXMLDateTime(F' + aProp.Name + ');')
                            else if aProp._Type = dByte then
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name +
                                '] := '
                                + 'IntToStr(F' + aProp.Name + ');')
                            else
                              outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name
                                + '] := ' + 'F' + aProp.Name + ';');
                           End;
                    ptEnum:begin
                            outLine(fOut,'  aNode.'+fNodeAttributes+'[an' + aClass.Name + '_' + aProp.Name
                                + '] := ' + 'F' + aProp.Name + '.AsString;');
                           end;
                    ptComplex:raise(exception.Create('Complex Attribute not expected here (Save)'));
                  end; // Case
          end; // if aProp.Base = 'A' then
        end; // for p := 0 to aClass.Properties.Count - 1 do
        outLine(fOut,'');
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
              outLine(fOut,'  // element "' + aProp.Name +
                '" is TStringlist');
              if aProp.PropertyType=ptSimple then
                outLine(fOut,'  // but of simple elements');
              outLine(fOut,'  if Assigned(F' + aProp.Name + ') then');
              outLine(fOut,'    for i:=0 to F' + aProp.Name + '.Count - 1 do');
              outLine(fOut,'    begin');
              if aProp.Base = 'E' then
                outLine(fOut,'      xn := aNode.'+fNodeAddChild+'(nsName(_NameSpaceAlias, '
                  + 'sn' + aClass.Name + '_' + aProp.name + '));')
              else
                outLine(fOut,'      xn := aNode.'+fNodeAddChild+'('
                  + 'sn' + aClass.Name + '_' + aProp.name + ');');
              if aProp.PropertyType=ptSimple then
                outLine(fOut,'      xn.text := F' + aProp.Name + '.Strings[i];')
              else
              begin
                outLine(fOut,'      ' + aProp._type + '(F' + aProp.Name +
                  '.Objects[i]).Save(xn);');
              end;
              outLine(fOut,'    end; // for i:=0 to ...');
            end
            else // no list
            begin
              if aProp.PropertyType<>ptComplex then
              begin
                if aProp.IsOptional then
                begin
                  outLine(fOut,'  if ' + aProp.Name + '_IsSet_ then');
                  outLine(fOut,'  begin');
                  outLine(fOut,'    xn := aNode.'+fNodeAddChild+'(nsName(_NameSpaceAlias, '
                    + 'sn' + aClass.Name + '_' + aProp.name + '));');
                  oute(fOut,'  ');
                end
                else
                  outLine(fOut,'  xn := aNode.'+fNodeAddChild+'(nsName(_NameSpaceAlias, '
                    + 'sn' + aClass.Name + '_' + aProp.name + '));');
                case aprop.PropertyType of
                  ptSimple:begin
                            if (aProp._Type = dString) then
                              outLine(fOut,'  xn.text := ' + 'F' + aProp.Name + ';')
                            else if aProp._Type = dDate then
                              outLine(fOut,'  xn.text := ' + 'DateToXMLDateTime(F' + aProp.Name +
                                ');')
                            else if aProp._Type = dDateTime then
                              outLine(fOut,'  xn.text := ' + 'DateTimeToXMLDateTime(F' +
                                aProp.Name + ');')
                            else if aProp._Type = dInteger then
                              outLine(fOut,'  xn.text := ' + 'IntToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dLong then
                              outLine(fOut,'  xn.text := ' + 'IntToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dFloat then
                              outLine(fOut,'  xn.text := ' + 'MyFloatToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dBoolean then
                              outLine(fOut,'  xn.text := ' + 'BoolToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dTime then
                              outLine(fOut,'  xn.text := ' + 'TimeToXMLDateTime(F' + aProp.Name
                                + ');')
                            else if (aProp._Type = dDatetime) then
                              outLine(fOut,'  xn.text := ' + 'DateTimeToXMLDateTime(F' +
                                aProp.Name + ');')
                            else if (aProp._Type = dDate) then
                              outLine(fOut,'  xn.text := ' + 'DateToXMLDateTime(F' + aProp.Name
                                + ');')
                            else if aProp._Type = dByte then
                              outLine(fOut,'  xn.text := ' + 'IntToStr(F' + aProp.Name + ');')
                            else if aProp._Type = dString then
                              outLine(fOut,'  xn.text := ' + 'F' + aProp.Name + ';')
                            else if aProp._Type = 'uxs.tnormalizedString' then
                              outLine(fOut,'  xn.text := ' + 'F' + aProp.Name + ';')
                            else if aProp._Type = 'uxs.tbase64Binary' then
                              outLine(fOut,'  xn.text := ' + 'F' + aProp.Name + ';')
                            else
                             outLine(fOut,'  xn.text := ' + 'F' + aProp.Name + ';');
                           end ;
                  ptComplex:raise(exception.Create('Complex Property not expected here (Save)'));
                  ptEnum:outLine(fOut,'  xn.text := ' + 'F' + aProp.Name + '.AsString;');
                end;



                if aProp.IsOptional then
                  outLine(fOut,'  end;');
              end // if aProp.simple then
              else
              begin
                outLine(fOut,'  if Assigned(F' + aProp.Name + ') then');
                outLine(fOut,'  begin');
                outLine(fOut,'    xn := aNode.'+fNodeAddChild+'('
                  + 'sn' + aClass.Name + '_' + aProp.name + ');');
                outLine(fOut,'    F' + aProp.Name + '.Save(xn);');
                outLine(fOut,'  end;');
              end
            end;
          end; // if aProp.Base = 'E' then
        end; // for p := 0 to aClass.Properties.Count - 1 do
      end;
      outLine(fOut,'end; // procedure save');
      outLine(fOut,'');
    end;

    outLine(fOut,'end.');
 end;


procedure TDelphiClassWriter.WriteImplementation;
begin
  ImplWriteUnitHeader(fImplOut);
  ImplwriteEnumsHelpers(fImplOut);
  ImplWriteClasses(fImplOut);

end;





end.
