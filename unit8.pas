unit Unit8;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FileUtil, TplTimerUnit, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, simpleinternet,
  simplehtmltreeparser, extendedhtmlparser, xquery, xquery_json, dateutils,
  strutils,LazUTF8,character_utf8tools,eventlog, LocalizedForms,bbutils,unConstants,
  zuncomprfp, pasMP, LCLProc, ghashmap, Generics.Hashes,contnrs;

type

  { for thetvdb.com genres - languages }
  { InnerDictionary }
  proHashInnerDict = class
    public
      class function hash(a:String;b:SizeUInt):SizeUInt;
  end;
  InnerDictionary = specialize THashmap<string,string,proHashInnerDict>;


  { TGenresTheTVDB }
  ProHashTheTVDB = class
    public
      class function hash(a:String;b:SizeUInt):SizeUInt;
  end;
  TGenresTheTVDB = specialize THashmap<String,InnerDictionary,ProHashTheTVDB>;


  { for moviedb genres - languages }
  ProHash = class
      public
          class function hash(a:LongInt;b:LongInt):LongInt;
  end;
  TGenresMovieDB = specialize THashmap<LongInt,String,proHash>;


  { pro scraping roku k filmu - languages }
  Tjazyky = (English, Svenska, Norsk, Dansk, Suomeksi, Nederlands, Deutsch, Italiano,
             Espanol, Francais, Polski, Magyar, Greek, Turkish, Russian, Hebrew,
             Japanese, Portuguese, Chinese, Czech, Slovenian, Croatian, Korean);

  { pro scraping roku k filmu }
  TScraperFilm = (Fthemoviedb,imdb,csfd);
  TfunctionScraperFilm = function(PomNazev:string):string;
  TprocedureInitGenresLanguageFilm = procedure(lang:string);

  { pro scraping roku k seriálu }
  TScraperSerial = (Sthemoviedb,tvmaze,thetvdb,Scsfd);
  TfunctionScraperSerial =  function(PomNazev:string):string;
  TprocedureInitGenresLanguageSerial = procedure(lang:string);

  { general action for all scrapers - něco jako closures ve Swiftu :-) }
  TprocedureSraperAction = procedure(v: IXQValue) is nested;


  { pro scraping episodes detail for TVseries - begin }
  { TEpisodeInfo - 3rd level of dictionary }
  proHashTEpisodeInfo = class
    public
      class function hash(a:String;b:SizeUInt):SizeUInt;
  end;
  TEpisodeInfo = specialize THashmap<String,String,proHashTEpisodeInfo>;

  { TEpisodeInSeason - 2nd level of dictionary }
  proHashTEpisodeInSeason = class
    public
      class function hash(a:String;b:SizeUInt):SizeUInt;
  end;
  TEpisodeInSeason = specialize THashmap<String,TEpisodeInfo,proHashTEpisodeInSeason>;

  { TEpisodeInfoAll - 1st level of dictionary }
  proHashTEpisodeInfoAll = class
    public
      class function hash(a:String;b:SizeUInt):SizeUInt;
  end;
  TEpisodeInfoAll = specialize THashmap<String,TEpisodeInSeason,proHashTEpisodeInfoAll>;

  { TEpisodeInfoComplete - encapsulate data and inner levels references b/c THashmap
                           does not take into account nested objects deallocation}
  TEpisodeInfoComplete = class
    episodeInfoAll : TEpisodeInfoAll;
    references: TFPObjectList;
    constructor create;
    destructor destroy; override;
  end;

  TfunctionSraperEpisodeDetail = function(id:String):TEpisodeInfoComplete;

  { pro scraping episodes detail for TVseries - end }


  { TFormScraper }

  TFormScraper = class(TLocalizedForm)
    edtHodnoceni: TEdit;
    edtZanry: TEdit;
    pauseButton: TButton;
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
    vyberZanru:TStringList;                  { seznam nascrapovaných řetězců žánrů }
    vyberHodnoceni:TStringList;              { seznam nascrapovaných řetězců hodnocení }
    vyberIDSerie:TStringList;                { seznam nascrapovaných id serií }
    ProgressBar1: TProgressBar;
    procedure FormDestroy(Sender: TObject);
    procedure pauseButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure Scrapuj(var scraperVstup,parsujNazev:string;theTvDbTag:Boolean;
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
    idSerie:String; // nutné pro episode info scraping for nfo creating
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
  { helper for moviedb scrapers genres initialization }
  procedure initGenres(var tabulka:TGenresMovieDB;
                           pathToFile:String;
                           parseString:String);
  { for init genres of film scrapers }
  procedure initGenresMovieDBFilm(lang:String);
  procedure initGenresImdbFilm(lang:String);
  procedure initGenresCsfdFilm(lang:String);
  { for init genres of series scrapers }
  procedure initGenresThemoviedbSerial(lang:string);
  procedure initGenresTvmazeSerial(lang:string);
  procedure initGenresThetvdbSerial(lang:string);  // not use b/c initialised only once
  procedure initGenresThetvdbSerialOnce(lang:string);
  procedure initGenresCsfdSerial(lang:string);
  { pro scraping episode details for TV Series }
  function SerialThemoviedbEpisodes(id:string):TEpisodeInfoComplete;
  function SerialTvmazeEpisodes(id:string):TEpisodeInfoComplete;
  function SerialThetvdbEpisode(id:string):TEpisodeInfoComplete;
  function SerialCsfdEpisode(id:string):TEpisodeInfoComplete;
  { pro scraping fanart and poster for thetvdb.com nfo creating }
  procedure getPosterFanart(cesta:String;id:String);

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
  genresMovieDB : TgenresMovieDB;              // for moviedDB film scraper
  genresMovieDBSerial:TGenresMovieDB;          // for moviedDB serial scraper
  InitGenresLanguageFilm :array[TScraperFilm] of TprocedureInitGenresLanguageFilm;
  InitGenresLanguageSerial:array[TScraperSerial] of TprocedureInitGenresLanguageSerial;
  genresTheTVDB : TGenresTheTVDB;              // for TheTVDB searial scraper
  pomSlovnik:InnerDictionary;                // inner Dictionary from movidedb-genres-film.json
  pomSlovnikReferences:TFPObjectList;        // list refereces for dealocation
  scraperyEpizody : array[TScraperSerial] of TfunctionSraperEpisodeDetail;
  aktualniScraperEpisody:TfunctionSraperEpisodeDetail;



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
       pomArrayZanry:array of String;
       pomArrayHodnoceni:array of String;
       pomArrayReferer: array of String;
       pomArrayHeaders: array[0..3] of String;
       pomArrayIDSerie: array of String;


function mojeHashFunkce(s:String):LongInt;
begin
 result:= SimpleChecksumHash(pchar(s), s.Length);
end;

{ TEpisodeInfoComplete }

constructor TEpisodeInfoComplete.create;
begin
  self.episodeInfoAll:=TEpisodeInfoAll.create;
  self.references:=TFPObjectList.create;
end;

destructor TEpisodeInfoComplete.destroy;
begin
  self.episodeInfoAll.Free;
  self.references.Free;
  inherited destroy;
end;

{ proHashTEpisodeInfoAll }

class function proHashTEpisodeInfoAll.hash(a: String; b: SizeUInt): SizeUInt;
begin
  hash := mojeHashFunkce(a) mod b;
end;

{ proHashTEpisodeInSeason }

class function proHashTEpisodeInSeason.hash(a: String; b: SizeUInt): SizeUInt;
begin
  if b=0 then
     hash := 0
  else
    hash := mojeHashFunkce(a) mod b;
end;

{ proHashTEpisodeInfo }

class function proHashTEpisodeInfo.hash(a: String; b: SizeUInt): SizeUInt;
begin
  hash := mojeHashFunkce(a) mod b;
end;

{ ProHashTheTVDB }

class function ProHashTheTVDB.hash(a: String; b: SizeUInt): SizeUInt;
begin
  hash := mojeHashFunkce(a) mod b;
end;

{ proHashInnerDict }

class function proHashInnerDict.hash(a: String; b: SizeUInt): SizeUInt;
begin
  hash := mojeHashFunkce(a) mod b;
end;


{ for moviedb genres - languages }
class function proHash.hash(a: LongInt; b: LongInt): LongInt;
begin
 hash:=a mod b;
end;

{ pro scraping roku k filmu }
function FilmThemoviedb(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    theTvDbTag:Boolean;
  procedure scraperAction(v: IXQValue);
  var
      pomNazev,pomRok,pomObr, pomText:String;
      pomRokTDate:TDateTime;
      pomList: TXQVList;
      pomArray: TXQValueJSONArray;
      pom:IXQValue;

   begin
     FormScraper.vyberReferer.Add('');
      pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      pomObr:= (v as TXQValueJSONArray).seq.get(2).toString;
      if pomObr = 'null' then
               formScraper.vyberObrazku.Add('')
                     else
               formScraper.vyberObrazku.Add(
                     'http://image.tmdb.org/t/p/w154'+pomObr);
      formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      pomArray:=((v as TXQValueJSONArray).seq.get(4)) as TXQValueJSONArray;
      // pomText:=pomArray.jsonSerialize(tnsText);
      pomText:='';
      for pom in pomArray.GetEnumeratorMembers do
            pomText:= pomText + genresMovieDB.GetData(pom.toInt64)+ ', ';
      RemoveTrailingChars(pomText,[' ',',']);
      formScraper.vyberZanru.Add(pomText);
      formScraper.vyberHodnoceni.Add((v as TXQValueJSONArray).seq.get(5).toString);

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
               '.("poster_path"),.("overview"),'+
                '.("genre_ids"),.("vote_average")]';

 theTvDbTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,theTvDbTag,
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
    theTvDbTag:Boolean;

  procedure scraperAction(v: IXQValue);
  var
      pomNazev,pomRok, pomImdbId:String;
      pomRokTDate:TDateTime;
      w: IXQValue;
   begin
      pomImdbId:= (v as TXQValueJSONArray).seq.get(0).toString;
      //formScraper.EventLog1.Debug('konec první části imdbID: '+pomImdbId);
      formScraper.vyberReferer.Add('Referer: http://www.imdb.com/title/'+
                                   pomImdbId+'/');
      w:= process('http://www.omdbapi.com/?i='+pomImdbId,
                   '$json ! [.("Title"),string(.("Year")),'+
                             'string(.("Poster")),.("Plot"),'+
                             '.("Genre"),string(.("imdbRating"))]');
      pomNazev:= (w as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (w as TXQValueJSONArray).seq.get(1).toString;
      formScraper.vyberObrazku.Add((w as TXQValueJSONArray).seq.get(2).toString);
      formScraper.vyberDeju.Add((w as TXQValueJSONArray).seq.get(3).toString);
      FormScraper.vyberZanru.Add((w as TXQValueJSONArray).seq.get(4).toString);
      FormScraper.vyberHodnoceni.Add((w as TXQValueJSONArray).seq.get(5).toString);
      //formScraper.EventLog1.Debug('konec druhé části imdbID: '+pomImdbId);
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
 theTvDbTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,theTvDbTag,@scraperAction);{naplní FormScraper výsledkem}
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

  procedure Calculate;
  // due to the necessity to separate calculate and run part to avoid memory leaks
  // see: https://github.com/benibela/internettools/issues/12
  var
    pomOdkazNaFilm, pomZtazeno, pomString: String;
    v: IXQValue;
    t: THtmlTemplateParser;
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

     t:=THtmlTemplateParser.create;
     // nahrazení w:= process((pomZtazeno, template ...)
     // template loading
     t.parseTemplate('<div id="poster" class="image" template:optional="true">  ' + slineBreak +
          '    <img> {obrazek:=@src} </img> ' + slineBreak +
          '</div> ' + slineBreak +
          '<div class="info" template:optional="true">  ' + slineBreak +
          '    <div class="header"> ' + slineBreak +
          '  		 <h1>{nazev:=text()}</h1> ' + slineBreak +
          '    </div>' + slineBreak +
          '    <p class="genre"> {zanr:=text()}</p> ' + slineBreak +
          '    <p> ' + slineBreak +
          '       <span itemprop="dateCreated"> ' + slineBreak +
          '           <template:read var="rok" source="text()" regex="(\d\d\d\d)"/>' + slineBreak +
          '       </span>   ' + slineBreak +
          '    </p>      ' + slineBreak +
          '</div> ' + slineBreak +
          '<div data-truncate="570" template:optional="true"> ' + slineBreak +
          '  	<span class="dot icon icon-bullet"></span>      ' + slineBreak +
          '        {dej:=deep-text()}' + slineBreak +
          '    <span class="source"></span> ' + slineBreak +
          '</div>' + slineBreak +
          '<h2 class="average">' + slineBreak +
          '  <template:read var="hodnoceni" source="text()" regex="(\d*)"/>' + slineBreak +
          '</h2>');
     // parsing with loaded template
     t.parseHTML(pomZtazeno);
     // using parsing result
     pomArrayObrazek[fromIndex]:= t.variables.Values['obrazek'].toString;
     //DebuglnThreadLog(pomArrayObrazek[fromIndex]);
     if (Pos('http',pomArrayObrazek[fromIndex]) = 0) then
             pomArrayObrazek[fromIndex]:='http:'+pomArrayObrazek[fromIndex];
     pomArrayNazev[fromIndex]:=t.variables.Values['nazev'].toString;
     pomArrayRok[fromIndex]:=t.variables.Values['rok'].toString;
     pomArrayDej[fromIndex]:=t.variables.Values['dej'].toString;
     pomString:= t.variables.Values['zanr'].toString;
     pomArrayZanry[fromIndex]:= StringReplace(pomString,' /',',',[rfReplaceAll]);
     pomArrayHodnoceni[fromIndex]:=t.variables.Values['hodnoceni'].toString;
     t.free;
  end;

begin  // run parallelDownloadJob
   Calculate;
   freeThreadVars;
end;

function FilmCsfd(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    theTvDbTag:Boolean;

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
    SetLength(pomArrayZanry,pomI);
    SetLength(pomArrayHodnoceni,pomI);
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
        formScraper.vyberZanru.Add(pomArrayZanry[i]);
        FormScraper.vyberHodnoceni.Add(pomArrayHodnoceni[i]);
        FormScraper.vyberReferer.Add(pomArrayReferer[i]);
      end;
    SetLength(pomArrayNazev,0);
    SetLength(pomArrayRok,0);
    SetLength(pomArrayObrazek,0);
    SetLength(pomArrayDej,0);
    SetLength(pomArrayZanry,0);
    SetLength(pomArrayHodnoceni,0);
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
 theTvDbTag:=False;
 FormScraper.Scrapuj(scraperVstup,parsujNazev,theTvDbTag,@scraperAction);{naplní FormScraper výsledkem}
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
    theTvDbTag:Boolean;

  procedure scraperAction(v:IXQValue);
   var
      pomNazev,pomRok,pomObr,pomText:String;
      pomRokTDate:TDateTime;
      pomArray: TXQValueJSONArray;
      pom:IXQValue;

   begin
     FormScraper.vyberReferer.Add('');
      pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      pomObr:= (v as TXQValueJSONArray).seq.get(2).toString;
      //ShowMessage(pomObr);
      if pomObr = 'null' then
               formScraper.vyberObrazku.Add('')
                     else
               formScraper.vyberObrazku.Add(
                     'http://image.tmdb.org/t/p/w154'+pomObr);
      formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      pomArray:=((v as TXQValueJSONArray).seq.get(4)) as TXQValueJSONArray;
      // pomText:=pomArray.jsonSerialize(tnsText);
      pomText:='';
      for pom in pomArray.GetEnumeratorMembers do
            pomText:= pomText + genresMovieDBSerial.GetData(pom.toInt64)+ ', ';
      RemoveTrailingChars(pomText,[' ',',']);
      formScraper.vyberZanru.Add(pomText);
      formScraper.vyberHodnoceni.Add((v as TXQValueJSONArray).seq.get(5).toString);
      formScraper.vyberIDSerie.Add((v as TXQValueJSONArray).seq.get(6).toString);
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
               '.("poster_path"),.("overview"),'+
                '.("genre_ids"),.("vote_average"),.("id")]';
 theTvDbTag:=False;
 //ShowMessage('aktuální jazyk: ' + aktualniJazyk + sLineBreak+
 //             scraperVstup );
 FormScraper.Scrapuj(scraperVstup,parsujNazev,theTvDbTag,@scraperAction);{naplní FormScraper výsledkem}
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
    theTvDbTag:Boolean;

   procedure scraperAction(v:IXQValue);
   var
      pomNazev,pomRok, pomText:String;
      pomRokTDate:TDateTime;
      pomArray: TXQValueJSONArray;
      pom: IXQValue;
   begin
      FormScraper.vyberReferer.Add('');
      pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      formScraper.vyberObrazku.Add((v as TXQValueJSONArray).seq.get(2).toString);
      formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      pomArray:=((v as TXQValueJSONArray).seq.get(4)) as TXQValueJSONArray;
      // pomText:=pomArray.jsonSerialize(tnsText);
      pomText:='';
      for pom in pomArray.GetEnumeratorMembers do
            pomText:= pomText + pom.toString + ', ';
      RemoveTrailingChars(pomText,[' ',',']);
      formScraper.vyberZanru.Add(pomText);
      formScraper.vyberHodnoceni.Add((v as TXQValueJSONArray).seq.get(5).toString);
      formScraper.vyberIDSerie.Add((v as TXQValueJSONArray).seq.get(6).toString);
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
                                 'string(.("image")("medium")),.("summary"),' +
                                 '.("genres"),.("rating")("average"),.("id")]';
 theTvDbTag:=False;
 nahradDiakritiku(scraperVstup);
 FormScraper.Scrapuj(scraperVstup,parsujNazev,theTvDbTag,@scraperAction);{naplní FormScraper výsledkem}
 if  FormScraper.ShowModal = mrOK then
     SerialTvmaze:=FormScraper.vybranyRok
                                   else
     begin
      FormScraper.vybranyNazev:=PomNazev;
      SerialTvmaze:='0';
     end;
end;

procedure theTVDB_parallelDownloadJob(const Job:PPasMPJob;const ThreadIndex:longint;
                                 const pointerNaV:pointer;const FromIndex,ToIndex:longint);
var
  pomOdkazNaFilm, pomZtazeno, pomString,token, pomRok, pomObr, pomText: String;
  pomRokTDate:TDateTime;
  v,w,pomZanr, pom: IXQValue;
  pomArray: TXQValueJSONArray;
begin
   //DebuglnThreadLog('Thread Index: ' + inttostr(ThreadIndex));
   //DebuglnThreadLog('From Index: ' + inttostr(fromIndex));
   //DebuglnThreadLog('To Index: ' + inttostr(toIndex));
   v:= IXQValue(pointerNav^);
   if Job = nil  then
      pomOdkazNaFilm:= v.toString
                 else
      pomOdkazNaFilm:= ( v as TXQValueSequence).get(fromIndex+1).toString;
   //DebuglnThreadLog('pomOdkazNaFilm:'+ pomOdkazNaFilm);
   try
     defaultInternet.additionalHeaders.Add(pomArrayHeaders[0]);
     defaultInternet.additionalHeaders.Add(pomArrayHeaders[1]);
     // to add token to request header
     defaultInternet.additionalHeaders.Add(pomArrayHeaders[2]);
     // to add language to the request header
     defaultInternet.additionalHeaders.Add(pomArrayHeaders[3]);
     pomZtazeno:= retrieve('https://api.thetvdb.com/series/'+pomOdkazNaFilm);
     pomArrayReferer[fromIndex]:='';
   except
     on e:Exception do DebuglnThreadLog(e.ToString);
   end;
   w:= process(pomZtazeno,
              '$json("data")! [.("seriesName") ,string(.("firstAired")),' + slineBreak +
                              '.("banner"), .("overview"),' + slineBreak +
                              '.("genre"), .("siteRating"),.("id")]');
   //DebuglnThreadLog(defaultInternet.additionalHeaders.DelimitedText);

      pomArrayNazev[fromIndex]:= (w as TXQValueJSONArray).seq.get(0).toString;
      pomRok:= (w as TXQValueJSONArray).seq.get(1).toString;
      pomObr:= (w as TXQValueJSONArray).seq.get(2).toString;
      if pomObr = '' then
         pomArrayObrazek[fromIndex]:=pomObr
                      else
         pomArrayObrazek[fromIndex]:= 'http://www.thetvdb.com/banners/_cache/'+pomObr;
      pomArrayDej[fromIndex] := (w as TXQValueJSONArray).seq.get(3).toString;
      if pomRok='' then
         pomRokTDate:=0000-00-00
                   else
         {themoviedb api vrací RRR-MM-DD}
         pomRokTDate:=(w as TXQValueJSONArray).seq.get(1).toDateTime;
      pomArrayRok[fromIndex] := floattostr(yearof(pomRokTDate));
      //{vyberFilmu.Items.Strings[i] záhadně nefunguje}
      //pomArrayZanry[fromIndex]:= (w as TXQValueJSONArray).seq.get(4).jsonSerialize(tnsText);
      pomArray:= ((w as TXQValueJSONArray).seq.get(4)) as TXQValueJSONArray;
      pomText:='';
      for pom in pomArray.GetEnumeratorMembers do
            pomText:= pomText + genresTheTVDB[pom.toString][aktualniJazyk]+ ', ';
      RemoveTrailingChars(pomText,[' ',',']);
      pomArrayZanry[fromIndex]:= pomText;
      //DebuglnThreadLog(pomArrayZanry[fromIndex]);
      pomArrayHodnoceni[fromIndex]:=(w as TXQValueJSONArray).seq.get(5).toString;
      pomArrayIDSerie[fromIndex]:=(w as TXQValueJSONArray).seq.get(6).toString;
      freeThreadVars;
end;

function SerialThetvdb(PomNazev: string): string;
var
    scraperVstup,parsujNazev:string;
    theTvDbTag:Boolean;
    token:String;

   procedure scraperAction(v:IXQValue);
   var
      i,pomI:byte;
      pointerNaV : ^IXQValue;
   begin
      if v.typeName = 'integer' then
         pomI:=1
                                else
         pomI:=(v as TXQValueSequence).getSequenceCount;
      //formScraper.EventLog1.Debug('Počet odkazů: ' +inttostr(pomI));
      if pomI > 4 then pomI:=4; // only 5 search results
      pointerNaV:= @v;
      SetLength(pomArrayNazev,pomI);
      SetLength(pomArrayRok,pomI);
      SetLength(pomArrayObrazek,pomI);
      SetLength(pomArrayDej,pomI);
      SetLength(pomArrayZanry,pomI);
      SetLength(pomArrayHodnoceni,pomI);
      SetLength(pomArrayReferer,pomI);
      SetLength(pomArrayIDSerie,pomI);
      TPasMP.CreateGlobalInstance;
      if pomI = 1 then
            theTVDB_parallelDownloadJob(nil,0,pointerNaV,0,0)
                   else
            GlobalPasMP.Invoke(
            GlobalPasMP.ParallelFor(pointerNaV,0,pomI-1,@theTVDB_parallelDownloadJob,0,0));
      for i:=0 to pomI-1 do
        begin
          formScraper.vyberFilmu.Items.AddText(pomArrayNazev[i]+'~'+pomArrayRok[i]);
          formScraper.vyberObrazku.Add(pomArrayObrazek[i]);
          formScraper.vyberDeju.Add(pomArrayDej[i]);
          //formScraper.vyberZanru.Add(genresTheTVDB['Animation'][aktualniJazyk]);
          formScraper.vyberZanru.Add(pomArrayZanry[i]);
          FormScraper.vyberHodnoceni.Add(pomArrayHodnoceni[i]);
          FormScraper.vyberReferer.Add(pomArrayReferer[i]);
          FormScraper.vyberIDSerie.Add(pomArrayIDSerie[i]);
        end;
      SetLength(pomArrayNazev,0);
      SetLength(pomArrayRok,0);
      SetLength(pomArrayObrazek,0);
      SetLength(pomArrayDej,0);
      SetLength(pomArrayZanry,0);
      SetLength(pomArrayHodnoceni,0);
      SetLength(pomArrayReferer,0);
      SetLength(pomArrayIDSerie,0);
      FormScraper.EventLog1.Debug('Vynulování pomArrays hotovo');
   end;

      //FormScraper.EventLog1.Debug(format('%s', [pomNazev]))
      //FormScraper.vyberReferer.Add('');
      //pomNazev:= (v as TXQValueJSONArray).seq.get(0).toString;
      //pomRok:= (v as TXQValueJSONArray).seq.get(1).toString;
      //pomObr:= (v as TXQValueJSONArray).seq.get(2).toString;
      //if pomObr = '' then
      //                     formScraper.vyberObrazku.Add(pomObr)
      //                else
      //                     formScraper.vyberObrazku.Add(
      //                     'http://www.thetvdb.com/banners/_cache/'+
      //                      pomObr);
      //formScraper.vyberDeju.Add((v as TXQValueJSONArray).seq.get(3).toString);
      //if pomRok='' then pomRokTDate:=0000-00-00
      //      else
      //        {themoviedb api vrací RRR-MM-DD}
      //        pomRokTDate:=(v as TXQValueJSONArray).seq.get(1).toDateTime;
      //formScraper.vyberFilmu.Items.AddText(pomNazev+'~'+floattostr(yearof(pomRokTDate)));
      //{vyberFilmu.Items.Strings[i] záhadně nefunguje}
      //formScraper.vyberZanru.Add('Pomocný žánr');
      //formScraper.vyberHodnoceni.Add('55,555');

begin
   // to receive the token for API 2.1.0
   pomArrayHeaders[0]:= 'Content-Type: application/json';
   pomArrayHeaders[1]:=  'Accept: application/json';
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[0]);
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[1]);
   // to add token to request header
   token:= process(defaultInternet.post('https://api.thetvdb.com/login',
                                        '{"apikey": "'+unConstants.theTvdbAPI+'"}'),
                   '$json("token")').toString;
   pomArrayHeaders[2]:= 'Authorization: Bearer ' + token;
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[2]);
   //FormScraper.EventLog1.Debug(format('%s', [pomArrayHeaders[2]]));
   // to add language to the request header
   pomArrayHeaders[3]:= 'Accept-Language: '+aktualniJazyk;
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[3]);
   scraperVstup:= 'https://api.thetvdb.com/search/series?name='+pomNazev;
   parsujNazev:='$json("data")()!.("id")';
   theTvDbTag:=True;
   nahradDiakritiku(scraperVstup);
   FormScraper.Scrapuj(scraperVstup,parsujNazev,theTvDbTag,@scraperAction);{naplní FormScraper výsledkem}
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



