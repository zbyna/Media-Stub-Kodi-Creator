unit unGlobalScraper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset,DBGrids,Controls,Grids,ExtCtrls,Forms,
  strutils,contnrs, ghashmap,dialogs, OWideSupp;

type
  { TGlobalScraper }

  TGlobalScraper = class
    zQuery:TZquery;
    dbGrid:TDBGrid;
    timer1:TTimer;   // pro zavření hlášky s nenalezením a možností vybrat scraper pro
                     // rescrape nebo pokračovat na další položku
    dobaTimer1:Integer;
    procedure scrapujVyber;
    procedure createNfo(directory:String);
    procedure onTimer(sender:TObject);
    function notScrapedAction:Boolean;
    constructor create(zq:TZquery;dbg:TDBGrid);
    destructor destroy;override;
  end;

var
   globalScraper:TGlobalScraper;

implementation
 uses unit1,              // resource strings
      unit7,              // formNastaveni
      unit8,              // formScraper
      unNotSraped,        // form for rescrape
      unit9,              // formScrapujVyber
      OXmlCDOM,OXmlUtils; // creating xml
{ TGlobalScraper }

procedure TGlobalScraper.scrapujVyber;
var
  i: Integer;
  pomStr,PomStr1: String;
  Pom: Integer;
  scrapovatZnovuToSame : Boolean;
begin
  PomStr:='';
  PomStr1:='';
  {projdi výběr scrapuj položku naplň tabulkaVysledku v FormScrapujVyber unit9}
      //nultý řádek v tabulkaVysledku jsou názvy sloupců proto +1
  FormScrapujVyber.tabulkaVysledku.RowCount:=dbgrid.SelectedRows.Count+1;
  for i:=0 to dbgrid.SelectedRows.Count-1 do
   begin

     ZQuery.GotoBookmark(dbgrid.SelectedRows.Items[i]);
     if  ZQuery.FieldByName('DRUH').AsString='series' then
       begin       // --- řádek je seriál
         FormScrapujVyber.tabulkaVysledku.Cells[2,i+1]:='series';
         // pro případ, že scraper nenajde jméno ----- begin -----
         FormScrapujVyber.tabulkaVysledku.Cells[0,i+1]:=
                  ZQuery.FieldByName('NAZEV_SERIALU').AsString;
         //FormScraper.vybranyNazev:=ZQuery.FieldByName('NAZEV_SERIALU').AsString;
         // pro případ, že scraper nenajde jméno  ----- end -------
         if (i<>0) and (ZQuery.FieldByName('NAZEV_SERIALU').AsString=pomStr) then
           begin
             pomStr:= ZQuery.FieldByName('NAZEV_SERIALU').AsString;
             FormScrapujVyber.tabulkaVysledku.Cells[0,i+1]:=
              FormScrapujVyber.tabulkaVysledku.Cells[0,i];
             FormScrapujVyber.tabulkaVysledku.Cells[1,i+1]:=
              FormScrapujVyber.tabulkaVysledku.Cells[1,i]; //ZQuery.FieldByName('ROK').AsString;
             continue;
           end
                                                                               else
           begin
            pomStr:= ZQuery.FieldByName('NAZEV_SERIALU').AsString;
            {s prázdným názvem házi scrapování error 404}
            If ZQuery.FieldByName('NAZEV_SERIALU').AsString ='' then continue;
            repeat
              PomStr1:= aktualniScraperSerial(ZQuery.FieldByName('NAZEV_SERIALU').AsString);
              if PomStr1 <> 'nenalezeno' then
                begin
                  FormScrapujVyber.tabulkaVysledku.Cells[1,i+1]:=PomStr1;
                  FormScrapujVyber.tabulkaVysledku.Cells[0,i+1]:=FormScraper.vybranyNazev;
                end
                                       else
                scrapovatZnovuToSame:= self.notScrapedAction;
               // tady někde bych se měl po změně scraperu vrátit a znovu scrapovat tu samou položku
            until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');
           continue;
           end;
       end       // --- řádek je seriál
                                                        else
       begin     // --- řádek je film
          FormScrapujVyber.tabulkaVysledku.Cells[2,i+1]:='film';
          // pro případ, že scraper nenajde jméno ----- begin -----
          FormScrapujVyber.tabulkaVysledku.Cells[0,i+1]:=
                ZQuery.FieldByName('NAZEV').AsString;
          //FormScraper.vybranyNazev:=ZQuery.FieldByName('NAZEV').AsString;;
          // pro případ, že scraper nenajde jméno ----- end -----
          {s prázdným názvem házi scrapování error 404}
          if ZQuery.FieldByName('NAZEV').AsString ='' then continue;
         repeat
            pomStr:=aktualniScraperFilm(ZQuery.FieldByName('NAZEV').AsString);
           if pomStr <>'nenalezeno' then
             begin
                FormScrapujVyber.tabulkaVysledku.Cells[1,i+1]:=PomStr;
                FormScrapujVyber.tabulkaVysledku.Cells[0,i+1]:=FormScraper.vybranyNazev;
             end
                                      else
             scrapovatZnovuToSame:= self.notScrapedAction;
         until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');
         continue;
       end;    // --- řádek je film
   end;
  FormScrapujVyber.mojeAutosize;
  Pom:=FormScrapujVyber.ShowModal;
  {tabulkaVysledku do položek výběru v DBgrid}
  if pom=mrOK then
     for i:=0 to dbgrid.SelectedRows.Count-1 do
         begin
           ZQuery.GotoBookmark(dbgrid.SelectedRows.Items[i]);
           ZQuery.Edit;
           ZQuery.FieldByName('ROK').AsString:= FormScrapujVyber.tabulkaVysledku.Cells[1,i+1];
           if FormScrapujVyber.tabulkaVysledku.Cells[2,i+1]='series' then
                ZQuery.FieldByName('NAZEV_SERIALU').AsString:=
                FormScrapujVyber.tabulkaVysledku.Cells[0,i+1]
                                                                    else
                ZQuery.FieldByName('NAZEV').AsString:=
                FormScrapujVyber.tabulkaVysledku.Cells[0,i+1];

           ZQuery.Post;
         end;
  if pom=mrCancel then  FormScrapujVyber.tabulkaVysledku.Clean([gzNormal,gzFixedRows])
