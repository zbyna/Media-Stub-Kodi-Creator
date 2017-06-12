unit unHledej;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons,db,LocalizedForms;

type

  { TfrmHledej }

  TfrmHledej = class(TLocalizedForm)
    LabeledEdit1: TLabeledEdit;
    SpeedButtonPredchozi: TSpeedButton;
    SpeedButtonDalsi: TSpeedButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      // musí být nastavena frmHledej.KeyPreview, jinak nechytá klávesové zkratky
    procedure SpeedButtonDalsiClick(Sender: TObject);
    procedure SpeedButtonPredchoziClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmHledej: TfrmHledej;
  BookmarkPos :TBookMark;



implementation

{$R *.frm}
 uses unit1;  // chci pracovat s objekty z unit1 a nepotřebuju je v deklaraci
              // jde o proměnnou kliknuto
{ TfrmHledej }

procedure TfrmHledej.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   Application.ReleaseComponent(frmHledej);
end;

procedure TfrmHledej.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);        // musí být nastavena frmHledej.KeyPreview
begin
  if (Shift = [ssCtrl]) then
      case key of
        ord('P') : SpeedButtonPredchozi.Click;
        ord('N') : SpeedButtonDalsi.Click;
        ord('F') : frmHledej.Close;
      end;
end;

procedure TfrmHledej.SpeedButtonDalsiClick(Sender: TObject);
var
  i: Integer;
label
     endOuterLoop;
begin
      Form1.ZQuery1.DisableControls;
      BookmarkPos := Form1.ZQuery1.Bookmark;
      Form1.DBGrid1.SelectedRows.CurrentRowSelected:=False;// zrušit výběr
      Form1.ZQuery1.Next;
      while not(Form1.ZQuery1.Eof) do
        begin
          for i:=0 to Form1.Zquery1.FieldCount-1  do
             if Pos((LabeledEdit1.Text), Form1.Zquery1.Fields[i].AsString )>0 then
                begin
                  // vybrat výsledek, aby šlo ihned editovat a přidat do výběru
                  Form1.DBGrid1.SelectedRows.CurrentRowSelected:=True;
                  //Form1.DBGrid1.SelectedRows.Refresh;
                  goto endOuterLoop; // ukončit vnější cyklus
                end;
             Form1.ZQuery1.Next;
        end;
      Form1.ZQuery1.Bookmark := BookmarkPos; // při nenalezení skočit na původní pozici
      Form1.DBGrid1.SelectedRows.CurrentRowSelected:=True;  // a přidat do výběru
      endOuterLoop:
      Form1.ZQuery1.EnableControls;
end;

procedure TfrmHledej.SpeedButtonPredchoziClick(Sender: TObject);
var
  i: Integer;
label
     endOuterLoop;
begin
      Form1.ZQuery1.DisableControls;
      BookmarkPos := Form1.ZQuery1.Bookmark;
      Form1.DBGrid1.SelectedRows.CurrentRowSelected:=False;// zrušit výběr
      Form1.ZQuery1.Prior;
      while not(Form1.ZQuery1.Bof) do
        begin
          for i:=0 to Form1.Zquery1.FieldCount-1  do
             if Pos((LabeledEdit1.Text), Form1.Zquery1.Fields[i].AsString )>0 then
                begin
                  // vybrat výsledek, aby šlo ihned editovat a  přidat do výběru
                  Form1.DBGrid1.SelectedRows.CurrentRowSelected:=True;
                  goto endOuterLoop; // ukončit vnější cyklus
                end;
             Form1.ZQuery1.Prior;
        end;
      Form1.ZQuery1.Bookmark := BookmarkPos;
      Form1.DBGrid1.SelectedRows.CurrentRowSelected:=True; // přidat do výběru
      endOuterLoop:
      Form1.ZQuery1.EnableControls;
end;

end.