{$R *.frm}

{ TFormScraper }

procedure TFormScraper.Scrapuj(var scraperVstup,parsujNazev:string;theTvDbTag:Boolean;
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
    vyberZanru.Clear;
    vyberHodnoceni.Clear;
    vyberIDSerie.Clear;
    nenalezeno:=false;
    if theTvDbTag then      // b/c of theTvDb horizontals banners
       begin
        imgObrazek.Left:= 280;
        imgObrazek.Top:=88;
        imgObrazek.Width:=409;
        imgObrazek.Height:=75; // original banner 300x55 means keep ratio :-)
        memDej.Left:=280;
        memDej.Top:=181;  // 88+226/3*2 +20 for border
        memDej.Width:=409;
        memDej.Height:=226 div 2;
       end
                   else
       begin
        imgObrazek.Left:=280;
        imgObrazek.Top:=88;
        imgObrazek.Width:=144;
        imgObrazek.Height:=226;
        memDej.Left:=444;
        memDej.Top:=88;
        memDej.Width:=240;
        memDej.Height:=226;
       end;

    { zapamatuj si defaultní formát data }
    pamatuj1:=DefaultFormatSettings.DateSeparator;
    pamatuj2:=DefaultFormatSettings.ShortDateFormat;
    { nastav formát data používaný stránkami }
    DefaultFormatSettings.DateSeparator:='-';  // defaultní se inicalizuje ze systému z kultury :-)
    DefaultFormatSettings.ShortDateFormat:= 'yyyy-mm-dd'; {themoviedb api vrací RRR-MM-DD}
    {uprav vstup a scrapuj }
     EventLog1.debug('------------------------------Začátek_scrapování------------------------------');
     EventLog1.Debug('HTTP header - begin (defaultInternet.additionalHeaders): ');
     EventLog1.Debug(format('%s', [defaultInternet.additionalHeaders.Text]));
     EventLog1.Debug('scraperVstup: '+ReplaceText(scraperVstup,
                                                  unConstants.theMovidedbAPI,'*****'));
     EventLog1.Debug('csfd tag: '+booltostr(theTvDbTag,true));
     EventLog1.Debug('query: ' + LeftStr(parsujNazev,800) + ' ...');
        try
          ztazeno:= retrieve(scraperVstup);
        except
          on e:Exception do
             begin
               EventLog1.Debug(e.ToString);
               nenalezeno:=true;
               exit;
             end;
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

    EventLog1.Debug('ztazeno: '+ LeftStr(ztazeno,800)+' ...');
    if (IsWordPresent('"total_results":0}',ztazeno,[','])) or
       (Pos('not found!',ztazeno) > 0)                      or
       ((ztazeno = '[]')and (aktualniScraperFilm = ScraperyFilm[csfd]))
       {specialita csfd api :-) někdy}
                       then
                            begin
                              nenalezeno:=true;
                              exit;
                            end;

    if aktualniScraperSerial = ScraperySerial[thetvdb] then
         scraperAction(process(ztazeno,parsujNazev))
                                                       else
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
    EventLog1.Info('--------------------------------------------------------------------------------');
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
  edtZanry.Caption:=vyberZanru[pomIndex];
  edtHodnoceni.Caption:=vyberHodnoceni[pomIndex];
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
      if vyberIDSerie.Count > 0 then
         idSerie:=vyberIDSerie[vyberFilmu.ItemIndex]
                                 else
         idSerie:='';
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