end;

procedure TGlobalScraper.createNfo(directory:String);
var
  i: Integer;
  pomStr,PomStr1,pomPath, pomString: String;
  Pom: Integer;
  scrapovatZnovuToSame : Boolean;
  pomEpisodesInfo:TEpisodeInfoComplete;

  procedure createNfoFile(itemType,path:String); // itemType = tvshow or movie
  var
    xmlNode: TXMLNode;
    xmlDoc : IXMLDocument;
    pomGenre: TCaption;
    j: Integer;

  begin
    xmlDoc:=CreateXMLDoc(itemType,true);
    xmlNode:=xmlDoc.DocumentElement;
    // documentNode contains documentElement(so called root element) :-)
    // below inserts comment before documentElement(root element)
    xmlDoc.GetDocumentNode.InsertComment('created on '+ DateTimeToStr(now) +
                                         ' - MediaStub Kodi Creator',xmlNOde);
    xmlNode.AddChild('title').AddText(FormScraper.vybranyNazev);
    xmlNode.AddChild('year').AddText(FormScraper.vybranyRok);
    xmlNode.AddChild('plot').AddText(FormScraper.memDej.Lines.Text);
    xmlNode.AddChild('rating').AddText(FormScraper.edtHodnoceni.Text);
    pomGenre:= FormScraper.edtZanry.Text;
    for j:=1 to WordCount(pomGenre,[',']) do
          xmlNode.AddChild('genre').AddText(ExtractWord(j,pomGenre,[',']));
    pomPath:=directory+path;
    If ForceDirectories(pomPath) then    //utf8tosys
      begin
       xmlDoc.WriterSettings.IndentType:=itIndent;
       xmlDoc.SaveToFile(pomPath+itemType+'.nfo');
       if aktualniScraperSerial = @(SerialThetvdb) then
          begin
            FormScraper.imgObrazek.Picture.SaveToFile(pomPath + 'banner.jpg');
            getPosterFanart(pomPath,FormScraper.idSerie);
          end
       else
          FormScraper.imgObrazek.Picture.SaveToFile(pomPath+'poster.jpg');
      end;
  end;

  procedure createNfoFileEpizode(path:String;episodesInfo:TEpisodeInfoComplete);
  var
    xmlNode, xmlNode1: TXMLNode;
    xmlDoc : IXMLDocument;
    k: Integer;
    episodes, sezona, pomSezona, pomEpisode: String;
    episodesCount: SizeInt;
    pomTitle, pomPlot:string;

  begin
    episodes:=ZQuery.FieldByName('DILY_NA_DISKU').AsString;
    sezona:= ZQuery.FieldByName('SEZONA').AsString;
    pomSezona:=ExtractWord(1,sezona,['s']);
    RemoveLeadingChars(pomSezona, ['0']);
    episodesCount:=  WordCount(episodes,['e']);
    if episodesCount = 1 then
       xmlDoc:=CreateXMLDoc('root',true)
                         else
       xmlDoc:=CreateXMLDoc('multiepisodeinfo',true);
    xmlNode:=xmlDoc.DocumentElement;
    // documentNode contains documentElement(so called root element) :-)
    // below inserts comment before documentElement(root element)
    xmlDoc.GetDocumentNode.InsertComment('created on '+ DateTimeToStr(now) +
                                         ' - MediaStub Kodi Creator',xmlNOde);
    for k:=1 to episodesCount  do
        begin
          pomEpisode:= ExtractWord(k,episodes,['e']);
          Removeleadingchars(pomEpisode,['0']);
          xmlNode1:=xmlNode.AddChild('episodedetails');
          //ShowMessage(episodesInfo.episodeInfoAll['1']['1']['jmeno']);
          if episodesInfo.episodeInfoAll['1']['1']['jmeno'] = 'xxxxx' then
            begin
              pomTitle:= '';  // info neni
              pomPlot:='';    // plot není
            end
          else
            begin
              pomTitle:= episodesInfo.episodeInfoAll[pomSezona][pomEpisode]['jmeno'];
              pomPlot:= episodesInfo.episodeInfoAll[pomSezona][pomEpisode]['obsah'];
            end;
          xmlNode1.AddChild('title').AddText(pomTitle);
          xmlNode1.AddChild('season').AddText(pomSezona);
          xmlNode1.AddChild('episode').AddText(pomEpisode);
          xmlNode1.AddChild('plot').AddText(pomPlot);
        end;
    pomPath:=directory+path;
    If ForceDirectories(pomPath) then    //utf8tosys
      begin
       xmlDoc.WriterSettings.IndentType:=itIndent;
       xmlDoc.SaveToFile(pomPath+sezona+episodes+'.nfo');
      end;
  end;

