unit Unit9;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons,LocalizedForms;

type

  { TFormScrapujVyber }

  TFormScrapujVyber = class(TLocalizedForm)
    okButton: TBitBtn;
    cancelButton: TBitBtn;
    scrapujVyberButton: TBitBtn;
    jinyScraperButton: TBitBtn;
    tabulkaVysledku: TStringGrid;
    procedure jinyScraperButtonClick(Sender: TObject);
    procedure scrapujVyberButtonClick(Sender: TObject);
    procedure mojeAutosize;
  private
    { private declarations }
  public
    { public declarations }
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  FormScrapujVyber: TFormScrapujVyber;



implementation
uses unit7,                           // formNastaveni
     unit8,                           // formScraper
     unit1,                           // resource strings
     unGlobalScraper;                 // object globalScraper

{$R *.lfm}

{ TFormScrapujVyber }

procedure TFormScrapujVyber.scrapujVyberButtonClick(Sender: TObject);

var
  i: Integer;
  pomStr: String;
  PomStr1: String;
  scrapovatZnovuToSame:Boolean;
begin
  for I:=tabulkaVysledku.Selection.Top to tabulkaVysledku.Selection.Bottom do
    begin
      tabulkaVysledku.AutoSizeColumn(0);
      if  tabulkaVysledku.Cells[2,i]='series' then
       begin       // --- řádek je seriál
         if (i<>tabulkaVysledku.Selection.Top) and (tabulkaVysledku.Cells[0,i]=pomStr) then
           begin
             tabulkaVysledku.Cells[0,i]:=tabulkaVysledku.Cells[0,i-1];
             tabulkaVysledku.Cells[1,i]:=tabulkaVysledku.Cells[1,i-1];
             pomStr:= tabulkaVysledku.Cells[0,i];
             mojeAutosize;
             continue;
           end
                                                                               else
           begin
            {s prázdným názvem házi scrapování error 404}
            If  tabulkaVysledku.Cells[0,i]='' then continue;
            repeat
              PomStr1:= aktualniScraperSerial(tabulkaVysledku.Cells[0,i]);

              if PomStr1 <> 'nenalezeno' then
                begin
                  FormScrapujVyber.tabulkaVysledku.Cells[1,i]:=PomStr1;
                  FormScrapujVyber.tabulkaVysledku.Cells[0,i]:=FormScraper.vybranyNazev;
                end
                                         else
                scrapovatZnovuToSame:= globalScraper.notScrapedAction;
             pomStr:= tabulkaVysledku.Cells[0,i];
             mojeAutosize;
           until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');
           continue;
           end;
       end       // --- řádek je seriál
                                                        else
       begin     // --- řádek je film
          {s prázdným názvem házi scrapování error 404}
          if tabulkaVysledku.Cells[0,i]='' then continue;
          repeat
              pomStr:=aktualniScraperFilm(tabulkaVysledku.Cells[0,i]);
              if pomStr <>'nenalezeno' then
                begin
                  tabulkaVysledku.Cells[1,i]:=PomStr;
                  tabulkaVysledku.Cells[0,i]:=FormScraper.vybranyNazev;
                end
                                        else
                scrapovatZnovuToSame:= globalScraper.notScrapedAction;
             mojeAutosize;
         until not(scrapovatZnovuToSame) or (pomStr<>'nenalezeno');
         continue;
       end;    // --- řádek je film
    end;
end;

procedure TFormScrapujVyber.jinyScraperButtonClick(Sender: TObject);
begin
   if FormNastaveni.ShowModal = mrOK then
    begin

    end;
end;

procedure TFormScrapujVyber.mojeAutosize;
begin
  tabulkaVysledku.AutoSizeColumns;
  if tabulkaVysledku.ColWidths[0]<200 then tabulkaVysledku.ColWidths[0]:=200;
  if tabulkaVysledku.ColWidths[1]<50 then tabulkaVysledku.ColWidths[1]:=50;
  if tabulkaVysledku.ColWidths[2]<50 then tabulkaVysledku.ColWidths[2]:=50;
  tabulkaVysledku.Width:=310;
end;

procedure TFormScrapujVyber.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  tabulkaVysledku.Columns.Items[0].Title.Caption:=rsName;
  tabulkaVysledku.Columns.Items[1].Title.Caption:=rsYear;
  tabulkaVysledku.Columns.Items[2].Title.Caption:=rsSort;
end;

end.

