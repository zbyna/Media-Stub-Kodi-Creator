unit unHistory;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils,Controls, db, gvector,typinfo,variants,
  unUkazHistorii,vte_edittree,VirtualTrees,Dialogs,Forms,
  MTProcs,LCLProc;

type

   { TUndoNeboRedo }
   TUndoNeboRedo = (undo,redo);

  { TsqlTypProUndo }
  TsqlTypProUndo = (delete,insert);
  THodnoty = array[0..10] of String;

   { TPolozka }
   TPolozka = class
     operaceUndo:TsqlTypProUndo;
     operaceRedo:TsqlTypProUndo;
     hodnoty: Thodnoty;
     constructor create(op:TsqlTypProUndo; pomHodnoty:THodnoty);
   end;

  { TPolePolozek }
  TPolePolozek = specialize TVector<Tpolozka>;

  { THistoryItem }
  THistoryItem = class
     jmenoPolozky:String;
     polePolozek:TPolePolozek;
     constructor create(pomString:string;pomHodnoty:THodnoty;sqlTyp:TsqlTypProUndo);
     procedure operaceDoPolePolozek(pomHodnoty:Thodnoty;sqlTyp:TsqlTypProUndo);
     procedure operaceZPolePolozek( pomDs:TDataset;pomUnRe:TUndoNeboRedo;pomPol:Integer);
  end;

  { THistoryVector }
  THistoryVector = specialize Tvector<THistoryItem>;

  { THistory }
  THistory = class
     name:String;
     historyVector:THistoryVector;
     procedure printHistoryVector;
     constructor create(pomString:String);
     destructor destroy; override;
  end;

  // mohl by ještě obsahovat třídu TGlobalHistory, která by zapouzdřovala veškeré
  // proměnné a procedury použité v unit1 tzn:

  { TGlobalHistory }

  TGlobalHistory = class
     undoPolozky:THistory;           // undoBuffer
     redoPolozky:THistory;           // redoBuffer
     multiPolozkaHistorie:Boolean;   // více prvků v historyItem.polePolozek
     probihaUndo:Boolean;            // vybráno menu Historie/Undo
     probihaRedo:Boolean;            // vybráno menu Historie/Redo
     dataSet:TDataset;               // daset for history
     isfrmUkazHistoriiShown:Boolean; // because of speed improving
     procedure doUndo;
     procedure doRedo;
     procedure showHistoryBuffers;
     procedure beforeDelete;
     procedure beforeEdit;
     procedure beforePost;
     procedure clearAndPrintUndoAndRedo;   // zatím prázdná
     constructor create(ds:TDataset);
     destructor destroy; override;
  end;

 var
      globalHistory:TGlobalHistory;


implementation
 uses
    unit1,      // because of Form1.frmeventLog.Debug , jinak nezávislé na form1 :-)
    syncobjs;



{ TPolozka }
constructor TPolozka.create(op:TsqlTypProUndo; pomHodnoty:THodnoty);

begin
  self.operaceUndo:=op;
  case op of
   insert:self.operaceRedo:= delete ;
   delete:self.operaceRedo:= insert ;
  end;
  self.hodnoty:=pomHodnoty;
end;

{ THistory }
constructor THistory.create(pomString:String);
begin
  self.name:=pomString;
  self.historyVector:=THistoryVector.Create;
end;

destructor THistory.destroy;
begin
  self.historyVector.Free;
end;

procedure THistory.printHistoryVector; // upravit podle potřeby

begin
  if not globalHistory.isfrmUkazHistoriiShown then exit;
  if (globalHistory.undoPolozky.historyVector.Size >=100000) and
     frmUkazHistorii.checkBuffersSize  then
       if MessageDlg(Format(rsIfHistoryExc, [LineEnding, LineEnding, LineEnding]), mtWarning,
          [mbYes, mbNo], 0) = mrYes then
             begin
               frmUkazHistorii.close;
               exit;
             end;

  frmUkazHistorii.VET.ReinitNode(frmUkazHistorii.vet.RootNode,true);
   DebuglnThreadLog(format('%s',
         ['ReinitStromu VET - printHistoryVector:']));
  frmUkazHistorii.vetRedo.ReinitNode(frmUkazHistorii.vetRedo.RootNode,true);
   DebuglnThreadLog(format('%s',
         ['ReinitStromu vetRedo - printHistoryVector:']));
end;