begin
  PomStr:='';
  PomStr1:='';
  // možná zbytečné, ještě někdy prověřit :-)
  // vytváří se totiž ve funkci unit8.SerialThemoviedbEpisodes()
  pomEpisodesInfo:=TEpisodeInfoComplete.create;
  {projdi výběr a vytvoř nfo soubor v cestě path}
      //nultý řádek v tabulkaVysledku jsou názvy sloupců proto +1
  for i:=0 to dbgrid.SelectedRows.Count-1 do
   begin
     ZQuery.GotoBookmark(dbgrid.SelectedRows.Items[i]);
     if  ZQuery.FieldByName('DRUH').AsString='series' then
       begin       // --- řádek je seriál
         if (i<>0) and (ZQuery.FieldByName('NAZEV_SERIALU').AsString=pomStr) then
           begin
             pomStr:= ZQuery.FieldByName('NAZEV_SERIALU').AsString;
             pomPath:=ZQuery.FieldByName('DIRECTORY').AsString;
             createNfoFileEpizode(pomPath,pomEpisodesInfo);
             continue;
           end
                                                                               else
           begin
            pomStr:= ZQuery.FieldByName('NAZEV_SERIALU').AsString;
            {s prázdným názvem házi scrapování error 404}
            If ZQuery.FieldByName('NAZEV_SERIALU').AsString ='' then continue;
            repeat
              PomStr1:= aktualniScraperSerial(ZQuery.FieldByName('NAZEV_SERIALU').AsString);
              if PomStr1 <> 'nenalezeno' then
                begin
                  pomPath:=ZQuery.FieldByName('DIRECTORY').AsString;
                  pomString:= ZQuery.FieldByName('SEZONA').AsString+'\';
                  pomPath:=StringReplace(pomPath,pomString,'',[rfIgnoreCase]);
                  createNfoFile('tvshow',pomPath);
                  // there may be several TV series in selection
                  FreeAndNil(pomEpisodesInfo);
                  pomEpisodesInfo:=aktualniScraperEpisody(FormScraper.idSerie);
                  createNfoFileEpizode(ZQuery.FieldByName('DIRECTORY').AsString,
                                       pomEpisodesInfo);
                end
                                       else
                scrapovatZnovuToSame:= self.notScrapedAction;
               // tady někde bych se měl po změně scraperu vrátit a znovu scrapovat tu samou položku
            until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');
           continue;
           end;
       end       // --- řádek je seriál
                                                        else
       begin     // --- řádek je film
          {s prázdným názvem házi scrapování error 404}
          if ZQuery.FieldByName('NAZEV').AsString ='' then continue;
         repeat
            pomStr:=aktualniScraperFilm(ZQuery.FieldByName('NAZEV').AsString);
           if pomStr <>'nenalezeno' then
             begin
                pomPath:=ZQuery.FieldByName('DIRECTORY').AsString;
                createNfoFile('movie',pomPath);
             end
                                      else
             scrapovatZnovuToSame:= self.notScrapedAction;
         until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');
         continue;
       end;    // --- řádek je film
   end;
  freeandnil(pomEpisodesInfo);
