unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  JLabeledIntegerEdit, Forms, Controls, StdCtrls, ExtCtrls,LocalizedForms;

type

  { TForm2 }

  TForm2 = class(TLocalizedForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    JLabeledIntegerEdit1: TJLabeledIntegerEdit;
    LabeledEdit1: TLabeledEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  protected
  procedure UpdateTranslation(ALang: String); override;
  end;

var
  Form2: TForm2;


implementation
  uses unit1;
{$R *.frm}

{ TForm2 }

procedure TForm2.CheckBox1Change(Sender: TObject);
begin
  if Form2.CheckBox1.Checked then Form2.JLabeledIntegerEdit1.Enabled:=true;
  if not(Form2.CheckBox1.Checked) then Form2.JLabeledIntegerEdit1.Enabled:=false;
end;

procedure TForm2.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  JLabeledIntegerEdit1.EditLabel.Caption:=rsInintialInde;
  LabeledEdit1.EditLabel.Caption:=rsFixedPartOfL;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

end.

