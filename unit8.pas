unit Unit8;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FileUtil, TplTimerUnit, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, simpleinternet,
  simplehtmltreeparser, extendedhtmlparser, xquery, xquery_json, dateutils,
  strutils,LazUTF8,character,eventlog, LocalizedForms,bbutils,unConstants,
  zuncomprfp,pasMP,LCLProc;

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

  { general action for all scrapers - něco jako closures ve Swiftu :-) }
  TprocedureSraperAction = procedure(v: IXQValue) is nested;
  { TFormScraper }

  TFormScraper = class(TLocalizedForm)
    EventLog1: TEventLog;
    imgObrazek: TImage;
    memDej: TMemo;
    OkButton: TButton;
    CancelButton: TButton;
    Label1: TLabel;
    Timer1: TTimer;
    vyberFilmu: TListBox;                    { seznam nascrapovaných řetězců název+rok }
    vyberObrazku:TStringList;                { seznam nascrapovaných řetězců adres obrázků }
    vyberDeju:TStringList;                   { seznam nascrapovaných řetězců dějů }
    vyberReferer:TStringList;
    ProgressBar1: TProgressBar;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure Scrapuj(var scraperVstup,parsujNazev:string;csfdTag:Boolean;
                                    scraperAction:TprocedureSraperAction);
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
      // input data for parrallel downloading job
       pomArrayNazev: array of String;
       pomArrayRok:array of String;
       pomArrayObrazek:array of String;
       pomArrayDej:array of String;
       pomArrayReferer: array of String;

{ pro scraping roku k filmu }
function FilmThemoviedb(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    csfdTag:Boolean;
  procedure scraperAction(v: IXQValue);
  var
      pomNazev,pomRok:String;
      pomRokTDate:TDateTime;

   begin
     FormScraper.vyberReferer.Add('');
      pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      formScraper.vyberObrazku.Add('http://image.tmdb.org/t/p/w154'+
                    (v as TXQValueJSONArray).seq.get(2).toString);
      formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      //pomNazev:=nazev.toString;
      //pomRok:=rok.toString;
      //ShowMessage(v.debugAsStringWithTypeAnnotation());
      if length(pomRok)=4 then   {když api vrací rovnou čtyři znaky roku}
          begin
            formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+pomRok);
            exit;   // ve formScraper.Scrapuj() bylo continue
          end;
      if pomRok='' then pomRokTDate:=0000-00-00
            else
              {themoviedb api vrací RRR-MM-DD}
              pomRokTDate:=(v as TXQValueJSONArray).seq.get(1).toDateTime;
      formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+floattostr(yearof(pomRokTDate)));
      {vyberFilmu.Items.Strings[i] záhadně nefunguje}
   end;

begin

 scraperVstup:='https://api.themoviedb.org/3/search/movie?api_key='+
               unConstants.theMovidedbAPI +'&query='+
               pomNazev+'&language='+aktualniJazyk;
 parsujNazev:='$json("results")() ! [.("title"), .("release_date"),'+
               '.("poster_path"),.("overview")]';

 csfdTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,csfdTag,
                      @scraperAction);{naplní FormScraper výsledkem}
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
    csfdTag:Boolean;

  procedure scraperAction(v: IXQValue);
  var
      pomNazev,pomRok, pomImdbId:String;
      pomRokTDate:TDateTime;
      w: IXQValue;
   begin
      pomImdbId:= (v as TXQValueJSONArray).seq.get(0).toString;
      FormScraper.vyberReferer.Add('Referer: http://www.imdb.com/title/'+
                                   pomImdbId+'/');
      w:= process('http://www.omdbapi.com/?i='+pomImdbId,
                   '$json ! [.("Title"),string(.("Year")),'+
                             'string(.("Poster")),.("Plot")]');
      pomNazev:= (w as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (w as TXQValueJSONArray).seq.get(1).toString;
      formScraper.vyberObrazku.Add((w as TXQValueJSONArray).seq.get(2).toString);
      formScraper.vyberDeju.Add((w as TXQValueJSONArray).seq.get(3).toString);
      //pomNazev:=nazev.toString;
      //pomRok:=rok.toString;
      //ShowMessage(v.debugAsStringWithTypeAnnotation());
      if length(pomRok)=4 then   {když api vrací rovnou čtyři znaky roku}
          begin
            formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+pomRok);
            exit;   // ve formScraper.Scrapuj() bylo continue
          end;
      if pomRok='' then pomRokTDate:=0000-00-00
            else
              {themoviedb api vrací RRR-MM-DD}
              pomRokTDate:=(v as TXQValueJSONArray).seq.get(1).toDateTime;
      formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+floattostr(yearof(pomRokTDate)));
      {vyberFilmu.Items.Strings[i] záhadně nefunguje}
   end;