end;

constructor TGlobalScraper.create(zq: TZquery;dbg:TDBGrid);
begin
  self.zQuery:=zq;
  self.dbGrid:=dbg;
  self.dobaTimer1:=3;
  self.timer1:=TTimer.create(nil);
  self.timer1.enabled:=False;
  self.timer1.Interval:=1000;
  self.timer1.OnTimer:=@self.onTimer; // více na: http://forum.lazarus.freepascal.org/index.php?topic=7046.0
end;

destructor TGlobalScraper.destroy;
begin
  self.timer1.Destroy;
  inherited;
end;

procedure TGlobalScraper.onTimer(sender: TObject);
begin
  dobaTimer1:=dobaTimer1-1;
  if dobaTimer1 = 0 then
      begin
        Screen.GetCurrentModalForm.Close;
        timer1.Enabled:=False;   // možná zbytečné :-)
      end;
  frmNotScraped.btnContinue.Caption:=rsPokraOvatBez +
                                     ' ('+inttostr(dobaTimer1)+')';
end;

function TGlobalScraper.notScrapedAction:Boolean;

begin
    dobaTimer1:=3;
    timer1.Interval:=1000;
    timer1.Enabled:=True;
    frmNotScraped.btnChange.Caption:=rsZmNitScraper;
    frmNotScraped.btnContinue.Caption:= rsPokraOvatBez +
                             ' ('+inttostr(dobaTimer1)+')';
    case frmNotScraped.ShowModal of
      mrRetry: begin
                 timer1.Enabled:=False;
                 FormNastaveni.ShowModal ;
                 FormScrapujVyber.mojeAutosize;
                 notScrapedAction:=True;
               end;
      mrOK: notScrapedAction:=False;
      //mrClose:notScrapedAction:=False;
      mrCancel:notScrapedAction:=False;
    end;
    timer1.Enabled:=False;
end;

initialization
  begin
    globalScraper:=TGlobalScraper.create(nil,nil); // v čase inicializace není DBGrid1 vytvořena
    // !!!!! need to asign  real dbgrid and zquery used in form1 in TForm1.create
    // !!!!!  globalScraper.dbGrid:=DBGrid1;
    // !!!!!  globalScraper.zQuery:=ZQuery1;
  end;

finalization
  globalScraper.destroy;
end.

