unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, vte_edittree, Forms, Controls, StdCtrls, ExtCtrls, Virtualtrees,
  JLabeledIntegerEdit, Dialogs, ActnList, Buttons,FileUtil,strutils, Graphics, Classes
  ,LocalizedForms;

type

  { TForm3 }

  TForm3 = class(TLocalizedForm)
    Action1: TAction;
    ActionList1: TActionList;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;   {Ok}
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;    {Hledat rok na Internetu}
    CheckBox1: TCheckBox;
    CheckBoxTr: TCheckBox;    { přepínač nový seriál/změna seriálu pro strom}
    CheckBoxNs: TCheckBox;    { přepínač nový seriál/změna seriálu pro Název Seriálu}
    CheckBoxRo: TCheckBox;    { přepínač nový seriál/změna seriálu pro Rok}
    CheckBoxUm: TCheckBox;    { přepínač nový seriál/změna seriálu pro Umístění}
    CheckBoxMe: TCheckBox;    { přepínač nový seriál/změna seriálu pro Medium}
    ComboBox1: TComboBox;
    ImgListForm3: TImageList;
    JLabeledIntegerEdit1: TJLabeledIntegerEdit;
    JLabeledIntegerEdit2: TJLabeledIntegerEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    VET: TVirtualEditTree;
    procedure Action1Update(Sender: TObject);
    procedure Button1Click(Sender: TObject);   {Přidej root node}
    procedure Button2Click(Sender: TObject);    {Přidej child node}
    procedure Button3Click(Sender: TObject);     {Smaž node}
    procedure Button4Click(Sender: TObject);     {OK}
    procedure Button5Click(Sender: TObject);      {Cancel}
    procedure Button6Click(Sender: TObject);      {Vytvoř strom pomocí Form4}
    procedure Button7Click(Sender: TObject);      {Hledat rok na Internetu}
    procedure CheckBox1Change(Sender: TObject);    {index umístění}
    procedure CheckBoxMeChange(Sender: TObject); {přepínač nový seriál/změna seriálu pro Medium}
    procedure CheckBoxNsClick(Sender: TObject); {přepínač nový seriál/změna seriálu pro Název Seriálu}
    procedure CheckBoxRoChange(Sender: TObject); {přepínač nový seriál/změna seriálu pro Rok}
    procedure CheckBoxTrClick(Sender: TObject);  {přepínač nový seriál/změna seriálu pro Strom}
    procedure CheckBoxUmChange(Sender: TObject); {přepínač nový seriál/změna seriálu pro Umístění}
    procedure FormShow(Sender: TObject);         { Uprav Form3 pro zobrazení}
    procedure VETChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VETFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure VETFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VETGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure VETGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VETStructureChange(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Reason: TChangeReason);{Spočítá dynamicky podle ukazatelů počet sezón,disků a dílů do Memo2}
    procedure ZmenStavCheckboxu(b,c:boolean);  {kupodivu schová/ukáže checkboxy
                                                s nimi svázané prvky pro form3}
    procedure VytvorStrom(PocetSezon,PocetDisku,PocetDilu:byte);
    procedure odhadniStromZVyberu;  {Vytvoří strom pro vybrané řádky při Hromadná změna - komplexní}
  private
    { private declarations }
  public
    { public declarations }
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  Form3: TForm3;
  CelkovyPocetDilu: Byte;      {Celkový počet dílů uživatelsky vytvořeného stromu}
  CelkovyPocetDisku:Byte;      {Celkový počet disků uživatelsky vytvořeného stromu}
  RadkyVyberu:integer;         {Počet vybraných řádků při volbě Hromadná změna - komplexní}
  NepridavatDily:boolean;      {Zda lze přidávat další díly při Hromadná změna - komplexní }
  NeubiratDily:boolean;




implementation
   uses unit1,unit4,unit8, {chci pracovat s objekty Form1,Form4 a
                                  nepotřebuju je v deklaraci}
        unGlobalScraper;  // je tam timer + kód na využití frmNotScraped (unNotScraped)
type
  PTreeData = ^TTreeData;                         { Ukazatel na data v node }
  TTreeData = record
    Column0: String;
  end;

{$R *.frm}

{ TForm3 }


procedure TForm3.FormShow(Sender: TObject);   { Uprav Form3 pro zobrazení}
var
  PomPng:Tbitmap;
