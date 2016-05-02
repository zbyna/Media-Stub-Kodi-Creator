unit Unit8;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TplTimerUnit, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, simpleinternet,
  simplehtmltreeparser, extendedhtmlparser, xquery, xquery_json, dateutils,
  strutils,LazUTF8,character,eventlog, LocalizedForms;

type
  { pro scraping roku k filmu - languages }
  Tjazyky = (English, Svenska, Norsk, Dansk, Suomeksi, Nederlands, Deutsch, Italiano,
             Espanol, Francais, Polski, Magyar, Greek, Turkish, Russian, Hebrew,
             Japanese, Portuguese, Chinese, Czech, Slovenian, Croatian, Korean);

  { pro scraping roku k filmu }

  TScraperFilm = (Fthemoviedb,imdb,csfd);
  TfunctionScraperFilm = function(PomNazev:string):string;

  { pro scraping roku k seriálu }

  TScraperSerial = (Sthemoviedb,tvmaze,thetvdb,Scsfd);
  TfunctionScraperSerial =  function(PomNazev:string):string;
  { TFormScraper }

  TFormScraper = class(TLocalizedForm)
    EventLog1: TEventLog;
    OkButton: TButton;
    CancelButton: TButton;
    Label1: TLabel;
    Timer1: TTimer;
    vyberFilmu: TListBox;                    { seznam nascrapovaných řetězců název+rok }
    ProgressBar1: TProgressBar;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure Scrapuj(var scraperVstup,parsujNazev:string;htmlTag:Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure vyberFilmuClick(Sender: TObject);
    procedure vyberFilmuEnter(Sender: TObject);
  private
    { private declarations }
    muzesKoncit:Boolean;
    prvniFokus:Boolean;
  public
    { public declarations }
    vybranyNazev,vybranyRok:String;  { výstup ze scrapování dostupný všude}
  end;
  { pro scraping roku k filmu }
  function FilmThemoviedb(PomNazev:string):string;
  function FilmImdb(PomNazev:string):string;
  function FilmCsfd(PomNazev:string):string;
  { pro scraping roku k seriálu }
  function SerialThemoviedb(PomNazev:string):string;
  function SerialTvmaze(PomNazev:string):string;
  function SerialThetvdb(PomNazev:string):string;
  function SerialCsfd(PomNazev:string):string;
  procedure nahradDiakritiku(var retezec:String);

var
  FormScraper: TFormScraper;
  jazyky:array[Tjazyky] of string[2] =('en', 'sv', 'no', 'da', 'fi', 'nl', 'de', 'it',
                                       'es', 'fr', 'pl', 'hu', 'el', 'tr', 'ru', 'he',
                                       'ja', 'pt', 'zh', 'cs', 'sl', 'hr','ko');
  aktualniJazyk:string[2];
  ScraperyFilm :array[TScraperFilm] of TFunctionScraperFilm ;
  aktualniScraperFilm:TfunctionScraperFilm;
  ScraperySerial :array[TScraperSerial] of TFunctionScraperSerial;
  aktualniScraperSerial:TfunctionScraperSerial;



implementation
 uses unit7,  // formNastaveni
      unit1,  // resource strings
      unit9;  // formScrapujVyber

 var  nenalezeno:boolean;
      dobaTrmChangeScraper:Integer;

{ pro scraping roku k filmu }
function FilmThemoviedb(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;

begin

 scraperVstup:='https://api.themoviedb.org/3/search/movie?api_key=38aa2361f14d66ac47ff4d0c46c9ebd4&query='
            +pomNazev+'&language='+aktualniJazyk;
 parsujNazev:='$json("results")() ! [.("title"), .("release_date")]';

 htmlTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     FilmThemoviedb:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      FilmThemoviedb:='';
     end;
end;

function FilmImdb(PomNazev: string):string;
var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;

begin

 scraperVstup:='http://www.omdbapi.com/?s='+PomNazev;
 parsujNazev:='$json("Search")() ! [.("Title"),string(.("Year"))]' ;
 htmlTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     FilmImdb:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      FilmImdb:='';
     end;
end;

function FilmCsfd(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;

begin

 scraperVstup:='http://csfdapi.cz/movie?search='+PomNazev;
 parsujNazev:='$json() ! [.("names")("cs") ,string(.("year"))]';
 htmlTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     FilmCsfd:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      FilmCsfd:='';
     end;
end;

{ pro scraping roku k seriálu }
function SerialThemoviedb(PomNazev: string): string;
  var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;

begin

  scraperVstup:=UTF8ToSys(('https://api.themoviedb.org/3/search/tv?api_key=38aa2361f14d66ac47ff4d0c46c9ebd4&query='
            +pomNazev+'&language='+aktualniJazyk));

 parsujNazev:='$json("results")() ! [.("name"), .("first_air_date")]';
 htmlTag:=False;
 //ShowMessage('aktuální jazyk: ' + aktualniJazyk + sLineBreak+
 //             scraperVstup );
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     SerialThemoviedb:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      SerialThemoviedb:='0';
     end;
end;

function SerialTvmaze(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;

begin

  scraperVstup:='http://api.tvmaze.com/search/shows?q='+PomNazev;
 //for $prom in  $json()("show")
 //return [$prom("name"),$prom("premiered")]
 parsujNazev:='$json()("show") ! [.("name") ,string(.("premiered"))]';
 htmlTag:=False;
 nahradDiakritiku(scraperVstup);
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     SerialTvmaze:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      SerialTvmaze:='0';
     end;
end;

function SerialThetvdb(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;
begin

   //http://www.thetvdb.com/api/GetSeries.php?seriesname=neviditeln%C3%AD&language=cs
   scraperVstup:= 'http://www.thetvdb.com/api/GetSeries.php?seriesname='+pomNazev+
                  '&language='+aktualniJazyk;
 //parsujNazev:= 'for $prom in Data/series' + sLineBreak +
 //          'return [string($prom/seriesname/text()) ,string($prom/firstaired/text())]';
 parsujNazev:= 'Data/series ! [string(./seriesname/text()) ,string(./firstaired/text())]';
 htmlTag:=False;
 nahradDiakritiku(scraperVstup);
  //ShowMessage('aktuální jazyk: ' + aktualniJazyk + sLineBreak+
 //             scraperVstup );
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     SerialThetvdb:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      SerialThetvdb:='0';
     end;
end;

function SerialCsfd(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    htmlTag:Boolean;

begin

  scraperVstup:='http://csfdapi.cz/movie?search='+PomNazev;
 parsujNazev:='$json() ! [.("names")("cs") ,string(.("year"))]';
 htmlTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,htmlTag);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     SerialCsfd:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      SerialCsfd:='0';
     end;
end;

{$R *.lfm}

{ TFormScraper }

procedure TFormScraper.Scrapuj(var scraperVstup,parsujNazev:string;htmlTag:Boolean);

var     v: IXQValue;
        //Nazev,Rok:IXQValue;
        //i: Integer;
        ztazeno: String;
        pamatuj1: Char;
        pamatuj2: String;
        pomNazev,pomRok:String;
        pomRokTDate:TDateTime;
begin
    vyberFilmu.Clear;
    nenalezeno:=false;
    { zapamatuj si defaultní formát data }
    pamatuj1:=DefaultFormatSettings.DateSeparator;
    pamatuj2:=DefaultFormatSettings.ShortDateFormat;
    { nastav formát data používaný stránkami }
    DefaultFormatSettings.DateSeparator:='-';  // defaultní se inicalizuje ze systému z kultury :-)
    DefaultFormatSettings.ShortDateFormat:= 'yyyy-mm-dd'; {themoviedb api vrací RRR-MM-DD}
    {uprav vstup a scrapuj }
    if htmlTag then ztazeno:='<html>'+retrieve(scraperVstup)+'</html>'
               else ztazeno:=retrieve(scraperVstup);
     EventLog1.Info('--------------Začátek scrapování--------------------');
     EventLog1.Debug(scraperVstup);
     EventLog1.Debug('html tag: '+booltostr(htmlTag,true));
     EventLog1.Debug('query: ' + parsujNazev);
     EventLog1.Debug(ztazeno);

    if (IsWordPresent('"total_results":0}',ztazeno,[','])) or
       (Pos('Movie not found!',ztazeno) > 0)                      or
       ((ztazeno = '[]')and (aktualniScraperFilm = ScraperyFilm[csfd]))
       {specialita csfd api :-) někdy}
                                           then
                                                begin
                                                  nenalezeno:=true;
                                                  exit;
                                                end;
    //ShowMessage('Počet nalezených filmů: ' + inttostr(nazev.Count));
    //ShowMessage('Počet nalezených roků: ' + inttostr(Rok.Count));
    for v in process (ztazeno,parsujNazev) do  { naplň seznam získanými hodnotami }
      begin
        pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
        pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
        //pomNazev:=nazev.toString;
        //pomRok:=rok.toString;
        //ShowMessage(v.debugAsStringWithTypeAnnotation());
        if length(pomRok)=4 then   {csfd api vrací rovnou čtyři znaky roku}
            begin
              vyberFilmu.Items.AddText(pomNazev+'~'+pomRok);
              continue;
            end;
        if pomRok='' then pomRokTDate:=0000-00-00
              else
                {themoviedb api vrací RRR-MM-DD}
                pomRokTDate:=(v as TXQValueJSONArray).seq.get(1).toDateTime;
        vyberFilmu.Items.AddText(pomNazev+'~'+floattostr(yearof(pomRokTDate)));
        {vyberFilmu.Items.Strings[i] záhadně nefunguje}
      end;
    EventLog1.Info('-----------------------------------------------------');
    if vyberFilmu.Items.Count<>0 then vyberFilmu.Selected[0]:=True
                                 else
                                   begin
                                     nenalezeno:=true;
                                     exit;
                                   end;

    { vrať zpět defaultní formát data }
    DefaultFormatSettings.DateSeparator:=pamatuj1;
    DefaultFormatSettings.ShortDateFormat:= pamatuj2;
end;

procedure TFormScraper.Timer1Timer(Sender: TObject);
begin
  if  nenalezeno then
      begin
        Timer1.Enabled:=True;
        OkButton.Click;
      end;
  ProgressBar1.Position:=ProgressBar1.Position+20;
  if ProgressBar1.Position =100 then
     if muzesKoncit then
                      begin
                        muzesKoncit:=False;
                        OkButton.Click;
                      end
                    else
                       begin
                         muzesKoncit:=True;
                         exit;
                       end;
end;

procedure TFormScraper.vyberFilmuClick(Sender: TObject);
begin
  ProgressBar1.Position:=0;
end;

procedure TFormScraper.vyberFilmuEnter(Sender: TObject);
begin
  If not prvniFokus then ProgressBar1.Position:=0
                    else prvniFokus:=false;
end;

procedure TFormScraper.OkButtonClick(Sender: TObject);
var
     PomS:String;
begin
  if not nenalezeno then
     begin
      PomS:=UTF8ToSys(vyberFilmu.Items[vyberFilmu.ItemIndex]);
      vybranyNazev:=SysToUTF8(ExtractDelimited(1,PomS,['~']));
      vybranyRok:=SysToUTF8(ExtractDelimited(2,PomS,['~']));
     end
                    else
     begin
       vybranyRok:='nenalezeno';

     end;
  ProgressBar1.Position:=0;
end;

procedure TFormScraper.CancelButtonClick(Sender: TObject);
begin
  ProgressBar1.Position:=0;
  //vybranyNazev:='';
  //vybranyRok:='';
end;

procedure TFormScraper.FormCreate(Sender: TObject);
begin
  EventLog1.Active:=True;
  Timer1.Enabled:=false;
  prvniFokus:=true;
  {inicializace jazyka pro scrapování}
  aktualniJazyk:=jazyky[Tjazyky(FormNastaveni.LanguageScrapers.ItemIndex)];
  {inicializace procedur pro scrapování}
   ScraperyFilm[Fthemoviedb]:=@(FilmThemoviedb);
   ScraperyFilm[imdb]:=@(FilmImdb);
   ScraperyFilm[csfd]:=@(FilmCsfd);
   ScraperySerial[Sthemoviedb]:=@(SerialThemoviedb);
   ScraperySerial[tvmaze]:=@(SerialTvmaze);
   ScraperySerial[thetvdb]:=@(SerialThetvdb);
   ScraperySerial[Scsfd]:=@(SerialCsfd);
  { vytvoření aktuálních scraperu z ini, možno až po vytvoření FormNastaveni (unit7)
    jinak segmentation error za runtimu}
  aktualniScraperFilm:=ScraperyFilm[TScraperFilm(FormNastaveni.FilmScrapers.ItemIndex)];
  aktualniScraperSerial:=ScraperySerial[TScraperSerial(FormNastaveni.SerialScrapers.ItemIndex)];
  FormNastaveni.nastavStatusBar;
end;

procedure TFormScraper.FormClose(Sender:TObject; var CloseAction:TCloseAction);
begin
   Timer1.Enabled:=false;
end;

procedure TFormScraper.FormShow(Sender: TObject);

begin
  prvniFokus:=true;
  Timer1.Enabled:=true;
  //Label1.Caption:='Vyberte pořad: ';
end;

procedure nahradDiakritiku(var retezec:String);
var
  ukChar: PChar;
  unicode: Cardinal;
  CharLen: integer;
  unicodeCategory: SmallInt;
  pomString:String;
begin
 pomString:='';
 ukChar:=pchar(Tcharacter.Normalize_NFKD(retezec));
  repeat
    unicode:=UTF8CharacterToUnicode(ukChar,CharLen);
    // unicodeinfo.categoryStrings -'Mark, Nonspacing'  šestá položka
    // UTF8PROC_CATEGORY_MN = 6
    unicodeCategory:=Tcharacter.GetUnicodeCategory(UnicodetoUTF8(unicode));
    if unicodeCategory <> 6 then
        pomString:= pomString + UnicodeToUTF8(unicode);
    inc(ukChar,CharLen);
  until (CharLen=0) or (ukChar^ = #0);
  retezec:=pomString;
end;

end.