procedure TFormScraper.pauseButtonClick(Sender: TObject);
begin
  Timer1.Enabled:=not(Timer1.Enabled);
end;

procedure TFormScraper.FormDestroy(Sender: TObject);
begin
  vyberObrazku.Free;
  vyberDeju.Free;
  vyberReferer.Free;
  vyberZanru.Free;
  vyberHodnoceni.Free;
  vyberIDSerie.Free;
end;

procedure TFormScraper.FormCreate(Sender: TObject);

begin
  // Rozhoduje EventLog1.FileName -
  //  - když je vyplněno nepomůže ani EventLog1.Active := False;
  //EventLog1.Active:=False; //  must be EventLog1.LogType := ltFile or set in Object inspector
  //EventLog1.Identification:='Scrapping';
  //EventLog1.Pause;
  if FormNastaveni.logyAplikaceNastaveni.Checked[1] then
     begin
      EventLog1.FileName:='scrapping.log';
      EventLog1.Active:=True;
     end
  else
    begin
      EventLog1.FileName:='';
      EventLog1.Active:=False;
    end;
  Timer1.Enabled:=false;
  prvniFokus:=true;

  { vytvoření aktuálních scraperu z ini, možno až po vytvoření FormNastaveni (unit7)
    jinak segmentation error za runtimu, nemůže být v initialisation unitu}
  aktualniScraperFilm:=ScraperyFilm[TScraperFilm(FormNastaveni.FilmScrapers.ItemIndex)];
  aktualniScraperSerial:=ScraperySerial[TScraperSerial(FormNastaveni.SerialScrapers.ItemIndex)];
  aktualniScraperEpisody:=scraperyEpizody[TScraperSerial(FormNastaveni.SerialScrapers.ItemIndex)];
  FormNastaveni.nastavStatusBar;

  {inicializace jazyka pro scrapování,nemůže být v initialization unitu}
  aktualniJazyk:=jazyky[Tjazyky(FormNastaveni.LanguageScrapers.ItemIndex)];

  // inicializace genresMovieDBSerial for serial scraper
  genresMovieDBSerial:=TGenresMovieDB.create;
  initGenres(genresMovieDBSerial,
             'https://api.themoviedb.org/3/genre/tv/list?api_key='+theMovidedbAPI+
             '&language='+aktualniJazyk,'$json("genres")() ! [.("id"), .("name")]');
  //inicializace genresMovieDB for film scraper
  genresMovieDB:=TGenresMovieDB.create;
  initGenres(genresMovieDB,
             'https://api.themoviedb.org/3/genre/movie/list?api_key='+theMovidedbAPI+
             '&language='+aktualniJazyk,'$json("genres")() ! [.("id"), .("name")]');

  // inicializace genresTVDB for serial scraper, different approach - only once !!!!!
  genresTheTVDB:= TGenresTheTVDB.create;
  initGenresThetvdbSerialOnce(aktualniJazyk);


  // vytvoření TStringList pro scrapování obrázků a dějů a pomocných referrers
  vyberObrazku:=TStringList.Create;
  vyberDeju:=TStringList.Create;
  vyberReferer:=TStringList.Create;
  vyberZanru:=TStringList.Create;
  vyberHodnoceni:=TStringList.Create;
  vyberIDSerie:=TStringList.Create;
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