begin
  PomPng:=TBitmap.Create;
  if  Form1.ZjistiPromNovySerial() then
      begin                                    { Uprav Form3 pro Vytvoř seriál}
        ZmenStavCheckboxu(false,true);
        NepridavatDily:=false;
        NeubiratDily:=false;
        Button4.Enabled:=True;
        ImgListForm3.GetBitmap(0,PomPng);       { Ikonka pro Vytvoř seriál}
        Icon.Assign(PomPng);
        Form3.Caption:=rsVytvoSeriL;
      end
                                  else
      begin                                    { Uprav Form3 pro Hromadná změna - komplexní}
        ZmenStavCheckboxu(true,false);
        RadkyVyberu:=Form1.DBGrid1.SelectedRows.Count;
        MessageDlg(Format(rsPoEtDiskVeVB, [inttostr(RadkyVyberu)]),
          mtInformation, [mbOK, mbCancel], 0);
        ImgListForm3.GetBitmap(1,PomPng);        { Ikonka pro Seriál - komplexní změna}
        Icon.Assign(PomPng);
        Form3.Caption:=rsSeriLHromadn;
      end;
 PomPng.Free;

end;

procedure TForm3.Action1Update(Sender: TObject);  { Schovej přidání nodes}
begin
  if CheckBoxTr.Checked then
     begin
       if (CelkovyPocetDisku > RadkyVyberu) then
          begin
            NepridavatDily:=True;
            NeubiratDily:=False;
            Button4.Enabled:=False;
          end;

       if (CelkovyPocetDisku < RadkyVyberu) then
          begin
            NeubiratDily:=True;
            NepridavatDily:=False;
            Button4.Enabled:=False;
          end;
       if CelkovyPocetDisku = RadkyVyberu then
          begin
             Button4.Enabled:=True;
             NepridavatDily:=False;
             NeubiratDily:=False;
           end;
     end;
end;

procedure TForm3.Button1Click(Sender: TObject);  { Přidej root node }
Var                                              { tady to je seriál }
  Data: PTreeData;
  XNode : PVirtualNode;
Begin

  XNode:=VET.AddChild(nil);

  if VET.AbsoluteIndex(XNode) > -1 then
  Begin
   Data := VET.GetNodeData(Xnode);
   Data^.Column0:= 'series' ;
  End;
End;

procedure TForm3.Button2Click(Sender: TObject);   { Přidej child node a přečísluj
                                                    všechny siblings }
var
  XNode, XNodeParent: PVirtualNode;
  Data: PTreeData;
  Spom: String;
  i:integer;
begin
  if not Assigned(VeT.FocusedNode) then Exit;
    VET.Expanded[VET.FocusedNode]:=True;
    case VET.GetNodeLevel(VET.FocusedNode) of       { Ne pro level Díly}
      0 : Spom:= rsSezNa;
      1 : if not(NepridavatDily) then
            Spom:= rsDisk
                                 else
            begin
             MessageDlg(Format(rsPoEtVybranCh, [inttostr(RadkyVyberu)]),
               mtWarning, [mbOK], 0);

             exit
            end;
      2 : Spom:= rsDL;
      3 : exit
    end;
    XNode := VeT.AddChild(VET.FocusedNode);
    XNodeParent:=Xnode^.Parent;
    XNode:=XNodeParent^.FirstChild;
    for i:=1 to XNodeParent^.ChildCount do
      begin
        Data := VET.GetNodeData(Xnode);
        Data^.Column0:= Spom +  inttostr(i);
        if i=XNodeParent^.ChildCount then  exit
          else Xnode:=VET.GetNextSibling(Xnode);
      end;

end;


procedure TForm3.Button3Click(Sender: TObject);    { Smaž node a přečísluj všechny siblings }
var
  XNode, XNodeParent: PVirtualNode;
  Data: PTreeData;
  Spom: String;
  i:integer;