{ THistoryItem }
constructor THistoryItem.create(pomString: string;pomHodnoty:THodnoty;sqlTyp:TsqlTypProUndo);
begin
  self.jmenoPolozky:=pomString;
  self.polePolozek:=TPolePolozek.Create;
  self.polePolozek.PushBack(TPolozka.create(sqlTyp,pomHodnoty));
end;

procedure THistoryItem.operaceDoPolePolozek(pomHodnoty: Thodnoty;
  sqlTyp: TsqlTypProUndo);

begin
  self.polePolozek.PushBack(TPolozka.create(sqlTyp,pomHodnoty));
end;

procedure THistoryItem.operaceZPolePolozek( pomDs: TDataset;pomUnRe:TUndoNeboRedo;pomPol:integer);
var
  i: Integer;
  v:variant;
  pomOperace:TsqlTypProUndo;
  nalezen: Boolean;
begin
  case pomUnRe of
    undo: pomOperace:=self.polePolozek.Items[pomPol].operaceUndo;
    redo: pomOperace:=self.polePolozek.Items[pomPol].operaceRedo;
  end;
  case pomOperace of
   insert:
          begin
           pomDs.Insert;
           for i:=0  to 10 do
             pomDs.Fields[i].AsString:= self.polePolozek.Items[pomPol].hodnoty[i];
           pomDs.Post;
          end;
   delete:
        begin
          v:=VarArrayCreate([0,10],varvariant);
          for i:=0  to 10 do
             v[i]:= self.polePolozek.Items[pomPol].hodnoty[i];
          nalezen:=pomDs.Locate('NAZEV;NAZEV_SERIALU;ROK;DRUH;UMISTENI;MEDIUM;DILY_CELKEM;DILY_NA_DISKU;SEZONA;STUBFILE;DIRECTORY',
                                 v,[loCaseInsensitive]);
          Form1.frmeventLog.Debug('Nalezen ? ' +
                                   BoolToStr(nalezen,'True','False'));
          if nalezen then  pomDs.Delete;
        end
  end;
  //self.polePolozek.PopBack;
end;

{ TGlobalHistory }

procedure TGlobalHistory.doUndo;
var
  i: Integer;
  pomNode: PVirtualNode;
  vybrane: TNodeArray;
begin
  if undoPolozky.historyVector.Size = 0 then
    begin
      // frmeventLog.Info(timetostr(Time)+' no undo to proceed');
      exit;
    end
                                            else
    //frmeventLog.Info(' Probíhá undo');
  probihaUndo:=True;
  for i:=0 to undoPolozky.historyVector.Back.polePolozek.Size-1 do
    undoPolozky.historyVector.Back.operaceZPolePolozek(
                                   dataSet as Tdataset,undo,i);
  redoPolozky.historyVector.PushBack(undoPolozky.historyVector.Back);
  redoPolozky.printHistoryVector;
  undoPolozky.historyVector.PopBack;
   if globalHistory.isfrmUkazHistoriiShown then
                globalHistory.undoPolozky.printHistoryVector;
  //end;
  probihaUndo:=False;
end;

procedure TGlobalHistory.doRedo;
var
  i: Integer;
begin
  if redoPolozky.historyVector.Size = 0 then
    begin
      //frmeventLog.Info(timetostr(Time)+' no redo to proceed');
      exit;
    end
                                         else
    //frmeventLog.Info(' Probíhá redo');
  probihaRedo:=True;
  for i:=0 to redoPolozky.historyVector.Back.polePolozek.Size-1 do
    redoPolozky.historyVector.Back.operaceZPolePolozek(
      dataSet as Tdataset,redo,i);
  undoPolozky.historyVector.PushBack(redoPolozky.historyVector.Back);
  undoPolozky.printHistoryVector;
  redoPolozky.historyVector.PopBack;
  if globalHistory.isfrmUkazHistoriiShown then
               globalHistory.redoPolozky.printHistoryVector;
  probihaRedo:=False;
end;

procedure TGlobalHistory.showHistoryBuffers;
begin
  frmUkazHistorii.FormStyle:=fsStayOnTop;
  //undoPolozky.printHistoryVector;  // při větším počtu položek uzké hrdlo
  frmUkazHistorii.Show;
end;

procedure TGlobalHistory.beforeDelete;
var
    pomHodnoty:THodnoty;
    i:Integer;