procedure initGenres(var tabulka:TGenresMovieDB;
                           pathToFile:String;
                           parseString:String); //
    var
        w,v:IXQValue;
        i: Integer;
        cislo: Int64;
        nazevGenre: String;
    begin
      // způsobuje memory leak v w32internetaccess.pas řádek:381
      // FLastHTTPHeaders jsou vytvořeny dvakrát ještě v internetaccess.pas řádek:917
      w:=process(pathToFile,parseString);
      i:=1;
      for v in w do
         begin
           cislo:=(v as TXQValueJSONArray).seq.get(0).toInt64;
           nazevGenre:=(v as TXQValueJSONArray).seq.get(1).toString;
           // naplň THashMap
           tabulka.insert(cislo,nazevGenre);
           i:=i+1;
         end;
    end;

procedure initGenresMovieDBFilm(lang: String);
begin
  initGenres(genresMovieDB,
             'https://api.themoviedb.org/3/genre/movie/list?api_key='+theMovidedbAPI+
             '&language='+lang,'$json("genres")() ! [.("id"), .("name")]');
end;

procedure initGenresImdbFilm(lang: String);
begin
  // prepared for possible genre translating
end;

procedure initGenresCsfdFilm(lang: String);
begin
  // prepared for possible genre translating
end;

procedure initGenresThemoviedbSerial(lang: string);
begin
  initGenres(genresMovieDBSerial,
             'https://api.themoviedb.org/3/genre/tv/list?api_key='+theMovidedbAPI+
             '&language='+aktualniJazyk,'$json("genres")() ! [.("id"), .("name")]');