begin
 scraperVstup:='http://www.omdbapi.com/?s='+
                defaultInternet.urlEncodeData(PomNazev)+
                '&type=movie';
 parsujNazev:='$json("Search")()![.("imdbID")]';
 csfdTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,csfdTag,@scraperAction);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     FilmImdb:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      FilmImdb:='';
     end;
end;

procedure parallelDownloadJob(const Job:PPasMPJob;const ThreadIndex:longint;
                                 const pointerNaV:pointer;const FromIndex,ToIndex:longint);
var
  pomOdkazNaFilm, pomZtazeno: String;
  v,w: IXQValue;
begin
   //DebuglnThreadLog('Thread Index: ' + inttostr(ThreadIndex));
   //DebuglnThreadLog('From Index: ' + inttostr(fromIndex));
   //DebuglnThreadLog('To Index: ' + inttostr(toIndex));
   v:= IXQValue(pointerNav^);
   pomOdkazNaFilm:= ( v as TXQValueObject).getProperty('odkaz').get(fromIndex+1).toString;
   //DebuglnThreadLog('pomOdkazNaFilm:'+ pomOdkazNaFilm);
   try
     pomZtazeno:= retrieve('http://www.csfd.cz'+pomOdkazNaFilm);
     pomArrayReferer[fromIndex]:='Referer: http://www.csfd.cz'+pomOdkazNaFilm;
   except
     on e:Exception do DebuglnThreadLog(e.ToString);
   end;
   if defaultInternet.lastHTTPHeaders.IndexOf(
           'Content-Encoding: gzip') <> -1 then
       begin
        pomZtazeno:=decompress(pomZtazeno);
        //DebuglnThreadLog(
        //            '***** gzip unpacked in multithread attempt :-) *****');
       end;
   w:= process(pomZtazeno,
               '<div id="poster" class="image" template:optional="true">' + slineBreak +
               '    <img> {obrazek:=@src} </img> ' + slineBreak +
               '</div>' + slineBreak +
               '<div class="info" template:optional="true">' + slineBreak +
               '     <div class="header">' + slineBreak +
               '		<h1>{nazev:=text()}</h1>' + slineBreak +
               '     </div>' + slineBreak +
               '     <p></p>' + slineBreak +
               '     <p> <template:read var="rok" source="text()" regex="(\d\d\d\d)"/> </p>' + slineBreak +
               '</div>' + slineBreak +
               '<div data-truncate="570" template:optional="true">' + slineBreak +
               '	<span class="dot icon icon-bullet"></span>' + slineBreak +
               '           {dej:=text()}' + slineBreak +
               '    <span class="source"></span>' + slineBreak +
               '</div>');
   pomArrayObrazek[fromIndex]:= (w as TXQValueObject).getProperty('obrazek').get(1).toString;
   //DebuglnThreadLog(pomArrayObrazek[fromIndex]);
   if (Pos('http:',pomArrayObrazek[fromIndex]) = 0) then
           pomArrayObrazek[fromIndex]:='http:'+pomArrayObrazek[fromIndex];
   pomArrayNazev[fromIndex]:=(w as TXQValueObject).getProperty('nazev').get(1).toString;
   pomArrayRok[fromIndex]:=(w as TXQValueObject).getProperty('rok').get(1).toString;
   pomArrayDej[fromIndex]:=(w as TXQValueObject).getProperty('dej').get(1).toString;