begin
    if not Assigned(VeT.FocusedNode) then Exit;
    VET.Expanded[VET.FocusedNode]:=True;
    case VET.GetNodeLevel(VET.FocusedNode) of       { '' pro Root level}
      0 : Spom:= '';
      1 : Spom:= rsSezNa;
      2 : if not(NeubiratDily) then
            Spom:= rsDisk
                                 else
            begin
             MessageDlg(Format(rsPoEtVybranCh, [inttostr(RadkyVyberu)]),
               mtWarning, [mbOK], 0);

             exit
            end;
      3 : Spom:= rsDL
    end;
    XNode := VET.FocusedNode;
    XNodeParent:=Xnode^.Parent;
    VET.DeleteSelectedNodes;
    XNode:=XNodeParent^.FirstChild;
    for i:=1 to XNodeParent^.ChildCount do
      begin
        Data := VET.GetNodeData(Xnode);
        Data^.Column0:= Spom +  inttostr(i);
        if i=XNodeParent^.ChildCount then  exit
          else Xnode:=VET.GetNextSibling(Xnode);
      end;

end;

procedure TForm3.Button4Click(Sender: TObject); { OK a pak vlož nový seriál do tabulky}
var
 XNodeRoot, XNodeSezona, XNodeDisk, XnodeDil : PVirtualNode;
 //i,j,z : byte;
 PomPocetDilu : string;
 PomPocetSezon : string;
 PocetSezon,PocetDisku,PocetDilu : byte;
 PomUm: String;
 PomNa: String;
begin
ModalResult:=mrOK;