end;

procedure initGenresTvmazeSerial(lang: string);
begin

end;

procedure initGenresThetvdbSerial(lang: string);
begin
  // another approach translation for all available languages are intialised once
  // during creating this form
end;

procedure initGenresThetvdbSerialOnce(lang: string);

var
  w,v,y,x,z:IXQValue;
begin
  pomSlovnikReferences:=TFPObjectList.Create;
  w:=process('file://thetvdb-genres.json',
            '$json()');
  for v in w do
   begin
     x:=process('file://thetvdb-genres.json',
            '$json("'+v.toString+'")()');
     pomSlovnik:=InnerDictionary.create;
     pomSlovnikReferences.Add(pomSlovnik);
     for y in x do
        begin
          z:= process('file://thetvdb-genres.json',
              '$json("'+v.toString+'")("'+y.toString+'")');
          //// fill THashMap pomSlovnik;
          pomSlovnik.insert(y.toString,z.toString);
        end;
     //// naplň THashMap genresTheTVDB;
     genresTheTVDB.insert(v.toString,pomSlovnik);
   end;
end;

procedure initGenresCsfdSerial(lang: string);
begin
  // prepared for possible genre translating
end;

{ pro scraping episode details for TV Series }

function SerialThemoviedbEpisodes(id: string): TEpisodeInfoComplete;
var
  v,w:IXQValue;
  scraperVstup,parsujNazev,pomSeason,ztazeno: String;
  episodeInfo:TEpisodeInfo;             // dictionary 3rd level
  episodeInSeason:TEpisodeInSeason;     // dictionary 2nd level
  episodeInfoComplete:TEpisodeInfoComplete; //whole dictionary + references in one class
  pomEpisodeNumber,pomEpisodeName,pomEpisodeOverview: String;
