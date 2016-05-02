unit Unit5;
 // stub files creating
{$mode objfpc}{$H+}

interface

uses
  SysUtils, FileUtil,  Forms, Controls, Dialogs, ExtCtrls, StdCtrls, EditBtn,{OmniXML,}
  {OmniXMLUtils,} OXmlCDOM,OXmlUtils, Classes,LocalizedForms, LazUTF8;

type

  { TForm5 }

  TForm5 = class(TLocalizedForm)
    Button1: TButton;                  { OK}
    Button2: TButton;                   { Cancel }
    DirectoryEdit1: TDirectoryEdit;     { umožňuje vybrat adresář }
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;          {Alternative title - název seriálu}
    LabeledEdit2: TLabeledEdit;           {Message to be displayed - umístění}
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  Form5: TForm5;



implementation
 uses unit1;  { chci pracovat s objekty Form1 }
{$R *.lfm}

{ TForm5 }

procedure TForm5.FormCreate(Sender: TObject);
begin
DirectoryEdit1.RootDir:= ( getCurrentDir);  //systoutf8
DirectoryEdit1.Directory:=( getCurrentDir);  // systoutf8

end;

procedure TForm5.FormShow(Sender: TObject);
begin
  if Form1.ZQuery1.FieldByName('DRUH').AsString = 'series'
      then
        LabeledEdit1.Text:=Form1.ZQuery1.FieldByName('NAZEV_SERIALU').AsString
      else
        LabeledEdit1.Text:=Form1.ZQuery1.FieldByName('NAZEV').AsString;
  LabeledEdit2.Text:=Form1.ZQuery1.FieldByName('UMISTENI').AsString;
end;

procedure TForm5.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  LabeledEdit1.EditLabel.Caption:=rsAlternativeT;
  LabeledEdit2.EditLabel.Caption:=rsMessageToBeD;
end;

procedure TForm5.Button1Click(Sender: TObject);    { OK a pak vytvoř stub soubor}
var
  i: byte;
  discstub: TXMLNode;
  xmlDoc : IXMLDocument;
  //pomSerieNazev : String;
  PomS: String;
  ////--------------------------------------------------------------------
  //// volitelně vytvořit druhý xml soubor nfo  pro automatické zařazení
  //// do tagu (třeba offline), nejde to v nfo by museli být všechny údaje o filmu
  // nebo alespoň http adresa na informace o filmu a to dělat nebudu :-)
  //----------------------------------------------------------------------
  //procedure vytvorXMLsTagem(druhPolozky:String;nazevPolozky:String;
  //                          nazevTagu:String);
  // // druhPolozky movie nebo tvshow :
  // // viz. http://kodi.wiki/view/NFO_files/movies
  // // viz. http://kodi.wiki/view/NFO_files/tvshows
  //  var
  //    xmlDocTag:IXMLDocument;
  //    serieNeboFilm:TXMLNode;
  //    pomDir:String;
  //    pomFile:String;
  //  begin
  //    xmlDocTag:=CreateXMLDoc(druhPolozky); // movie nebo tvshow
  //    serieNeboFilm:=xmlDocTag.DocumentElement;
  //    serieNeboFilm.AddChild('tag').AddText(nazevTagu);
  //    pomDir:=DirectoryEdit1.Directory+PathDelim+nazevPolozky+PathDelim;
  //    if ForceDirectories(pomDir) then
  //      begin
  //        pomFile:= pomDir + nazevPolozky + '.nfo';
  //        xmlDocTag.WriterSettings.IndentType:=itIndent;
  //        xmlDocTag.SaveToFile(PomFile);
  //      end;
  //  end;

begin
 //pomSerieNazev:=''; // nfo soubor se u serie vytváří jenom jednou a to v adresáři serie
 ModalResult:=mrOK;
 for i:=0 to Form1.dbgrid1.SelectedRows.Count-1 do
   begin
    Form1.ZQuery1.GotoBookmark(Form1.dbgrid1.SelectedRows.Items[i]);
    if Form1.ZQuery1.FieldByName('DRUH').AsString = 'series'
      then
        begin
          LabeledEdit1.Text:=Form1.ZQuery1.FieldByName('NAZEV_SERIALU').AsString;
          //if LabeledEdit1.Text <> pomSerieNazev then
          //    vytvorXMLsTagem('tvshow',LabeledEdit1.Text,'Offline');
        end
      else
        begin
          LabeledEdit1.Text:=Form1.ZQuery1.FieldByName('NAZEV').AsString;
          //vytvorXMLsTagem('movie', LabeledEdit1.Text +'('+
          //                Form1.ZQuery1.FieldByName('ROK').AsString + ')',
          //               'Offline');
        end;
    LabeledEdit2.Text:=Form1.ZQuery1.FieldByName('UMISTENI').AsString;
    xmlDoc:=CreateXMLDoc('discstub');
    discstub:=xmlDoc.DocumentElement;
    discstub.AddChild('title').AddText(LabeledEdit1.Text);
    discstub.AddChild('message').AddText(LabeledEdit2.Text);
    PomS:=DirectoryEdit1.Directory;
    PomS:=PomS+Form1.ZQuery1.FieldByName('DIRECTORY').AsString;
    If ForceDirectories((PomS)) then    //utf8tosys
      begin
        Poms:=Poms+Form1.ZQuery1.FieldByName('STUBFILE').AsString;
        xmlDoc.WriterSettings.IndentType:=itIndent;
        xmlDoc.SaveToFile(PomS);
      end;
   end;
end;

end.

