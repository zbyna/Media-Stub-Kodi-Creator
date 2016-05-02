unit unNotSraped;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, LocalizedForms, JvNavigationPane,
  TplButtonExUnit, TplButtonUnit, KButtons, LSControls, JButton, FZCommon,
  Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmNotScraped }

  TfrmNotScraped = class(TLocalizedForm)
    btnContinue: TButton;
    btnChange: TButton;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure UpdateTranslation(ALang: String); override;
  end;

var
  frmNotScraped: TfrmNotScraped;

implementation

{$R *.lfm}
uses
    Unit8,                      // formScraper
    unit1,                      // resource strings
    unGlobalScraper;            // globalScraper object

{ TfrmNotScraped }

procedure TfrmNotScraped.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  //globalScraper.timer1.Enabled:=False;
end;

procedure TfrmNotScraped.FormCreate(Sender: TObject);
begin
  frmNotScraped.Caption:=rsChybkaSeVlou;
  btnContinue.Caption:=rsPokraOvatBez;
  btnChange.Caption:=rsZmNitScraper;
  Label1.Caption:=Format(rsAktuLnScrape, [LineEnding]);
end;

procedure TfrmNotScraped.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
end;


end.

