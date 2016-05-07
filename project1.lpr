program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Forms, Interfaces, Unit1, Unit2, Unit3, Unit4, {pl_zmsql,}
  {pl_kcontrols, pl_win_midi,}  pl_exsystem, pl_synapsevs, pl_zeosdbo,
  pl_bgracontrols, pl_bgrauecontrols, pl_kcontrols, Unit5, Unit6, Unit7, Unit8,
  Unit9, Unit10, unHledej, utf8tools, unHistory, unUkazHistorii, unGridMod,
  unNotSraped, unGlobalScraper, unConstants;

{$R *.res}

begin
  Application.Title:='Media Stub Kodi Creator';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TFormNastaveni, FormNastaveni);
  Application.CreateForm(TFormScraper, FormScraper);
  Application.CreateForm(TFormScrapujVyber, FormScrapujVyber);
  Application.CreateForm(TFormUpravUmisteni, FormUpravUmisteni);
  Application.CreateForm(TfrmUkazHistorii, frmUkazHistorii);
  Application.CreateForm(TfrmNotScraped, frmNotScraped);
  Application.Run;
end.