begin
  episodeInfoComplete:=TEpisodeInfoComplete.create;
  scraperVstup:=UTF8ToSys(('https://api.themoviedb.org/3/tv/'+
                            FormScraper.idSerie +
                            '?api_key='+unConstants.theMovidedbAPI+
                            '&language='+aktualniJazyk));
  parsujNazev:='$json("seasons")()![.("season_number")]';
  ztazeno:= retrieve(scraperVstup);
  for v in process (ztazeno,parsujNazev) do
     begin
       pomSeason:= (v as TXQValueJSONArray).seq.get(0).toString;
       scraperVstup:=UTF8ToSys(('https://api.themoviedb.org/3/tv/'+FormScraper.idSerie+
                                '/season/'   +  pomSeason+
                                '?api_key='  +  unConstants.theMovidedbAPI+
                                '&language=' +  aktualniJazyk));
       parsujNazev:='$json("episodes")()![.("episode_number"),.("name"),.("overview")]';
       ztazeno:=retrieve(scraperVstup);
       episodeInSeason:=TEpisodeInSeason.create;
       episodeInfoComplete.references.Add(episodeInSeason);
       for w in process(ztazeno,parsujNazev) do
          begin
            episodeInfo:=TEpisodeInfo.create;
            episodeInfoComplete.references.add(episodeInfo);
            pomEpisodeNumber:= (w as TXQValueJSONArray).seq.get(0).toString;
            pomEpisodeName:= (w as TXQValueJSONArray).seq.get(1).toString;
            pomEpisodeOverview:= (w as TXQValueJSONArray).seq.get(2).toString;
            episodeInfo.insert('jmeno',pomEpisodeName);
            episodeInfo.insert('obsah',pomEpisodeOverview);
            episodeInSeason.insert(pomEpisodeNumber,episodeInfo);
          end;
       episodeInfoComplete.episodeInfoAll.insert(pomSeason,episodeInSeason);
     end;
  Result:=episodeInfoComplete;