If  Form1.ZjistiPromNovySerial()
                                         then
 begin {-------------------------------- začátek vlož nový seriál volba Vytvoř seriál}
    PocetSezon:=0;
     PocetDisku:=0;
     PocetDilu:=0;
     PomPocetDilu:='';
     PomPocetSezon:= '';
     Memo2.Clear;

       XNodeRoot   := VET.GetFirstLevel(0);
       XNodeSezona := VET.GetFirstLevel(1);
       XNodeDisk   := VET.GetFirstLevel(2);
       XnodeDil    := VET.GetFirstLevel(3);

       while (XNodeSezona <> nil) do
         begin
            PocetSezon := PocetSezon +1;
            If length(IntToStr(PocetSezon)) = 1 then
                    PomPocetSezon := 's0' + IntToStr(PocetSezon)
                     else
                    PomPocetSezon := 's'+ IntToStr(PocetSezon);
            while (XNodeDisk <> nil ) do
              begin
               PocetDisku := PocetDisku +1;
               while (XnodeDil <> nil ) do
                 begin
                  PocetDilu := PocetDilu +1;
                  If length(IntToStr(PocetDilu)) = 1 then
                    PomPocetDilu := PomPocetDilu + 'e0' + IntToStr(PocetDilu)
                     else
                    PomPocetDilu := PomPocetDilu +'e'+ IntToStr(PocetDilu) ;
                  XnodeDil := XnodeDil^.NextSibling;
                 end;
               XNodeDisk := XNodeDisk^.NextSibling;
               if (XnodeDisk <> nil) then {Pokud není disk poslední v akt. serii posuň se na další}
                  begin
                     XnodeDil :=  XNodeDisk^.FirstChild;
                  end;
               {Vytvoř řádek v tabulce }
                 Form1.ZQuery1.Append;  {vyzkoušet Append i Insert}
                      PomNa:=inttostr(PocetDisku);
                      if length(PomNa)=1 then PomNa:='0'+PomNa;
                      Form1.ZQuery1.FieldByName('NAZEV').AsString:= LabeledEdit1.Text+' '+PomNa;
                      Form1.ZQuery1.FieldByName('NAZEV_SERIALU').AsString:= LabeledEdit1.Text;
                      Form1.ZQuery1.FieldByName('ROK').AsString:= InttoStr(JLabeledIntegerEdit1.Value);
                      Form1.ZQuery1.FieldByName('DRUH').AsString:= 'series';
                      if CheckBox1.Checked then
                         begin
                           PomUm:=inttostr(JLabeledIntegerEdit2.Value+PocetDisku-1);
                           if length(PomUm) =1 then PomUm:='00'+PomUm;
                           if length(PomUm) =2 then PomUm:='0'+PomUm;
                           Form1.ZQuery1.FieldByName('UMISTENI').AsString:= LabeledEdit2.Text+
                           PomUm;
                         end
                                           else
                           Form1.ZQuery1.FieldByName('UMISTENI').AsString:= LabeledEdit2.Text;
                      Form1.ZQuery1.FieldByName('MEDIUM').AsString:= ComboBox1.Text;
                      Form1.ZQuery1.FieldByName('DILY_CELKEM').AsString:= IntToStr(CelkovyPocetDilu);
                      Form1.ZQuery1.FieldByName('DILY_NA_DISKU').AsString:= PomPocetDilu;
                      Form1.ZQuery1.FieldByName('SEZONA').AsString:= PomPocetSezon;
                      Form1.ZQuery1.FieldByName('STUBFILE').AsString:=  PomPocetSezon + PomPocetDilu +'.disc';
                      Form1.ZQuery1.FieldByName('DIRECTORY').AsString:= '\'+ Form1.validateFileName(LabeledEdit1.Text)+'\'+PomPocetSezon+'\';
               Form1.ZQuery1.Post;
               PomPocetDilu:='';
              end;
            XNodeSezona:=XNodeSezona^.NextSibling;
            if (XnodeSezona <> nil) then
               begin
                  XNodeDisk:=XNodeSezona^.FirstChild;

                   {
                    PocetDisku:=0;
                   }

               end;
            if (XNodeDisk  <> nil) then XnodeDil :=XNodeDisk^.FirstChild;
         end;
     // Form1.UlozZmenySQL; // zmněna se hlída přez zmenaVDatabazi viz zquery1.afterInsert;
 end   {-------------------------konec vlož nový seriál volba Vytvoř seriál}
                                 else
 begin {-------------------------začátek změň seriál volba Hromadná změna - komplexní}
   if  not(CheckboxTr.Checked) then  VytvorStrom(1,RadkyVyberu,1);
   PocetSezon:=0;
     PocetDisku:=0;
     PocetDilu:=0;
     PomPocetDilu:='';
     PomPocetSezon:= '';
     Memo2.Clear;

       XNodeRoot   := VET.GetFirstLevel(0);
       XNodeSezona := VET.GetFirstLevel(1);
       XNodeDisk   := VET.GetFirstLevel(2);
       XnodeDil    := VET.GetFirstLevel(3);

       while (XNodeSezona <> nil) do
         begin
            PocetSezon := PocetSezon +1;
            If length(IntToStr(PocetSezon)) = 1 then
                    PomPocetSezon := 's0' + IntToStr(PocetSezon)
                     else
                    PomPocetSezon := 's'+ IntToStr(PocetSezon);
            while (XNodeDisk <> nil ) do
              begin
               PocetDisku := PocetDisku +1;
               while (XnodeDil <> nil ) do
                 begin
                  PocetDilu := PocetDilu +1;
                  If length(IntToStr(PocetDilu)) = 1 then
                    PomPocetDilu := PomPocetDilu + 'e0' + IntToStr(PocetDilu)
                     else
                    PomPocetDilu := PomPocetDilu +'e'+ IntToStr(PocetDilu) ;
                  XnodeDil := XnodeDil^.NextSibling;
                 end;
               XNodeDisk := XNodeDisk^.NextSibling;
               if (XnodeDisk <> nil) then    {Pokud není disk poslední v akt. serii posuň se na další}
                  begin
                     XnodeDil :=  XNodeDisk^.FirstChild;
                  end;
               {edituj řádek v tabulce }
                 Form1.ZQuery1.GotoBookmark(Form1.dbgrid1.SelectedRows.Items[PocetDisku-1]); {To byla ale hnusná chyba :-) chce to víc odpočívat a spát}
                 Form1.ZQuery1.Edit;  {}
                 if  CheckBoxNs.Checked then
                  begin
                    PomNa:=inttostr(PocetDisku);
                    if length(PomNa)=1 then PomNa:='0'+PomNa;
                    Form1.ZQuery1.FieldByName('NAZEV').AsString:= LabeledEdit1.Text+' '+PomNa;
                    Form1.ZQuery1.FieldByName('NAZEV_SERIALU').AsString:= LabeledEdit1.Text;
                  end;
                 if CheckBoxRo.Checked then
                  Form1.ZQuery1.FieldByName('ROK').AsString:= InttoStr(JLabeledIntegerEdit1.Value);
                  Form1.ZQuery1.FieldByName('Druh').AsString:= 'series';
                 if CheckBoxUm.Checked then
                  begin
                    if CheckBox1.Checked then
                       begin
                         PomUm:=inttostr(JLabeledIntegerEdit2.Value+PocetDisku-1);
                         if length(PomUm) =1 then PomUm:='00'+PomUm;
                         if length(PomUm) =2 then PomUm:='0'+PomUm;
                         Form1.ZQuery1.FieldByName('UMISTENI').AsString:= LabeledEdit2.Text+
                         PomUm;
                       end
                                         else
                         Form1.ZQuery1.FieldByName('UMISTENI').AsString:= LabeledEdit2.Text;
                  end;
                 If CheckBoxMe.Checked then;
                  Form1.ZQuery1.FieldByName('MEDIUM').AsString:= ComboBox1.Text;
                 if CheckBoxTr.Checked then
                  begin
                    Form1.ZQuery1.FieldByName('DILY_CELKEM').AsString:= IntToStr(CelkovyPocetDilu);
                      Form1.ZQuery1.FieldByName('DILY_NA_DISKU').AsString:= PomPocetDilu;
                      Form1.ZQuery1.FieldByName('SEZONA').AsString:= PomPocetSezon;
                      Form1.ZQuery1.FieldByName('STUBFILE').AsString:=  PomPocetSezon + PomPocetDilu +
                      '.disc';
                      Form1.ZQuery1.FieldByName('DIRECTORY').AsString:= '\'+ form1.validateFileName(LabeledEdit1.Text)+'\'
                      +PomPocetSezon+'\';
                  end;
               Form1.ZQuery1.Post;
               PomPocetDilu:='';
              end;
            XNodeSezona:=XNodeSezona^.NextSibling;
            if (XnodeSezona <> nil) then
               begin
                  XNodeDisk:=XNodeSezona^.FirstChild;

                   {
                    PocetDisku:=0;
                   }

               end;
            if (XNodeDisk  <> nil) then XnodeDil :=XNodeDisk^.FirstChild;
         end;
    // Form1.UlozZmenySQL;  // zmněna se hlída přez zmenaVDatabazi viz zquery1.afterPost;
     VET.DeleteChildren(VET.RootNode,true)     { smaž strom, radši :-) }
   end; {--------------------------------konec změň seriál volba Hromadná změna - komplexní}

