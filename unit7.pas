unit Unit7;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, IniPropStorage,LCLTranslator,LocalizedForms;

type

  TuiJazyky = (czech,english);
  { TFormNastaveni }

  TFormNastaveni = class(TLocalizedForm)         // Options form
    IniPropStorage1: TIniPropStorage;
    Okbutton: TButton;
    CancelButton: TButton;
    PageControl1: TPageControl;
    FilmScrapers: TRadioGroup;
    LanguageScrapers: TRadioGroup;
    jazykAplikace: TRadioGroup;
    mysKoleckoOznaceni: TRadioGroup;
    SerialScrapers: TRadioGroup;
    Scrapers: TTabSheet;
    narodniNastaveni: TTabSheet;
    ostatni: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure jazykAplikaceSelectionChanged(Sender: TObject);
    procedure OkbuttonClick(Sender: TObject);
    procedure nastavStatusBar;
  private
    { private declarations }
  public
    { public declarations }
  protected
    procedure UpdateTranslation(ALang: String); override;
  end;

var
  FormNastaveni: TFormNastaveni;
  uiJazyk:array[TuiJazyky] of String[2] = ('cs','en');


implementation
uses unit1,       // resource string
     unit8;       // formScraper

{$R *.lfm}

{ TFormNastaveni }

procedure TFormNastaveni.OkbuttonClick(Sender: TObject);

begin
  FormNastaveni.Close;
  { nastavení aktuálního scraperu při změně konfigurace v ini souboru}
  aktualniScraperFilm:=ScraperyFilm[TScraperFilm(FormNastaveni.FilmScrapers.ItemIndex)];
  aktualniScraperSerial:=ScraperySerial[TScraperSerial(FormNastaveni.SerialScrapers.ItemIndex)];
  aktualniJazyk:=jazyky[Tjazyky(FormNastaveni.LanguageScrapers.ItemIndex)];
  nastavStatusBar;
end;

procedure TFormNastaveni.jazykAplikaceSelectionChanged(Sender: TObject);
var
  pom:String;
begin
   pom:=uiJazyk[TUiJazyky(jazykAplikace.ItemIndex)];
   SetDefaultLang(pom);
   Form1.UpdateTranslation(pom);
end;

procedure TFormNastaveni.FormCreate(Sender: TObject);
begin
 mysKoleckoOznaceni.Items.Strings[0]:= rsHighlightIni;
 mysKoleckoOznaceni.Items.Strings[1]:= rsDoNotHighlig;
end;

procedure TFormNastaveni.nastavStatusBar;
var
  PomS: String;
  PomF: String;
begin
  PomS:= FormNastaveni.SerialScrapers.Items[FormNastaveni.SerialScrapers.ItemIndex];
  PomF:= FormNastaveni.FilmScrapers.Items[FormNastaveni.FilmScrapers.ItemIndex];
  if (PomS='themoviedb.org') or (pomS='thetvdb.com') then PomS:=PomS+'('+aktualniJazyk+')';
  if PomF='themoviedb.org' then PomF:=PomF+'('+aktualniJazyk+')';
  Form1.StatusBar1.Panels[1].Text:=Format(rsSeriesFilms, [PomS, PomF]);
end;

procedure TFormNastaveni.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  mysKoleckoOznaceni.Items.Strings[0]:= rsHighlightIni;
  mysKoleckoOznaceni.Items.Strings[1]:= rsDoNotHighlig;
  nastavStatusBar;
end;

end.

