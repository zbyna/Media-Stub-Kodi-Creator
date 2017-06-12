unit Unit10;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Grids, ExtCtrls, StdCtrls,LocalizedForms,LazUTF8;

type

  { TFormUpravUmisteni }

  TFormUpravUmisteni = class(TLocalizedForm)
    chboxVsechnaCisla: TCheckBox;
    okButton: TButton;
    cancelButton: TButton;
    StringGridProUmisteni: TStringGrid;  {náhled změny Umístění podle vybrané pozice čísla}
    stringGridProVyberPozice: TStringGrid;  {umožní vybrat pozici čísla v Umístění}
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure okButtonClick(Sender: TObject);
    procedure stringGridProVyberPoziceSelectCell(Sender: TObject; aCol,
      aRow: Integer; var CanSelect: Boolean);  {doplní nuly zleva pro vybrané číslo v Umístění}
  private
    { private declarations }
  public
    { public declarations }
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  FormUpravUmisteni: TFormUpravUmisteni;



implementation
  uses Unit1;
  var pomWidth: array[0..10] of integer;
      frmGlobalI:Byte;
{$R *.frm}

{ TFormUpravUmisteni }

procedure TFormUpravUmisteni.FormShow(Sender: TObject);
var
  PomS: String;
  pomColumn:TGridColumn;
  pomPocetZnaku: Integer;
  i: Integer;
begin
  form1.ZQuery1.DisableControls;  // big speed influence
  for frmGlobalI:=0 to 10 do   // aby se skokově neměnila velikost sloupců
      pomWidth[frmGlobalI]:=Form1.DBGrid1.Columns.Items[frmGlobalI].Width;
  FormUpravUmisteni.Caption:=FormUpravUmisteni.Caption +
                             Form1.pomColumnForNumFormatAdujstment.Title.Caption;
  chboxVsechnaCisla.Caption:=rsChangeFormat;
  pomColumn:=stringGridProVyberPozice.Columns.Items[0];
  stringGridProVyberPozice.Columns.Clear;
  stringGridProVyberPozice.Columns.Add;
  stringGridProVyberPozice.Columns.Items[0]:=pomColumn;
  stringGridProVyberPozice.Columns.Items[0].Title.Caption:='0';
  Form1.ZQuery1.GotoBookmark(Form1.dbgrid1.SelectedRows.Items[0]);
  //PomS:=Form1.ZQuery1.FieldByName('UMISTENI').AsString;
  //PomS:=Form1.DBGrid1.SelectedColumn.Field.AsString;
  PomS:=Form1.pomColumnForNumFormatAdujstment.Field.AsString;
  pomPocetZnaku:=UTF8Length((PomS));    //utf8tosys
  //PomS:=UTF8ToWinCP(PomS);//UTF8ToSys {jenom lcL komponenty pracují s unicode(utf8)}
     // velká změna rtl používá utf-8 od fpc 3.x, jak v linuxu ?
     // Asi nijak, tam by mělo být vše utf-8 :-)
  stringGridProVyberPozice.Cells[0,1]:=UTF8copy(PomS,1,1);//Systoutf8{přístup k znakům stringu není z LcL}

  for i:= 1 to pomPocetZnaku-1 do
    begin

      stringGridProVyberPozice.Columns.Add;
      stringGridProVyberPozice.Columns.Items[i]:=stringGridProVyberPozice.Columns.Items[0];
      stringGridProVyberPozice.Columns.Items[i].Title.Caption:=IntToStr(i);
      //stringGridProVyberPozice.Cells[i,1]:= WinCPToUTF8(MidBStr((PomS),i+1,1));//systoutf8 { MidBStr je z RTL knihovny}
      stringGridProVyberPozice.Cells[i,1]:= UTF8Copy(pomS,i+1,1);
      stringGridProVyberPozice.Columns.Items[i].Alignment:=taCenter;
      stringGridProVyberPozice.Columns.Items[i].Title.Alignment:=taCenter;
    end;

  stringGridProVyberPozice.AutoSizeColumns;  // existuje taky TCustomStringGrid.AutoAdjustColumn(aCol: Integer)
  StringGridProUmisteni.RowCount:=Form1.dbgrid1.SelectedRows.Count+1;
  StringGridProUmisteni.Columns.Items[0].Title.Caption:= Form1.pomColumnForNumFormatAdujstment.Title.Caption;
  for i:=0 to Form1.DBGrid1.SelectedRows.Count-1 do
    begin
      Form1.ZQuery1.GotoBookmark(Form1.DBGrid1.SelectedRows.Items[i]);
      //StringGridProUmisteni.Cells[0,i+1]:=Form1.ZQuery1.FieldByName('UMISTENI').AsString;
      //StringGridProUmisteni.Cells[0,i+1]:=Form1.DBGrid1.SelectedColumn.Field.AsString;
      StringGridProUmisteni.Cells[0,i+1]:=Form1.pomColumnForNumFormatAdujstment.Field.AsString;
    end;
  //ShowMessage(StringGridProUmisteni.Cells[0,1]);
  form1.ZQuery1.EnableControls;   // big speed influence
end;

procedure TFormUpravUmisteni.FormHide(Sender: TObject);
begin
  form1.ZQuery1.DisableControls;
  FormUpravUmisteni.Caption:=UTF8StringReplace(FormUpravUmisteni.Caption,
                             Form1.pomColumnForNumFormatAdujstment.Title.Caption,
                             '',[rfIgnoreCase]);

  //FormUpravUmisteni.Caption:=  FormUpravUmisteni.Caption -
  //                          Form1.DBGrid1.SelectedColumn.Title.Caption;
  for frmGlobalI:=0 to 10 do    // aby se skokově neměnila velikost sloupců
      Form1.DBGrid1.Columns.Items[frmGlobalI].Width:=pomWidth[frmGlobalI];
  form1.ZQuery1.enableControls;
