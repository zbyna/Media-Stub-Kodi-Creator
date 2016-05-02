unit Unit4;

{$mode objfpc}{$H+}

interface

uses
   JLabeledIntegerEdit,
  Forms, Controls, Buttons, ComCtrls,LocalizedForms;

type

  { TForm4 }

  TForm4 = class(TLocalizedForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    JLabeledIntegerEdit1: TJLabeledIntegerEdit;   {Počet sezón    }
    JLabeledIntegerEdit2: TJLabeledIntegerEdit;   {Počet disků na sezonu    }
    JLabeledIntegerEdit3: TJLabeledIntegerEdit;   {Počet dílů na sezonu    }
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure UpDown2Changing(Sender: TObject; var AllowChange: Boolean);
    procedure UpDown3Changing(Sender: TObject; var AllowChange: Boolean);

  private
    { private declarations }
  public
    { public declarations }
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  Form4: TForm4;



implementation

  uses unit1;

{$R *.lfm}

{ TForm4 }

 { Čudlíčky }
procedure TForm4.BitBtn1Click(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TForm4.BitBtn2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

 { Změna polí JLabeledIntegerEdits pomocí UpDown prvků }
 { Série }
procedure TForm4.UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
begin
  JLabeledIntegerEdit1.Value:=UpDown1.Position;
end;

 { Disky }
procedure TForm4.UpDown2Changing(Sender: TObject; var AllowChange: Boolean);
begin
  JLabeledIntegerEdit2.Value:=UpDown2.Position;
end;

  { Díly }
procedure TForm4.UpDown3Changing(Sender: TObject; var AllowChange: Boolean);
begin
  JLabeledIntegerEdit3.Value:=UpDown3.Position;
end;

procedure TForm4.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  JLabeledIntegerEdit1.EditLabel.Caption:=rsTotalSeasons;
  JLabeledIntegerEdit2.EditLabel.Caption:=rsNumberOfDisk;
  JLabeledIntegerEdit3.EditLabel.Caption:=rsNumberOfEpis;
end;



end.