end;

function FilmCsfd(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    csfdTag:Boolean;



   procedure scraperAction(v:IXQValue);
   var
      i,pomI:byte;
      pointerNaV : ^IXQValue;
   begin
    pomI:=(v as TXQValueObject).getProperty('odkaz').Count;
    formScraper.EventLog1.Debug('Počet odkazů: ' +inttostr(pomI))  ;
    if pomI > 5 then pomI:=5; // only 5 search results
    pointerNaV:= @v;
    SetLength(pomArrayNazev,pomI);
    SetLength(pomArrayRok,pomI);
    SetLength(pomArrayObrazek,pomI);
    SetLength(pomArrayDej,pomI);
    SetLength(pomArrayReferer,pomI);
    TPasMP.CreateGlobalInstance;
    if pomI = 1 then
          parallelDownloadJob(nil,0,pointerNaV,0,0)
                 else
          GlobalPasMP.Invoke(
          GlobalPasMP.ParallelFor(pointerNaV,0,pomI-1,@parallelDownloadJob,0,0));
    for i:=0 to pomI-1 do
      begin
        formScraper.vyberFilmu.Items.AddText(pomArrayNazev[i]+'~'+pomArrayRok[i]);
        formScraper.vyberObrazku.Add(pomArrayObrazek[i]);
        formScraper.vyberDeju.Add(pomArrayDej[i]);
        FormScraper.vyberReferer.Add(pomArrayReferer[i]);
      end;
    SetLength(pomArrayNazev,0);
    SetLength(pomArrayRok,0);
    SetLength(pomArrayObrazek,0);
    SetLength(pomArrayDej,0);
    SetLength(pomArrayReferer,0);
    FormScraper.EventLog1.Debug('Vynulování pomArrays hotovo');
 end;

begin

 //scraperVstup:='http://csfdapi.cz/movie?search='+PomNazev;
 //parsujNazev:='$json() ! [.("names")("cs") ,string(.("year"))]';
 scraperVstup:='http://www.csfd.cz/hledat/?q='+PomNazev;
 nahradDiakritiku(scraperVstup);
 parsujNazev:=  '<title> ' + slineBreak +
          '<template:read var="testik" source="text()" /> ' + slineBreak +
          '</title>' + slineBreak +
          '<template:if test = "$testik = ''Vyhledávání | ČSFD.cz''">' + slineBreak +
          '<div id="search-films" class="ct-general th-1">   ' + slineBreak +
          '    <div class="content">   ' + slineBreak +
          '       <ul class="ui-image-list js-odd-even">   ' + slineBreak +
          '        <template:loop>   ' + slineBreak +
          '            <li>   ' + slineBreak +
          '              <div>   ' + slineBreak +
          '                <h3><a>{odkaz:= @href}</a></h3>' + slineBreak +
          '              </div>   ' + slineBreak +
          '           </li>   ' + slineBreak +
          '        </template:loop>   ' + slineBreak +
          '      </ul>                   ' + slineBreak +
          '       <ul template:optional="true" class="films others">' + slineBreak +
          '         <template:loop>   ' + slineBreak +
          '           <li>   ' + slineBreak +
          '              <a>{odkaz:= @href}</a>' + slineBreak +
          '           </li>   ' + slineBreak +
          '         </template:loop>   ' + slineBreak +
          '      </ul> ' + slineBreak +
          '   </div>   ' + slineBreak +
          '</div>      ' + slineBreak +
          '</template:if>' + slineBreak +
          '<template:else>' + slineBreak +
          '   <li class="overview selected">' + slineBreak +
          '		<a> {odkaz:=@href}</a>' + slineBreak +
          '  </li>' + slineBreak +
          '</template:else>' ;
 csfdTag:=True;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,csfdTag,@scraperAction);{naplní FormScraper výsledkem}
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
    csfdTag:Boolean;

  procedure scraperAction(v:IXQValue);
   var
      pomNazev,pomRok:String;
      pomRokTDate:TDateTime;

   begin
     FormScraper.vyberReferer.Add('');
      pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      formScraper.vyberObrazku.Add('http://image.tmdb.org/t/p/w154'+
                    (v as TXQValueJSONArray).seq.get(2).toString);
      formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      //pomNazev:=nazev.toString;
      //pomRok:=rok.toString;
      //ShowMessage(v.debugAsStringWithTypeAnnotation());
      if length(pomRok)=4 then   {když api vrací rovnou čtyři znaky roku}
          begin
            formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+pomRok);
            exit;   // ve formScraper.Scrapuj() bylo continue
          end;
      if pomRok='' then pomRokTDate:=0000-00-00
            else
              {themoviedb api vrací RRR-MM-DD}
              pomRokTDate:=(v as TXQValueJSONArray).seq.get(1).toDateTime;
      formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+floattostr(yearof(pomRokTDate)));
      {vyberFilmu.Items.Strings[i] záhadně nefunguje}
   end;