end;




procedure TForm3.Button5Click(Sender: TObject);      { Cancel }
begin
  ModalResult:=mrCancel;
end;

procedure TForm3.Button6Click(Sender: TObject);  {ukaž modálně Form4 }
                                             {a vytvoř strom VirtualTreeView dle Form4 }
begin
  If Form4.ShowModal= mrOK then
  VytvorStrom(Form4.JLabeledIntegerEdit1.Value,
              Form4.JLabeledIntegerEdit2.Value,
              Form4.JLabeledIntegerEdit3.Value);
end;

procedure TForm3.Button7Click(Sender: TObject);   {Hledat rok na Internetu}
var
  PomStr: String;
  scrapovatZnovuToSame: Boolean;
begin
  if (not Form1.ZjistiPromNovySerial()) and (not CheckBoxNs.Checked) then
      begin
        MessageDlg(Format(rsProHledNRoku, [LineEnding]), mtWarning, [mbOK], 0);
        exit;
      end;
 If LabeledEdit1.Text='' then exit;  {s prázdným názvem házi scrapování error 404}
 repeat
    PomStr:=aktualniScraperSerial(LabeledEdit1.Text);
    if PomStr <> 'nenalezeno' then
      begin
        JLabeledIntegerEdit1.Value:=StrToInt(PomStr);
        LabeledEdit1.Text:=FormScraper.vybranyNazev;
      end
                              else
      scrapovatZnovuToSame:= globalScraper.notScrapedAction;
 until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');

end;

procedure TForm3.CheckBox1Change(Sender: TObject);
begin
  if Form3.CheckBox1.Checked then Form3.JLabeledIntegerEdit2.Enabled:=true;
  if not(Form3.CheckBox1.Checked) then Form3.JLabeledIntegerEdit2.Enabled:=false;
end;

procedure TForm3.CheckBoxMeChange(Sender: TObject); {přepínač nový seriál/změna seriálu
                                                     pro Medium}
begin
  if CheckBoxMe.Checked then
     begin
       Label3.Enabled:=true;
       ComboBox1.Enabled:=true;
     end
                        else
     begin
      Label3.Enabled:=false;
      ComboBox1.Enabled:=false;
     end;
end;

procedure TForm3.CheckBoxNsClick(Sender: TObject);
                                         {přepínač nový seriál/změna seriálu pro Název Seriálu}