end;

function SerialTvmazeEpisodes(id: string): TEpisodeInfoComplete;
var
  v,w:IXQValue;
  scraperVstup,parsujNazev,pomSeason,ztazeno: String;
  episodeInfo:TEpisodeInfo;             // dictionary 3rd level
  episodeInSeason:TEpisodeInSeason;     // dictionary 2nd level
  episodeInfoComplete:TEpisodeInfoComplete; //whole dictionary + references in one class
  pomEpisodeNumber,pomEpisodeName,pomEpisodeOverview: String;
  pomSeasonReal: Byte;
begin
  episodeInfoComplete:=TEpisodeInfoComplete.create;
  scraperVstup:=UTF8ToSys(('http://api.tvmaze.com/shows/'+
                            FormScraper.idSerie + '/seasons' ));
  parsujNazev:='$json()("id")';
  ztazeno:= retrieve(scraperVstup);
  pomSeasonReal:=0; // id is unique for record on site, we need sequence number
  for v in process (ztazeno,parsujNazev) do
     begin
       pomSeason:= v.toString;
       pomSeasonReal:=pomSeasonReal+1;
       scraperVstup:=UTF8ToSys(('http://api.tvmaze.com/seasons/'+pomSeason+
                                '?embed=episodes'));
       parsujNazev:=('$json("_embedded")("episodes")()'+
                     '![.("number"),.("name"),.("summary")]');
       ztazeno:=retrieve(scraperVstup);
       episodeInSeason:=TEpisodeInSeason.create;
       episodeInfoComplete.references.Add(episodeInSeason);
       for w in process(ztazeno,parsujNazev) do
          begin
            pomEpisodeNumber:= (w as TXQValueJSONArray).seq.get(0).toString;
            if pomEpisodeNumber = 'null' then continue;
            episodeInfo:=TEpisodeInfo.create;
            episodeInfoComplete.references.add(episodeInfo);
            pomEpisodeName:= (w as TXQValueJSONArray).seq.get(1).toString;
            pomEpisodeOverview:= (w as TXQValueJSONArray).seq.get(2).toString;
            episodeInfo.insert('jmeno',pomEpisodeName);
            episodeInfo.insert('obsah',pomEpisodeOverview);
            episodeInSeason.insert(pomEpisodeNumber,episodeInfo);
          end;
       episodeInfoComplete.episodeInfoAll.insert(inttostr(pomSeasonReal),
                                                 episodeInSeason);
     end;
  Result:=episodeInfoComplete;
end;

function SerialThetvdbEpisode(id: string): TEpisodeInfoComplete;
var
  pomArrayHeaders: array[0..3] of String;
  token, ztazeno, parsujSezony, parsujEpizody : String;
  pomEpisodeNumber,pomEpisodeName,pomEpisodeOverview, pomSeason: String;
  episodeInfo:TEpisodeInfo;             // dictionary 3rd level
  episodeInSeason:TEpisodeInSeason;     // dictionary 2nd level
  episodeInfoComplete:TEpisodeInfoComplete; //whole dictionary + references in one class
  v,w:IXQValue;
begin
  // to receive the token for API 2.1.0
   pomArrayHeaders[0]:= 'Content-Type: application/json';
   pomArrayHeaders[1]:=  'Accept: application/json';
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[0]);
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[1]);
   // to add token to request header
   token:= process(defaultInternet.post('https://api.thetvdb.com/login',
                                        '{"apikey": "'+unConstants.theTvdbAPI+'"}'),
                                        '$json("token")').toString;
   pomArrayHeaders[2]:= 'Authorization: Bearer ' + token;
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[2]);
   // to add language to the request header
   pomArrayHeaders[3]:= 'Accept-Language: '+aktualniJazyk;
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[3]);
   ztazeno:=retrieve('https://api.thetvdb.com/series/'+id+'/episodes/summary');
   parsujSezony:='jn:members($json("data")("airedSeasons"))';
   //nahradDiakritiku(scraperVstup);  asi nebude vůbec potřeba
   episodeInfoComplete:=TEpisodeInfoComplete.create;
   for v in process(ztazeno,parsujSezony) do
      begin
        pomSeason:=v.toString;
        if pomSeason = '0' then Continue; // no specials scrapping
        defaultInternet.additionalHeaders.Add(pomArrayHeaders[3]);
        ztazeno:=retrieve('https://api.thetvdb.com/series/'+id+
                          '/episodes/query?airedSeason='+pomSeason);
        parsujEpizody:='$json("data")()![.("airedEpisodeNumber"),'+
                                        '.("episodeName"),.("overview")]';
        episodeInSeason:=TEpisodeInSeason.create;
        episodeInfoComplete.references.Add(episodeInSeason);
        for w in process(ztazeno,parsujEpizody) do
           begin
             episodeInfo:=TEpisodeInfo.create;
             episodeInfoComplete.references.add(episodeInfo);
             pomEpisodeNumber:= (w as TXQValueJSONArray).seq.get(0).toString;
             pomEpisodeName:= (w as TXQValueJSONArray).seq.get(1).toString;
             pomEpisodeOverview:= (w as TXQValueJSONArray).seq.get(2).toString;
             episodeInfo.insert('jmeno',pomEpisodeName);
             episodeInfo.insert('obsah',pomEpisodeOverview);
             episodeInSeason.insert(pomEpisodeNumber,episodeInfo);
           end;
        episodeInfoComplete.episodeInfoAll.insert(pomSeason,episodeInSeason);
      end;
   result:=episodeInfoComplete;