begin

  scraperVstup:=UTF8ToSys(('https://api.themoviedb.org/3/search/tv?api_key='+
                            unConstants.theMovidedbAPI+'&query='+
                            pomNazev+'&language='+aktualniJazyk));

 parsujNazev:='$json("results")() ! [.("name"), .("first_air_date"),'+
               '.("poster_path"),.("overview")]';
 csfdTag:=False;
 //ShowMessage('aktuální jazyk: ' + aktualniJazyk + sLineBreak+
 //             scraperVstup );
 FormScraper.Scrapuj(scraperVstup,parsujNazev,csfdTag,@scraperAction);{naplní FormScraper výsledkem}
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
    csfdTag:Boolean;

   procedure scraperAction(v:IXQValue);
   var
      pomNazev,pomRok:String;
      pomRokTDate:TDateTime;
   begin
      FormScraper.vyberReferer.Add('');
      pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      formScraper.vyberObrazku.Add((v as TXQValueJSONArray).seq.get(2).toString);
      formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      //pomNazev:=nazev.toString;
      //pomRok:=rok.toString;
      //ShowMessage(v.debugAsStringWithTypeAnnotation());
      if length(pomRok)=4 then   {když api vrací rovnou čtyři znaky roku}
          begin
            formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+pomRok);
            exit;   // ve formScraper.Scrapuj() bylo continue
          end;
      if pomRok='' then pomRokTDate:=0000-00-00
            else
              {themoviedb api vrací RRR-MM-DD}
              pomRokTDate:=(v as TXQValueJSONArray).seq.get(1).toDateTime;
      formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+floattostr(yearof(pomRokTDate)));
      {vyberFilmu.Items.Strings[i] záhadně nefunguje}
   end;

begin
  scraperVstup:='http://api.tvmaze.com/search/shows?q='+PomNazev;
 //for $prom in  $json()("show")
 //return [$prom("name"),$prom("premiered")]
 parsujNazev:='$json()("show") ! [.("name") ,string(.("premiered")), '+
                                 'string(.("image")("medium")),.("summary")]';
 csfdTag:=False;
 nahradDiakritiku(scraperVstup);
 FormScraper.Scrapuj(scraperVstup,parsujNazev,csfdTag,@scraperAction);{naplní FormScraper výsledkem}
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
    csfdTag:Boolean;
    token:String;

   procedure scraperAction(v:IXQValue);
   begin
       ShowMessage(scraperVstup);
   end;