end;

procedure TFormUpravUmisteni.okButtonClick(Sender: TObject);
var
  i: Integer;
begin
  form1.ZQuery1.DisableControls;
  for i:=0 to Form1.DBGrid1.SelectedRows.Count-1 do
    begin
      Form1.ZQuery1.GotoBookmark(Form1.DBGrid1.SelectedRows.Items[i]);
      Form1.ZQuery1.Edit;
      //Form1.ZQuery1.FieldByName('UMISTENI').AsString:=StringGridProUmisteni.Cells[0,i+1];
      Form1.pomColumnForNumFormatAdujstment.Field.AsString:=StringGridProUmisteni.Cells[0,i+1];
      Form1.ZQuery1.Post;
    end;
  form1.ZQuery1.enableControls;
end;

procedure TFormUpravUmisteni.stringGridProVyberPoziceSelectCell(
  Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
{doplní nuly zleva pro vybrané číslo v Umístění}
type
   TCislice = set of '0'..'9';
var
   cislice : TCislice;
   i,k: Integer;
   PomS,PomS1: String;
   prvniCastUmisteni: String;
   druhaCastUmisteni: String;
   delkaUmisteni: Integer;
   PomaCol: Integer;
begin
  cislice:= ['0'..'9'];
  StringGridProUmisteni.RowCount:=Form1.dbgrid1.SelectedRows.Count+1;
  //ShowMessage(StringGridProUmisteni.Cells[0,1]);
  PomaCol:=0;
   for i:=0 to Form1.DBGrid1.SelectedRows.Count-1 do
     begin
       Form1.ZQuery1.GotoBookmark(Form1.DBGrid1.SelectedRows.Items[i]);
       //PomS:= (Form1.ZQuery1.FieldByName('UMISTENI').AsString); //Utf8tosys
       //PomS:=Form1.DBGrid1.SelectedColumn.Field.AsString;
       PomS:=Form1.pomColumnForNumFormatAdujstment.Field.AsString;
       delkaUmisteni:=UTF8Length(PomS);
       if aCol < 0 then pomacol:=1
                   else PomaCol:=aCol+1; //neexistuje 0-tý znak Stringu,
                      //ale sloupce StringGrid začínají od nuly
                      //!!! procedura někdy vrací acol parametr zákeřně
                      // záporný :-) tzn. není vybraná žádná buňka
       if (chboxVsechnaCisla.Checked) then PomaCol:=1;
       repeat
         k:=0;
         PomS1:='';
         // aby se dalo kliknout na jakoukoliv číslici, ne
         // jenom na první :-)
         if (PomaCol >1) and
            (utf8Copy(PomS,PomaCol,1)[1] in cislice) and
            (utf8Copy(PomS,PomaCol-1,1)[1] in cislice) then
               begin
                 PomaCol:=PomaCol +1;
                 if not (chboxVsechnaCisla.Checked) then break;
               end;
         // načítá blok číslic
         while ((PomaCol+k)<=(delkaUmisteni)) and (utf8Copy(PomS,PomaCol+k,1)[1] in cislice) do
            begin
             PomS1:=PomS1+utf8Copy(PomS,PomaCol+k,1);
             k:=k+1; // další znak v PomS1
             //if ((PomaCol+k)>(delkaUmisteni)) then break;
             // velmi poučné utf8copy končí chybou když je index větší jak
             // délka řetězce z kterého kopíruju tzn. pokud bude ve while cyklu
             // podmínka s utf8copy jako první bude se vyhodnocovat vždy a
             //program skončí na chybě z utf8 natvrdo :-), asi
             //by to chtělo vymyslet něco lepšího
            end;
         If (PomS1<>'')  then
            begin
             if UTF8Length(PomS1) =1 then PomS1:='00'+PomS1;
             if UTF8Length(PomS1) =2 then PomS1:='0'+PomS1;
             //prvniCastUmisteni:= systoutf8(MidBStr(PomS,1,PomaCol-1));
             prvniCastUmisteni:= UTF8Copy(PomS,1,PomaCol-1);
             //druhaCastUmisteni:= systoutf8(MidBStr(Poms,PomaCol+k,Length(Poms)-(PomaCol+k-1)));
             druhaCastUmisteni:= UTF8Copy(Poms,PomaCol+k,UTF8Length(Poms)-(PomaCol+k-1));
             StringGridProUmisteni.Cells[0,i+1]:= prvniCastUmisteni+PomS1+druhaCastUmisteni;
             if not (chboxVsechnaCisla.Checked) then break ;
             PomS:= prvniCastUmisteni+PomS1+druhaCastUmisteni;
             if (k<=2)  then PomaCol:=PomaCol+(3-k)+k // nebo délka PomS1 :-)
                        else PomaCol:=pomaCol+k+1
            end
                        else
            PomaCol:=PomaCol +1;
         delkaUmisteni:=UTF8Length(PomS);
       until (PomaCol > delkaUmisteni);
     end;
end;

procedure TFormUpravUmisteni.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  if form1.pomColumnForNumFormatAdujstment <> nil then
  StringGridProUmisteni.Columns.Items[0].Title.Caption:= Form1.pomColumnForNumFormatAdujstment.Title.Caption;//rsLocation;
  //chboxVsechnaCisla.Caption:=rsChangeFormat + 'GRRRR :-)';
  // na dvě věci je nutné přidat do Form.Show !!!
end;

end.

