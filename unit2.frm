inherited Form2: TForm2
  Left = 533
  Height = 187
  Top = 212
  Width = 445
  Caption = 'Bulk change of Location column'
  ClientHeight = 187
  ClientWidth = 445
  Position = poDesktopCenter
  object Button1: TButton[0]
    Left = 341
    Height = 52
    Top = 40
    Width = 65
    Caption = 'OK'
    OnClick = Button1Click
    TabOrder = 3
  end
  object LabeledEdit1: TLabeledEdit[1]
    Left = 16
    Height = 29
    Top = 40
    Width = 245
    EditLabel.AnchorSideLeft.Control = LabeledEdit1
    EditLabel.AnchorSideRight.Control = LabeledEdit1
    EditLabel.AnchorSideRight.Side = asrBottom
    EditLabel.AnchorSideBottom.Control = LabeledEdit1
    EditLabel.Left = 16
    EditLabel.Height = 1
    EditLabel.Top = 36
    EditLabel.Width = 245
    EditLabel.ParentColor = False
    TabOrder = 0
  end
  object CheckBox1: TCheckBox[2]
    Left = 16
    Height = 25
    Top = 72
    Width = 126
    Caption = 'Location index'
    OnChange = CheckBox1Change
    TabOrder = 1
  end
  object JLabeledIntegerEdit1: TJLabeledIntegerEdit[3]
    Left = 16
    Height = 29
    Top = 120
    Width = 184
    DisplayFormat = '0'
    Value = 0
    EditLabel.AnchorSideLeft.Control = JLabeledIntegerEdit1
    EditLabel.AnchorSideRight.Control = JLabeledIntegerEdit1
    EditLabel.AnchorSideRight.Side = asrBottom
    EditLabel.AnchorSideBottom.Control = JLabeledIntegerEdit1
    EditLabel.Left = 16
    EditLabel.Height = 1
    EditLabel.Top = 116
    EditLabel.Width = 184
    EditLabel.ParentColor = False
    Enabled = False
    TabOrder = 2
  end
  object Button2: TButton[4]
    Left = 341
    Height = 52
    Top = 104
    Width = 65
    Caption = 'Cancel'
    OnClick = Button2Click
    TabOrder = 4
  end
end