begin
   // to receive the token for API 2.1.0
   defaultInternet.additionalHeaders.Add('Content-Type: application/json');
   defaultInternet.additionalHeaders.Add('Accept: application/json');
   // to add token to request header
   token:= process(defaultInternet.post('https://api.thetvdb.com/login',
                       '{"apikey": "'+unConstants.theTvdbAPI+'"}'),
                       '$json("token")').toString;
   defaultInternet.additionalHeaders.Add('Authorization: Bearer '+token);
   // to add language to the request header
   defaultInternet.additionalHeaders.Add('Accept-Language: '+aktualniJazyk);
   scraperVstup:= 'https://api.thetvdb.com/search/series?name='+pomNazev;
  // {API 1.0} scraperVstup:= 'http://www.thetvdb.com/api/GetSeries.php?seriesname='+pomNazev+
  // {API 1.0}                '&language='+aktualniJazyk;
  parsujNazev:='$json("data")()! [.("seriesName") ,string(.("firstAired"))]';
 //parsujNazev:= 'for $prom in Data/series' + sLineBreak +
 //          'return [string($prom/seriesname/text()) ,string($prom/firstaired/text())]';
 // {API 1.0} parsujNazev:= 'Data/series ! [string(./seriesname/text()) ,string(./firstaired/text())]';
 csfdTag:=False;
 nahradDiakritiku(scraperVstup);
  //ShowMessage(format('%s', [defaultInternet.additionalHeaders.Text]) );
 FormScraper.Scrapuj(scraperVstup,parsujNazev,csfdTag,@scraperAction);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     SerialThetvdb:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      SerialThetvdb:='0';
     end;
end;

function SerialCsfd(PomNazev: string): string; // nahrazeno filmCsfd

begin
 Result:='';
end;

{$R *.lfm}

{ TFormScraper }

procedure TFormScraper.Scrapuj(var scraperVstup,parsujNazev:string;csfdTag:Boolean;
                                scraperAction:TprocedureSraperAction);

var
        v: IXQValue;
        //Nazev,Rok:IXQValue;
        i: Integer;
        ztazeno: String;
        pamatuj1: Char;
        pamatuj2: String;
begin
    vyberFilmu.Clear;
    vyberObrazku.Clear;
    imgObrazek.Picture.Clear;
    memDej.Clear;
    vyberDeju.Clear;
    vyberReferer.Clear;
    nenalezeno:=false;
    { zapamatuj si defaultní formát data }
    pamatuj1:=DefaultFormatSettings.DateSeparator;
    pamatuj2:=DefaultFormatSettings.ShortDateFormat;
    { nastav formát data používaný stránkami }
    DefaultFormatSettings.DateSeparator:='-';  // defaultní se inicalizuje ze systému z kultury :-)
    DefaultFormatSettings.ShortDateFormat:= 'yyyy-mm-dd'; {themoviedb api vrací RRR-MM-DD}
    {uprav vstup a scrapuj }
     EventLog1.Info('--------------Začátek scrapování--------------------');
     EventLog1.Debug('HTTP header - begin (defaultInternet.additionalHeaders): ');
     EventLog1.Debug(format('%s', [defaultInternet.additionalHeaders.Text]));
     EventLog1.Debug('scraperVstup: '+scraperVstup);
     EventLog1.Debug('csfd tag: '+booltostr(csfdTag,true));
     EventLog1.Debug('query: ' + LeftStr(parsujNazev,100) + ' ...');
        try
          ztazeno:= retrieve(scraperVstup);
        except
          on e:Exception do EventLog1.Debug(e.ToString);
        end;
        // jde o cachování tj. data s úplnými informacemi o filmu
        // se v případě opakovaného volání posílají z cache serveru
        // zazipovaná (gzip)
        //ztazeno:= defaultInternet.post(scraperVstup,'');
        EventLog1.Debug('HTTP header - begin (defaultInternet.lastHTTPHeaders): ');
        EventLog1.Debug(format('%s', [defaultInternet.lastHTTPHeaders.Text]));
        if defaultInternet.lastHTTPHeaders.IndexOf(
              'Content-Encoding: gzip') <> -1 then
                        begin
                         ztazeno:=decompress(ztazeno);
                         EventLog1.Debug('***** gzip unpacked :-) *****');
                        end;

    EventLog1.Debug('ztazeno: '+ LeftStr(ztazeno,100)+' ...');
    if (IsWordPresent('"total_results":0}',ztazeno,[','])) or
       (Pos('not found!',ztazeno) > 0)                      or
       ((ztazeno = '[]')and (aktualniScraperFilm = ScraperyFilm[csfd]))
       {specialita csfd api :-) někdy}
                       then
                            begin
                              nenalezeno:=true;
                              exit;
                            end;

      for v in process (ztazeno,parsujNazev) do scraperAction(v);

     EventLog1.Debug(format('%s %s', ['Kapacita obrázků: ',inttostr(vyberObrazku.Count)]));
     EventLog1.Debug(format('%s %s', ['Kapacita dějů: ',inttostr(vyberDeju.Count)]));
    defaultInternet.additionalHeaders.Clear;//vynulování dodatečné hlavičky HTTP
                                            // s hlavičkou pracuje thetvdb api 2.0.1

    if vyberFilmu.Items.Count<>0 then
            begin
             vyberFilmu.Selected[0]:=True;
             vyberFilmu.Click;
            end
                                 else
           begin
             nenalezeno:=true;
             eventlog1.Debug('nenalezeno: '+
                              booltostr(nenalezeno,true));
            // exit;
           end;

    { vrať zpět defaultní formát data }
    DefaultFormatSettings.DateSeparator:=pamatuj1;
    DefaultFormatSettings.ShortDateFormat:= pamatuj2;
    EventLog1.Info('-----------------------------------------------------');
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
var
    pomStream: TMemoryStream;
    pomAdresa: String;
    pomIndex:Byte;