begin
  If CheckBoxNs.Checked then
      begin
        LabeledEdit1.Enabled:=true;
        Form1.ZQuery1.GotoBookmark(Form1.dbgrid1.SelectedRows.Items[0]);
        LabeledEdit1.Text:= Form1.ZQuery1.FieldByName('NAZEV_SERIALU').AsString;
       end

                        else LabeledEdit1.Enabled:=false ;
end;

procedure TForm3.CheckBoxRoChange(Sender: TObject);{přepínač nový seriál/změna seriálu pro Rok}
begin
  if CheckBoxRo.Checked then
      begin
       JLabeledIntegerEdit1.Enabled:=true;
       Button7.Enabled:=true;
      end
                        else
      begin
        JLabeledIntegerEdit1.Enabled:=false;
        Button7.Enabled:=false;
      end;
end;

procedure TForm3.CheckBoxTrClick(Sender: TObject); {přepínač nový seriál/změna seriálu pro Strom}
begin
  If CheckBoxTr.Checked then
    begin
      VET.Enabled:=true;
      Button1.Enabled:=true;
      Button2.Enabled:=True;
      Button3.Enabled:=True;
      Button6.Enabled:=True;
      odhadniStromZVyberu;
    end
                        else
    begin
      VET.DeleteChildren(VET.RootNode,true);     { smaž strom, radši :-) }
      VET.Enabled:=False;
      Button1.Enabled:=False;
      Button2.Enabled:=False;
      Button3.Enabled:=False;
      Button4.Enabled:=True;
      Button6.Enabled:=False
    end;
end;

procedure TForm3.CheckBoxUmChange(Sender: TObject);{přepínač nový seriál/změna seriálu
                                                    pro Umístění}
begin
  if CheckBoxUm.Checked then
     begin
       LabeledEdit2.Enabled:=true;
       CheckBox1.Enabled:=true;
       JLabeledIntegerEdit2.Enabled:=false
     end
                        else
     begin
      LabeledEdit2.Enabled:=false;
      CheckBox1.Enabled:=false;
      JLabeledIntegerEdit2.Enabled:=false
     end;
end;

{ OnChange }
procedure TForm3.VETChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var pom,pom2: string;
begin
 VeT.Refresh;
    str(VET.FocusedNode^.ChildCount,pom);
    str(VET.getnodelevel(VET.FocusedNode),pom2);
    Memo1.Clear;
    Memo1.Append('Node level:' + pom2);
    Memo1.Append('Child count:' + pom);
end;

{ OnFokusChanged }
procedure TForm3.VETFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);

begin
VeT.Refresh;
end;

{ OnFreeNode }
procedure TForm3.VETFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PTreeData;
begin
  Data:=VET.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^.Column0 := '';
  end;
end;

 { OnGetNodeDataSize }
procedure TForm3.VETGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
   NodeDataSize := SizeOf(TTreeData);
end;

  { OnGetText - klíčová pro zobrazení sloupce }
procedure TForm3.VETGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var
  Data: PTreeData;
begin
  Data := VET.GetNodeData(Node);
  case Column of
    0: CellText := Data^.Column0;
  end
end;

{Spočítá:  počet sezón - dynamicky podle ukazatelů,
           počet disků - for cyklus se neosvědčil
           počet dílů  - lepší je while :-) }
procedure TForm3.VETStructureChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Reason: TChangeReason);
var
 pom1,pom2,pom3:string;
 XNodeRoot, XNodeSezona, XNodeDisk, XnodeDil : PVirtualNode;
 PocetSezon,PocetDisku,PocetDilu : byte;
