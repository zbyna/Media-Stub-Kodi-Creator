unit unUkazHistorii;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,  vte_edittree,VirtualTrees,
   Forms, Controls, Graphics, Dialogs, Menus,LocalizedForms,
  LCLProc,typinfo;

type

  PTreeData = ^TTreeData;    { Ukazatel na data v node }
  TTreeData = record
    Column0: String;
  end;

  { TfrmUkazHistorii }

  TfrmUkazHistorii = class(TLocalizedForm)
    menuItemClear: TMenuItem;
    menuItemUndo: TMenuItem;
    popUpVetItem: TPopupMenu;
    VET: TVirtualEditTree;
    vetRedo: TVirtualEditTree;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure menuItemClearClick(Sender: TObject);
    procedure menuItemUndoClick(Sender: TObject);
    procedure popUpVetItemPopup(Sender: TObject);
    procedure VETChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vetRedoChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VETFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
                               Column: TColumnIndex);
    procedure vetRedoFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
                               Column: TColumnIndex);
    procedure VETFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vetRedoFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VETGetNodeDataSize(Sender: TBaseVirtualTree;
                                 var NodeDataSize: Integer);
    procedure vetRedoGetNodeDataSize(Sender: TBaseVirtualTree;
                                 var NodeDataSize: Integer);
    procedure VETGetPopupMenu(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; const P: TPoint; var AskParent: Boolean;
      var aPopupMenu: TPopupMenu);
    procedure VETGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vetRedoGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VETInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vetRedoInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure UpdateTranslation(ALang: String); override;
    procedure VETStructureChange(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Reason: TChangeReason);
     procedure vetRedoStructureChange(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Reason: TChangeReason);
  private
    { private declarations }
  public
    { public declarations }
    checkBuffersSize:Boolean;
  end;

var
  frmUkazHistorii: TfrmUkazHistorii;

implementation

{$R *.frm}

uses
  unit1, // kvůli rsUndoBufferIt a rsRedoBufferIt  - strings for automatic translation
  unHistory ;
{ TfrmUkazHistorii }



{ OnChange }
procedure TfrmUkazHistorii.VETChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
//var pom,pom2: string;
begin
 vet.Refresh;
end;

procedure TfrmUkazHistorii.vetRedoChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  vetRedo.Refresh;
end;

procedure TfrmUkazHistorii.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
 // Application.ReleaseComponent(frmUkazHistorii);
 globalHistory.isfrmUkazHistoriiShown:=False;
 checkBuffersSize:=True;
end;

procedure TfrmUkazHistorii.FormActivate(Sender: TObject);
begin
  //globalHistory.undoPolozky.printHistoryVector;  // při větším počtu položek uzké hrdlo
end;

procedure TfrmUkazHistorii.FormCreate(Sender: TObject);
var
  XNodeRoot,XNodeRoot1: PVirtualNode;
//  Data: PTreeData;
begin
  vet.Header.Columns.Items[0].Text:=rsUndoBufferIt;
  vetRedo.Header.Columns.Items[0].Text:=rsRedoBufferIt;
  XNodeRoot:=VET.AddChild(nil);
  XNodeRoot1:=vetRedo.AddChild(nil);
end;

procedure TfrmUkazHistorii.FormShow(Sender: TObject);
var
  StartMS: Comp;
  XNodeRoot: PVirtualNode;
  Data: PTreeData;
begin
  StartMS:=timestamptomsecs(datetimetotimestamp(now));
  vet.ReinitNode(vet.RootNode,true);
  DebuglnThreadLog(format('%s',
         ['ReinitStromu VET - ukazHistorii.FormShow:']));
  vetRedo.ReinitNode(vetRedo.RootNode,true);
  DebuglnThreadLog(format('%s',
         ['ReinitStromu vetRedo - ukazHistorii.FormShow:']));
  globalHistory.isfrmUkazHistoriiShown:=True;
  checkBuffersSize:=False;
  globalHistory.undoPolozky.printHistoryVector;
  globalHistory.redoPolozky.printHistoryVector;
  checkBuffersSize:=True;
  //DebuglnThreadLog('Výpis historie trval: '+floattostr(timestamptomsecs(datetimetotimestamp(now))-StartMS)+' ms');
end;

procedure TfrmUkazHistorii.menuItemClearClick(Sender: TObject);
begin
 // tady to by mělo být součástí Controlleru (MVC) a ne View :-)
  globalHistory.clearAndPrintUndoAndRedo;
