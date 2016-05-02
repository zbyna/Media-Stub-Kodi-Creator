unit unGlobalScraper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset,DBGrids,Controls,Grids,ExtCtrls,Forms;

type
  { TGlobalScraper }

  TGlobalScraper = class
    zQuery:TZquery;
    dbGrid:TDBGrid;
    timer1:TTimer;   // pro zavření hlášky s nenalezením a možností vybrat scraper pro
                     // rescrape nebo pokračovat na další položku
    dobaTimer1:Integer;
    procedure scrapujVyber;
    procedure onTimer(sender:TObject);
    function notScrapedAction:Boolean;
    constructor create(zq:TZquery;dbg:TDBGrid);
  end;

var
   globalScraper:TGlobalScraper;

implementation
 uses unit1, // resource strings
      unit7, // formNastaveni
      unit8, // formScraper
      unNotSraped, // form for rescrape
      unit9; // formScrapujVyber
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
end.

