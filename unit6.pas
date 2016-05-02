unit Unit6;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Menus,LocalizedForms;

type

  { TForm6 - pro vytvoření filmu a zároveň pro hromadnou změnu filmu}

  TForm6 = class(TLocalizedForm)
    Button1: TButton;    { Ok}
    Button2: TButton;    {Storno}
    Button3: TButton;    {Hledat rok na Internetu}
    Button4: TButton;    {Další film  vytvoř nebo edituj}
    ImgListForm6: TImageList;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;   { Název}
    LabeledEdit2: TLabeledEdit;   { Rok}
    LabeledEdit3: TLabeledEdit;   { Umístění}
    ComboBox1: TComboBox;       { Media}
    StaticText1: TStaticText;        { Stubfile}
    StaticText2: TStaticText;        { Directory}
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure LabeledEdit2EditingDone(Sender: TObject);
    procedure LabeledEdit3EditingDone(Sender: TObject);
    procedure LabeledEdit3Enter(Sender: TObject);
  private
    { private declarations }
    procedure updateStubfileADirectory;

  public
    { public declarations }
    indexSwitch : boolean;        { použít index }
    indexDefinovan : boolean;      { už byl index definován}
    indexHodnota : Integer;         { hodnota indexu (bez báze)}
    indexBaze: Integer;             { báze indexu}
    umisteniStare:String;           { přechozí hodnota umístění}
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  Form6: TForm6;



implementation
  uses unit7,   { chci pracovat s objekty v unit7 tzn. s FormNastaveni }
       unit8,   { chci pracovat s objekty v unit8 tzn. scrapovat rok k filmu }
       unit1,   // v unit1 jsou resource stringy
       unGlobalScraper;  // je tam timer + kód na využití frmNotScraped (unNotScraped)

{$R *.lfm}

{ TForm6 }

procedure TForm6.updateStubfileADirectory;
begin
  StaticText1.Caption:=  LabeledEdit1.Text +'.disc';
  StaticText2.Caption:= '\'+ LabeledEdit1.Text+'('+LabeledEdit2.Text+')\';
end;

procedure TForm6.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  StaticText2.Caption:=rsDirectory2;
  LabeledEdit1.EditLabel.Caption:=rsName;
  LabeledEdit2.EditLabel.Caption:=rsYear;
  LabeledEdit3.EditLabel.Caption:=rsLocation;
end;

procedure TForm6.LabeledEdit2EditingDone(Sender: TObject);
begin
  updateStubfileADirectory
end;

procedure TForm6.LabeledEdit3EditingDone(Sender: TObject);  {Ukončení editace pole "Umístění"}
var
  PomUm: String;
begin
  If (indexSwitch=true) then
    begin
      if indexHodnota=0 then umisteniStare:=LabeledEdit3.Text;
      LabeledEdit3.Text:='';
      PomUm:=inttostr(indexBaze+indexHodnota) ;
      if length(PomUm) =1 then PomUm:=' 00'+PomUm;
      if length(PomUm) =2 then PomUm:=' 0'+PomUm;
      LabeledEdit3.Text:=umisteniStare+PomUm;
    end;
end;

procedure TForm6.LabeledEdit3Enter(Sender: TObject);   {Enter do pole "Umístění"}
begin
  If (indexHodnota=0) and (indexSwitch=true)   then
    begin
      if MessageDlg(rsPouTIndexUmS, mtConfirmation, [mbYes, mbNo], 0) = mrYes
            then
        begin
          indexDefinovan:=true;
          indexBaze:= strtoint(Inputbox(rsBZeIndexu, rsIndexOd, '0'));
        end
            else
          indexSwitch:=false;
    end;
end;

procedure TForm6.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  updateStubfileADirectory;
end;

procedure TForm6.Button3Click(Sender: TObject);
var
  pomText: string;
  scrapovatZnovuToSame: Boolean;
begin
  //aktualniScraperFilm:=ScraperyFilm[TScraperFilm(FormNastaveni.FilmScrapers.ItemIndex)];
  if LabeledEdit1.Text='' then exit;  {s prázdným názvem házi scrapování error 404}
  repeat
      pomText:=aktualniScraperFilm(LabeledEdit1.Text);
      if pomText <>'nenalezeno' then
        begin
          LabeledEdit2.Text:=pomText;
          LabeledEdit1.Text:=FormScraper.vybranyNazev;
        end
                                else
      scrapovatZnovuToSame:= globalScraper.notScrapedAction;
  until not(scrapovatZnovuToSame) or (pomText<>'nenalezeno');
end;

end.