end;

procedure TfrmUkazHistorii.menuItemUndoClick(Sender: TObject);
var
  vybrane: TNodeArray;
  indexVybraneNode: Cardinal;
  level: Cardinal;

begin
  vybrane:=vet.GetSortedSelection(True);
  if not assigned(vybrane) then
    begin
      vet.Selected[vet.RootNode]:=True; // pravděpodobně je prohozeno RootNode s RootNode^.lastchild
      setlength(vybrane,1);             // protože s RootNode^.lastchild to maže celou 0 a
      vybrane[0]:=vet.RootNode;         // s RootNode jenom poslední položku z úrovně 1
    end;
  level:=vet.GetNodeLevel(vybrane[0]);
  case level of                         //    přímo k TvirtualEditTree
   0: begin
       vybrane[0]:=vet.RootNode;         // s RootNode jenom poslední položku
       indexVybraneNode:=vybrane[0]^.Index; // z úrovně 1 viz. poznámka výše
      end;
   1: indexVybraneNode:=vybrane[0]^.Index;
   2: indexVybraneNode:=vybrane[0]^.Parent^.Index;
   3: indexVybraneNode:=vybrane[0]^.Parent^.Parent^.Index;
  end;
  // tady to by mělo být součástí Controlleru (MVC) a ne View :-)
  // kopíruj vybranou položku historie na konec undoPolozky:
  globalHistory.undoPolozky.historyVector.PushBack(
            globalHistory.undoPolozky.historyVector[indexVybraneNode]);
  // vymaž vybranou položku z undoPoložky
  globalHistory.undoPolozky.historyVector.Erase(indexVybraneNode);
  vet.DeleteNode(vybrane[0]);
  // zavolej normální undo
  globalHistory.doUndo;
end;

procedure TfrmUkazHistorii.popUpVetItemPopup(Sender: TObject);
// GetPopupMenu z TVirtualEditTree nejde použít protože:
// 1. blokuje používání CTR+Z tzn. klávesových zkratky pro dynamicky
//   přidělovaná popMenu nefungují
// 2. je voláno pouze v případě, že není přiřazeno popupMenu
  var
  level: Cardinal;
  Data: PTreeData;
  Node: PVirtualNode;
begin
  if globalHistory.undoPolozky.historyVector.Size = 0 then
      begin
         MenuItemUndo.Enabled:=False;
         exit;
      end
                                                      else
      MenuItemUndo.Enabled:=True;
  Node:=vet.FocusedNode;
  level:=VET.GetNodeLevel(Node);

  if node = nil then exit;
  case level of                      //    přímo k TvirtualEditTree
   0: exit {aPopupMenu:=popUpVetRootNode};
   1: Data:=VET.GetNodeData(Node);
   2: Data:=VET.GetNodeData(node^.Parent);
   3: Data:=VET.GetNodeData(node^.Parent^.Parent);
  end;
  popUpVetItem.Items.Items[0].Caption:=rsUndoHistoryI+Data^.Column0;
end;


{ OnFokusChanged }
procedure TfrmUkazHistorii.VETFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);

begin
 //vet.FocusedNode^.States:=vet.FocusedNode^.States - [vsSelected];
 VeT.Refresh;
 //showmessage('Invalidate');
 //frmUkazHistorii.VET.Invalidate;
end;

procedure TfrmUkazHistorii.vetRedoFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin

  vetRedo.FocusedNode^.States:=vetRedo.FocusedNode^.States - [vsSelected];
  vetRedo.FocusedNode:=vetRedo.RootNode;
  vetRedo.Refresh;
end;

{ OnFreeNode }
procedure TfrmUkazHistorii.VETFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PTreeData;
  globHistPom:THistoryVector;
begin

  Data:=VET.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^.Column0 := '';
  end;
end;

procedure TfrmUkazHistorii.vetRedoFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTreeData;
begin
  Data:=VET.GetNodeData(Node);
  if Assigned(Data) then
    Data^.Column0 := '';
end;

 { OnGetNodeDataSize }
procedure TfrmUkazHistorii.VETGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
   NodeDataSize := SizeOf(TTreeData);
end;

procedure TfrmUkazHistorii.vetRedoGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TfrmUkazHistorii.VETGetPopupMenu(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
  var AskParent: Boolean; var aPopupMenu: TPopupMenu);
begin

end;

  { OnGetText - klíčová pro zobrazení sloupce }