begin
     PocetSezon:=0;
     PocetDisku:=0;
     PocetDilu:=0;
     Memo2.Clear;

       XNodeRoot   := VET.GetFirstLevel(0);
       XNodeSezona := VET.GetFirstLevel(1);
       XNodeDisk   := VET.GetFirstLevel(2);
       XnodeDil    := VET.GetFirstLevel(3);

       while (XNodeSezona <> nil) do
         begin
            PocetSezon := PocetSezon +1;
            while (XNodeDisk <> nil ) do
              begin
               PocetDisku := PocetDisku +1;
               while (XnodeDil <> nil ) do
                 begin
                  PocetDilu := PocetDilu +1;
                  XnodeDil := XnodeDil^.NextSibling;
                 end;
               XNodeDisk := XNodeDisk^.NextSibling;
               if (XnodeDisk <> nil) then XnodeDil :=  XNodeDisk^.FirstChild;
              end;
            XNodeSezona:=XNodeSezona^.NextSibling;
            if (XnodeSezona <> nil) then XNodeDisk:=XNodeSezona^.FirstChild;
            if (XNodeDisk  <> nil) then XnodeDil :=XNodeDisk^.FirstChild;
         end;

    str(PocetSezon,pom3);
    str(PocetDisku,pom2);
    str(PocetDilu,pom1);
    CelkovyPocetDilu:=PocetDilu; {Pro použití při tvorbě nového seriálu}
    CelkovyPocetDisku:=PocetDisku;
    Memo2.Append(Format(rsSezonyCelkem, [pom3]));
    Memo2.Append(Format(rsDiskyCelkem, [pom2]));
    Memo2.Append(Format(rsDLyCelkem, [pom1]));

end;

procedure TForm3.ZmenStavCheckboxu(b,c: boolean); {kupodivu schová/ukáže checkboxy a}
begin                                              {s nimi svázané prvky pro form3}
  CheckboxNs.Enabled:=b;
  CheckboxNs.Visible:=b;
  CheckboxNs.Checked:=false;
  LabeledEdit1.Enabled:=c;

  CheckboxRo.Enabled:=b;
  CheckboxRo.Visible:=b;
  CheckboxRo.Checked:=False;
  JLabeledIntegerEdit1.Enabled:=c;
  Button7.Enabled:=c;

  CheckboxUm.Enabled:=b;
  CheckBoxUm.Visible:=b;
  CheckboxUm.Checked:=False;
  LabeledEdit2.Enabled:=c;
  CheckBox1.Enabled:=c;
  JLabeledIntegerEdit2.Enabled:=false;

  CheckboxMe.Enabled:=b;
  CheckBoxMe.Visible:=b;
  CheckBoxMe.Checked:=False;
  Label3.Enabled:=c;
  ComboBox1.Enabled:=c;

  CheckBox1.Checked:=false;

  CheckBoxTr.Enabled:=b;
  CheckBoxTr.Visible:=b;
  CheckBoxTr.Checked:=False;
  VET.Enabled:=c;
  Button1.Enabled:=c;
  Button2.Enabled:=c;
  Button3.Enabled:=c;
  Button6.Enabled:=c;

end;

procedure TForm3.VytvorStrom(PocetSezon,PocetDisku,PocetDilu: byte); {vytvoř strom
                                                                     VirtualTreeView}
var
 Data: PTreeData;
 XNodeRoot, XNodeSezona, XNodeDisk, XnodeDil : PVirtualNode;
 i,j,z : Integer;

begin
  if VET.RootNodeCount <> 0 then VET.DeleteChildren(VET.RootNode,true);
  XNodeRoot:=VET.AddChild(nil);
  if VET.AbsoluteIndex(XNodeRoot) > -1 then
  Begin
   Data := VET.GetNodeData(XnodeRoot);
   Data^.Column0:= 'series';
  End;
  for i:=1  to  PocetSezon  do
    begin
     XNodeSezona:= VET.AddChild(XNodeRoot);
     Data := VET.GetNodeData(XNodeSezona);
     Data^.Column0:= Format(rsSezona, [IntToStr(i)]) ;
     for j:=1  to PocetDisku do
       begin
        XNodeDisk:= VET.AddChild(XNodeSezona);
        Data := VET.GetNodeData(XNodeDisk);
        Data^.Column0:= Format(rsDisk2, [IntToStr(j)]);
        for z:=1 to PocetDilu do
          begin
           XnodeDil:=vet.AddChild(XNodeDisk);
           Data:=vet.GetNodeData(XnodeDil);
           Data^.Column0:=Format(rsDL2, [IntToStr(z)]);
          end;
          VET.Expanded[XNodeDisk]:=True;

        end;
        VET.Expanded[XNodeSezona]:=True;
     end;
  VET.Expanded[XNodeRoot]:=True;
end;

procedure TForm3.odhadniStromZVyberu;  {Vytvoří strom pro vybrané řádky při
                                       Hromadná změna - komplexní}
var
 Data: PTreeData;
 XNodeRoot, XNodeSezona, XNodeDisk, XnodeDil : PVirtualNode;
 i,z : Integer;
 pomSezona: String;
 pocetSezonVeVyberu: Integer;
 pocetDiskuVSezone: Integer;
 pocetDiluNaDisk: Integer;