begin
  ProgressBar1.Position:=0;
  pomIndex:=vyberFilmu.ItemIndex;
  pomAdresa:=vyberObrazku.Strings[pomIndex];
  if (pomAdresa <> '') and (pomAdresa <> 'N/A')  then
     begin
        pomStream:=TMemoryStream.Create;
        try
          try
           // nastav referrer pro umožnění stáhnutí ;-)
           defaultInternet.additionalHeaders.Text:=vyberReferer.Strings[pomIndex];
           defaultInternet.get(pomAdresa,pomStream);
           defaultInternet.additionalHeaders.Text:='';
           pomStream.Seek(0,soFromBeginning);
           imgObrazek.Picture.LoadFromStream(pomStream);
          Except
            on E: Exception do
            begin
              EventLog1.Debug(e.ToString);
              imgObrazek.Picture.LoadFromFile('no_poster-v2.png');
            end;
          end;
        finally
          pomStream.Free;
        end;
     end
                     else
     imgObrazek.Picture.LoadFromFile('no_poster-v2.png');
  memDej.clear;
  memDej.Lines.BeginUpdate;
  memDej.Append(vyberDeju.Strings[vyberFilmu.ItemIndex]);
  memDej.Lines.EndUpdate;
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
   ScraperySerial[Scsfd]:=@(FilmCsfd); //@(SerialCsfd);
  { vytvoření aktuálních scraperu z ini, možno až po vytvoření FormNastaveni (unit7)
    jinak segmentation error za runtimu}
  aktualniScraperFilm:=ScraperyFilm[TScraperFilm(FormNastaveni.FilmScrapers.ItemIndex)];
  aktualniScraperSerial:=ScraperySerial[TScraperSerial(FormNastaveni.SerialScrapers.ItemIndex)];
  FormNastaveni.nastavStatusBar;
  // vytvoření TStringList pro scrapování obrázků a dějů a pomocných referrers
  vyberObrazku:=TStringList.Create;
  vyberDeju:=TStringList.Create;
  vyberReferer:=TStringList.Create;
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