end;

function SerialCsfdEpisode(id: string): TEpisodeInfoComplete;
var
  episodeInfo:TEpisodeInfo;             // dictionary 3rd level
  episodeInSeason:TEpisodeInSeason;     // dictionary 2nd level
  episodeInfoComplete:TEpisodeInfoComplete;
begin
  episodeInfoComplete:=TEpisodeInfoComplete.create;
  episodeInfo:=TEpisodeInfo.create;
  episodeInfo.insert('jmeno','xxxxx');
  episodeInfoComplete.references.Add(episodeinfo);
  episodeInSeason:=TEpisodeInSeason.create;
  episodeInSeason.insert('1',episodeInfo);
  episodeInfoComplete.references.Add(episodeInSeason);
  episodeInfoComplete.episodeInfoAll.insert('1',episodeInSeason);
  Result:=episodeInfoComplete;
end;

procedure getPosterFanart(cesta: String;id:String);
const
      baseURL   = 'http://www.thetvdb.com/banners/';
      baseQuery = '$json("data")()("fileName")';
var
  pomArrayHeaders :array[0..2] of String;
  urlImages       :array[0..1] of String;
  nameImages      :array[0..1] of String = ('fanart.jpg','poster.jpg');
  imgLanguages    :array[0..1] of String = ('','en');
  token, ztazeno, pomAdresa, pomString: String;
  pomStream: TMemoryStream;
  imgObrazek:TPicture;
  i, j: Integer;
begin
   // to receive the token for API 2.1.0
   pomArrayHeaders[0]:= 'Content-Type: application/json';
   pomArrayHeaders[1]:=  'Accept: application/json';
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[0]);
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[1]);
   // to add token to request header
   token:= process(defaultInternet.post('https://api.thetvdb.com/login',
                                        '{"apikey": "'+unConstants.theTvdbAPI+'"}'),
                                        '$json("token")').toString;
   pomArrayHeaders[2]:= 'Authorization: Bearer ' + token;
   defaultInternet.additionalHeaders.Add(pomArrayHeaders[2]);
   urlImages[0]:= ('https://api.thetvdb.com/series/'+id+
                  '/images/query?keyType=fanart');
   urlImages[1]:=('https://api.thetvdb.com/series/'+id+
                  '/images/query?keyType=poster&resolution=680x1000');
   imgLanguages[0]:=aktualniJazyk;
   imgObrazek:=TPicture.Create;
   pomStream:=TMemoryStream.Create;
   for i:=0 to 1 do
      begin
         for j:=0 to 1 do
            begin
               defaultInternet.additionalHeaders.Add('Accept-Language: '+imgLanguages[j]);
               try
                 ztazeno:=retrieve(urlImages[i]);
                 break; // images for desired language found
               except
                 on E:Exception do
                    FormScraper.EventLog1.Debug(imgLanguages[j] +' ----- '+ e.ToString);
               end;
            end;
         // if images not found for any language continue with next
         if defaultInternet.lastHTTPResultCode = 404 then continue;
         pomString:= process(ztazeno,baseQuery).toXQVList.get(0).toString;
         //FormScraper.EventLog1.Debug(pomString);
         pomAdresa:=baseURL + pomString;
         //FormScraper.EventLog1.Debug(pomAdresa);
          try
            try
             defaultInternet.get(pomAdresa,pomStream);
             pomStream.Seek(0,soFromBeginning);
             imgObrazek.LoadFromStream(pomStream);
            Except
              on E: Exception do
              begin
                FormScraper.EventLog1.Debug(e.ToString);
                imgObrazek.LoadFromFile('no_poster-v2.png');
              end;
            end;
          finally
            pomStream.Clear;
          end;
         imgObrazek.SaveToFile(cesta + nameImages[i]);
         imgObrazek.Clear;
      end;
   imgObrazek.Free;
   pomStream.free;
end;

initialization

  {inicializace procedur pro scrapování}
   ScraperyFilm[Fthemoviedb]:=@(FilmThemoviedb);
   ScraperyFilm[imdb]:=@(FilmImdb);
   ScraperyFilm[csfd]:=@(FilmCsfd);
   ScraperySerial[Sthemoviedb]:=@(SerialThemoviedb);
   ScraperySerial[tvmaze]:=@(SerialTvmaze);
   ScraperySerial[thetvdb]:=@(SerialThetvdb);
   ScraperySerial[Scsfd]:=@(FilmCsfd); //@(SerialCsfd);
   scraperyEpizody[Sthemoviedb]:=@(SerialThemoviedbEpisodes);
   scraperyEpizody[tvmaze]:=@(SerialTvmazeEpisodes);
   scraperyEpizody[thetvdb]:=@(SerialThetvdbEpisode);
   scraperyEpizody[Scsfd]:=@(SerialCsfdEpisode);

  {inicializace procedur pro genre language }
  InitGenresLanguageFilm[Fthemoviedb]:=@(initGenresMovieDBFilm);
  InitGenresLanguageFilm[imdb]:=@(initGenresImdbFilm);
  InitGenresLanguageFilm[csfd]:=@(initGenresCsfdFilm);
  InitGenresLanguageSerial[Sthemoviedb]:=@(initGenresThemoviedbSerial);
  InitGenresLanguageSerial[tvmaze]:=@(initGenresTvmazeSerial);
  InitGenresLanguageSerial[thetvdb]:=@(initGenresThetvdbSerial);
  InitGenresLanguageSerial[Scsfd]:=@(initGenresCsfdSerial);

finalization
  genresMovieDB.Free;
  genresMovieDBSerial.Free;
  genresTheTVDB.Free;
  //pomSlovnik.Free;
  pomSlovnikReferences.Free;


end.