begin
 for i:=0 to 10 do
      pomHodnoty[i]:=dataSet.Fields.Fields[i].AsString;
 if (not probihaUndo) and (not probihaRedo)  then
     begin
      if redoPolozky.historyVector.Size <> 0 then
          begin
            redoPolozky.historyVector.Clear;
            redoPolozky.printHistoryVector;
            //frmeventLog.Info(timetostr(Time)+' redo buffer vyrázdněn');
          end;
      //frmeventLog.Info('Before delete: '+dataset.FieldByName('NAZEV').AsString);
      undoPolozky.historyVector.PushBack(THistoryItem.create(
         inttostr(undoPolozky.historyVector.Size+1)+' položka historie',
         pomHodnoty,insert));
      if globalHistory.isfrmUkazHistoriiShown then
               globalHistory.undoPolozky.printHistoryVector;
     end;
end;

procedure TGlobalHistory.beforeEdit;
var
    pomHodnoty:THodnoty;
    i:Integer;
begin
 for i:=0 to 10 do
      pomHodnoty[i]:=dataSet.Fields.Fields[i].AsString;
 if (not probihaUndo) and (not probihaRedo)  then
   begin
    //frmeventLog.Info('Before edit: '+dataset.FieldByName('NAZEV').AsString);
    // multiPolozkaHistorie:=True; - dataset.state automaticky na dsEdit;
    undoPolozky.historyVector.PushBack(THistoryItem.create(
      inttostr(Qword(undoPolozky.historyVector.Size)+1)+' položka historie (multi)',
      pomHodnoty,insert));
    //if globalHistory.isfrmUkazHistoriiShown then
    //           globalHistory.undoPolozky.printHistoryVector;
   end;

end;

procedure TGlobalHistory.beforePost;
var
     pomHodnoty:THodnoty;
     i:Integer;
begin
  //Memo2.Append('Before post: '+dataset.FieldByName('JMENO').AsString);
  for i:=0 to 10 do
      pomHodnoty[i]:=dataSet.Fields.Fields[i].AsString;
 if (not probihaUndo) and (not probihaRedo) then // neprobíhá Undo ani Redo
   begin  // tak by se asi mělo vyprázdnit Redo (probíhá normální operace)
          // tzn. todo
    if redoPolozky.historyVector.Size <> 0 then
      begin
        redoPolozky.historyVector.Clear;
        redoPolozky.printHistoryVector;
        //frmeventLog.Info(timetostr(Time)+' redo buffer vyrázdněn');
      end;
    //frmeventLog.Info('Before post: '+dataset.FieldByName('NAZEV').AsString);
    if (multiPolozkaHistorie) or (dataset.State=dsEdit) then
       begin
        undoPolozky.historyVector[undoPolozky.historyVector.Size-1].
               operaceDoPolePolozek(pomHodnoty,delete);
        if multiPolozkaHistorie then   multiPolozkaHistorie:=false;
        // dataset.State automaticky na dsBrowse po úspěšném dataset.Post;
       end
                            else
       begin
         undoPolozky.historyVector.PushBack(THistoryItem.create(inttostr(
          undoPolozky.historyVector.Size+1)+' položka historie',
          pomHodnoty,delete));
       end;
       if globalHistory.isfrmUkazHistoriiShown then
               globalHistory.undoPolozky.printHistoryVector;
   end;
end;

procedure TGlobalHistory.clearAndPrintUndoAndRedo;
begin
  undoPolozky.historyVector.Clear;
  redoPolozky.historyVector.Clear;
  undoPolozky.printHistoryVector;
  redoPolozky.printHistoryVector;
end;

constructor TGlobalHistory.create(ds: TDataset);
begin
  undoPolozky:=THistory.Create('Undo Buffer Items');
  redoPolozky:=THistory.Create('Redo Buffer Items');
  multiPolozkaHistorie:=False;
  probihaUndo:=False;
  probihaRedo:=False;
  dataSet:=ds;
end;

destructor TGlobalHistory.destroy;
begin
 self.undoPolozky.destroy;
 self.redoPolozky.destroy;
 inherited;
end;


 initialization
  begin
    globalHistory:=TGlobalHistory.create(nil); // v čase inicializace není dataset vytvořen
    // !!!!! need to asign real dataset used in form1
    // !!!!! in TForm1.create
    // !!!!! globalHistory.dataSet:=ZQuery1;
  end;

 finalization
 globalHistory.destroy;

end.