procedure TfrmUkazHistorii.VETGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var
  globHistPom:THistoryVector;
  Data:PTreeData;
begin
  Data := VET.GetNodeData(Node);
  //case Column of
  //  0: CellText := Data^.Column0;
  //end

  if (Column <= 0)  then
  begin
    try
      globHistPom:=globalHistory.undoPolozky.historyVector; // pomocná
      case  Sender.GetNodeLevel(Node) of
       0:begin
           Data^.Column0:=globalHistory.undoPolozky.name;
           CellText:=Data^.Column0;
         end;
       1:begin
           Data^.Column0:=globHistPom[node^.Index].jmenoPolozky;
           CellText:=Data^.Column0;
         end;
       2:begin
          Data^.Column0 := GetEnumName(Typeinfo(TsqlTypProUndo),
              ord(globHistPom[Node^.Parent^.Index].polePolozek[node^.Index].operaceUndo));
          CellText:=Data^.Column0;
         end;
       3: begin
            Data^.Column0:=globHistPom[Node^.Parent^.Parent^.Index].polePolozek[Node^.Parent^.Index].hodnoty[node^.index];
            CellText:=Data^.Column0;
          end;
      end;
    except
        On E: Exception do
        DebuglnThreadLog(format('%s %s %3d %3d',
         ['Error GetText',E.ToString,Node^.Parent^.Index,node^.Index]));
    end;
  end;
end;

procedure TfrmUkazHistorii.vetRedoGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  globHistPom:THistoryVector;
  Data:PTreeData;
begin
  Data := VET.GetNodeData(Node);
  if (Column <= 0)  then
  begin
    try
      globHistPom:=globalHistory.redoPolozky.historyVector; // pomocná
      case  Sender.GetNodeLevel(Node) of
       0:begin
           Data^.Column0:=globalHistory.redoPolozky.name;
           CellText:=Data^.Column0;
         end;
       1:begin
           Data^.Column0:=globHistPom[node^.Index].jmenoPolozky;
           CellText:=Data^.Column0;
         end;
       2:begin
          Data^.Column0 := GetEnumName(Typeinfo(TsqlTypProUndo),
              ord(globHistPom[Node^.Parent^.Index].polePolozek[node^.Index].operaceRedo));
          CellText:=Data^.Column0;
         end;
       3: begin
            Data^.Column0:=globHistPom[Node^.Parent^.Parent^.Index].polePolozek[Node^.Parent^.Index].hodnoty[node^.index];
            CellText:=Data^.Column0;
          end;
      end;
    except
        On E: Exception do
        DebuglnThreadLog(format('%s %s %3d %3d',
         ['Error GetText',E.ToString,Node^.Parent^.Index,node^.Index]));
    end;
  end;
end;

procedure TfrmUkazHistorii.VETInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
 case Sender.GetNodeLevel(Node) of
   0: begin
       Sender.ChildCount[Node]:=globalHistory.undoPolozky.historyVector.Size;
       Sender.Expanded[Node] := TRUE;
      end;
   1: Sender.ChildCount[Node]:=
            globalHistory.undoPolozky.historyVector[Node^.Index].polePolozek.Size;
   2: Sender.ChildCount[Node] := 11;
 end;

end;

procedure TfrmUkazHistorii.vetRedoInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
 case Sender.GetNodeLevel(Node) of
   0: begin
       Sender.ChildCount[Node]:=globalHistory.redoPolozky.historyVector.Size;
       Sender.Expanded[Node] := TRUE;
      end;
   1: Sender.ChildCount[Node]:=
            globalHistory.redoPolozky.historyVector[Node^.Index].polePolozek.Size;
   2: Sender.ChildCount[Node] := 11;
 end;

end;

procedure TfrmUkazHistorii.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  globalHistory.undoPolozky.printHistoryVector;
  globalHistory.redoPolozky.printHistoryVector;
end;

procedure TfrmUkazHistorii.VETStructureChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Reason: TChangeReason);   // upraví text v hlavničce stromu
begin
 VET.Header.Columns.Items[0].Text:=rsUndoBufferIt +': ' +
                  inttostr(globalHistory.undoPolozky.historyVector.Size);

end;

procedure TfrmUkazHistorii.vetRedoStructureChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Reason: TChangeReason);
begin
 vetRedo.Header.Columns.items[0].Text:=rsRedoBufferIt+': '+
                  inttostr(globalHistory.redoPolozky.historyVector.Size);
end;

end.