begin
  if VET.RootNodeCount <> 0 then VET.DeleteChildren(VET.RootNode,true);
  XNodeRoot:=VET.AddChild(nil);
  if VET.AbsoluteIndex(XNodeRoot) > -1 then
  Begin
   Data := VET.GetNodeData(XnodeRoot);
   Data^.Column0:= 'series';
  End;
  {Sezóna, Disk a Díly pro první řádek výběru - začátek}
   Form1.ZQuery1.GotoBookmark(Form1.DBGrid1.SelectedRows.Items[0]);
   pomSezona:= Form1.ZQuery1.FieldByName('SEZONA').AsString;
   pocetSezonVeVyberu:=1;
   pocetDiskuVSezone:=1;
   XNodeSezona:= VET.AddChild(XNodeRoot);         {vytvoří Sezónu č.1}
   Data := VET.GetNodeData(XNodeSezona);
   Data^.Column0:= rsSezona1;
   XNodeDisk:= VET.AddChild(XNodeSezona);         {Vytvoří Disk č.1}
   Data := VET.GetNodeData(XNodeDisk);
   Data^.Column0:= rsDisk1;
   pocetDiluNaDisk:=WordCount(Form1.ZQuery1.FieldByName('DILY_NA_DISKU').AsString,['e']);
   for z:=1 to pocetDiluNaDisk do                 {Vytvoří díly pro Disk č.1}
     begin
      XnodeDil:=vet.AddChild(XNodeDisk);
      Data:=vet.GetNodeData(XnodeDil);
      Data^.Column0:=Format(rsDL2, [IntToStr(z)]);
     end;
   VET.Expanded[XNodeDisk]:=True;
   VET.Expanded[XNodeSezona]:=True;
  {Sezóna, Disk a Díly pro první řádek výběru - konec}
  if RadkyVyberu=1 then
       begin
         VET.Expanded[XNodeRoot]:=True;
         exit
       end;
   for i:=1  to  RadkyVyberu-1  do
    begin
       Form1.ZQuery1.GotoBookmark(Form1.DBGrid1.SelectedRows.Items[i]);
       pocetDiskuVSezone:=pocetDiskuVSezone+1;
       if pomSezona <> Form1.ZQuery1.FieldByName('SEZONA').AsString then
         begin
           pocetSezonVeVyberu:=pocetSezonVeVyberu+1;
           pocetDiskuVSezone:=1;
           pomSezona:= Form1.ZQuery1.FieldByName('SEZONA').AsString;
           XNodeSezona:= VET.AddChild(XNodeRoot);
           Data := VET.GetNodeData(XNodeSezona);
           Data^.Column0:= Format(rsSezona, [IntToStr(pocetSezonVeVyberu)]);
         end;
       XNodeDisk:= VET.AddChild(XNodeSezona);
       Data := VET.GetNodeData(XNodeDisk);
       Data^.Column0:= Format(rsDisk2, [IntToStr(pocetDiskuVSezone)]);
       pocetDiluNaDisk:=WordCount(Form1.ZQuery1.FieldByName('DILY_NA_DISKU').AsString,['e']);
       for z:=1 to pocetDiluNaDisk do
         begin
          XnodeDil:=vet.AddChild(XNodeDisk);
          Data:=vet.GetNodeData(XnodeDil);
          Data^.Column0:=Format(rsDL2, [IntToStr(z)]);
         end;
       VET.Expanded[XNodeDisk]:=True;
       VET.Expanded[XNodeSezona]:=True;
     end;
  VET.Expanded[XNodeRoot]:=True;
end;

procedure TForm3.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  LabeledEdit1.EditLabel.Caption:=rsSerieName;
  LabeledEdit2.EditLabel.Caption:=rsLocation;
  JLabeledIntegerEdit1.EditLabel.Caption:=rsYear;
  VET.Header.Columns.Items[0].Text:=rsSeasonDiskEp;
end;

{
 Další nutné procedury (hlavně pro editaci) jsou v příkladu, který
 máš uložený jako projekt e:\Dokumenty_ZbynA\Lazarus - Pokusy\TTree -Lazarus\,
 jde otevřít v  PSPadu.  Dobrou noc Zbyňo :-)
}






end.

