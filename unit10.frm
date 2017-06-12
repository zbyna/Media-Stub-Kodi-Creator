inherited FormUpravUmisteni: TFormUpravUmisteni
  Left = 705
  Height = 403
  Top = 263
  Width = 522
  Caption = 'Number format adjustment in column: '
  ClientHeight = 403
  ClientWidth = 522
  OnHide = FormHide
  OnShow = FormShow
  Position = poDesktopCenter
  object stringGridProVyberPozice: TStringGrid[0]
    Left = 16
    Height = 64
    Top = 16
    Width = 488
    AutoFillColumns = True
    ColCount = 1
    Columns = <    
      item
        MinSize = 20
        MaxSize = 20
        Title.Alignment = taCenter
        Title.Caption = '0'
        Width = 484
      end>
    FixedCols = 0
    RowCount = 2
    ScrollBars = ssAutoHorizontal
    TabOrder = 0
    OnSelectCell = stringGridProVyberPoziceSelectCell
    ColWidths = (
      484
    )
  end
  object StringGridProUmisteni: TStringGrid[1]
    Left = 16
    Height = 263
    Top = 136
    Width = 270
    AutoFillColumns = True
    ColCount = 1
    Columns = <    
      item
        Title.Caption = ''
        Width = 266
      end>
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goSmoothScroll]
    ScrollBars = ssAutoVertical
    TabOrder = 1
    ColWidths = (
      266
    )
  end
  object okButton: TButton[2]
    Left = 398
    Height = 38
    Top = 136
    Width = 106
    Caption = 'Ok'
    ModalResult = 1
    OnClick = okButtonClick
    TabOrder = 2
  end
  object cancelButton: TButton[3]
    Left = 398
    Height = 37
    Top = 190
    Width = 106
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object chboxVsechnaCisla: TCheckBox[4]
    Left = 16
    Height = 25
    Top = 96
    Width = 26
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
end
