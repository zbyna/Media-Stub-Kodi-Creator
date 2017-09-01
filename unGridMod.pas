unit unGridMod;

{$mode objfpc}{$H+}
 // provides possibility:
 //             - to extend selection with SHIFT + click in dbgrid :-)
 //             - to choose mousewheel pointer behaviour in dbgrid :-)
 //             - to sort by click on column headers
interface

uses
  Classes,db,DBGrids,ZDataset, Controls, SysUtils;

type

  { TShiftSelectForGrid }

  TShiftSelectForGrid = class
     previousBookmark:TBookmark;
     previousRecNo:LongInt;
     //dataSet:TDataSet;   // dataset is referenced from dbgrid.DataSource.DataSet;
     dbgrid:TDBGrid;
     procedure dbGridShiftSelect;
     constructor create({ds:TDataset;}dg:TDBGrid);
  end;

  { TWheelGridModification }

  TWheelGridModification = class
     kolecko:Boolean;
     dbgrid:TDBGrid;
     procedure dbAfterScroll;
     procedure dbBeforeScroll;
     constructor create(dg:TDBGrid);
  end;

  { TColumnClickSorting }

  TColumnClickSorting = class
     minulyColumnTridici:TColumn;
     globalSwitch:Boolean;
     zquery:TZquery;
     procedure dbColumnTitleClick(Column:TColumn);
     constructor create(zq:TZquery);
  end;

var
        shiftSelectForGrid:TShiftSelectForGrid;
        wheelGridModification:TWheelGridModification;
        columnClickSorting:TColumnClickSorting;

implementation

{ TColumnClickSorting }

procedure TColumnClickSorting.dbColumnTitleClick(Column: TColumn);
var
  PomStr : String;
  PomStr1 : String;
begin
  PomStr := Column.FieldName;
  if minulyColumnTridici <> nil then minulyColumnTridici.Title.ImageIndex:=-1;
  if GlobalSwitch then
     begin
       PomStr1:=' ASC';
       //StatusBar1.Panels[0].Text:='Seřazeno dle:  ' + PomStr + ' - vzestupně';
       column.Title.ImageIndex:=1;  // obrázek je imageListDBColumns;
     end
                 else
     begin
       PomStr1:=' DESC';
       //StatusBar1.Panels[0].Text:='Seřazeno dle:  ' + PomStr + ' - sestupně';
       column.Title.ImageIndex:=0;  // obrázek je imageListDBColumns;
     end;
  minulyColumnTridici:=Column;
  GlobalSwitch := not(GlobalSwitch);
  //ZQuery1.Close;
  ZQuery.SQL.Text:= 'SELECT * FROM "Offlinemedia" ORDER BY ' + Pomstr + PomStr1 + ', NAZEV';
  //viz. http://stackoverflow.com/questions/2051162/sql-multiple-column-ordering
  //ZQuery1.SQL.Text:= 'SELECT * FROM "Offlinemedia" where NAZEV = :SL ' ;  Parametry jsou
  //ZQuery1.ParamByName('SL').AsString:= 'Ran';                             jenom pro
  //ZQuery1.ParamByName('SL').DataType:=ftstring;                            HODNOTY !!!
  ZQuery.Open;
end;

constructor TColumnClickSorting.create(zq:TZquery);
begin
  self.zquery:=zq;
  self.globalSwitch:=True;
  self.minulyColumnTridici:=nil;
end;

{ TWheelGridModification }

procedure TWheelGridModification.dbAfterScroll;
begin
  if  (ssShift in GetKeyShiftState)  then
                  begin
                   DBGrid.SelectedRows.CurrentRowSelected:=true;
                   kolecko:=false;
                  end
                                     else
                  if kolecko then
                       begin
                        DBGrid.SelectedRows.CurrentRowSelected:=true;
                        kolecko:=false;
                       end;
end;

procedure TWheelGridModification.dbBeforeScroll;
begin
  if  (ssShift in GetKeyShiftState)  then
        begin
          DBGrid.SelectedRows.CurrentRowSelected:=true;
        end
                                     else
                      if kolecko then
                             begin
                              DBGrid.SelectedRows.CurrentRowSelected:=false;
                              DBGrid.SelectedRows.Refresh;
                             end;
end;

constructor TWheelGridModification.create(dg: TDBGrid);
begin
  self.dbgrid:=dg;
  // self.kolecko se nastaví v TForm1.DBGrid1MouseWheel
end;

{ TShiftSelectForGrid }

procedure TShiftSelectForGrid.dbGridShiftSelect;
var
	soucPos: TBookmark;
	grid: TDBGrid;
	dSet: TDataSet;
	prvni, posledni, pom: LongInt;
        existingBookmarks:TBookmark;
begin
  grid := self.dbgrid;   //(Sender as TDBGrid);
  dSet := grid.DataSource.DataSet;
  existingBookmarks := self.previousBookmark;
  // Get the current position (bookmark) and record number (the row we shift-clicked on)
  soucPos := dSet.GetBookmark;
  posledni := dSet.RecNo;
  dSet.DisableControls;
  try    // dummy loop that allows multiple exits to a single point
    repeat
	if not (ssShift in GetKeyShiftState) then exit;
	if (existingBookmarks = nil) then exit;
	// RecNo of record we clicked before we shift-clicked
        prvni:=self.previousRecNo;
	if posledni = prvni then exit;
        // from last (shift click) selected to the first to avoid annoing
        //                               scrolling when gotobookmart used
	// Is the position of activated item (shift clicked one)
        //                 under position of item clicked previously ?
	if posledni < prvni then    // yes we need go down the table
             repeat
		grid.SelectedRows.CurrentRowSelected := True;
                dset.Next;
                posledni:=dSet.RecNo;
                // keep going until we reach the last row
             until posledni = prvni
        else     // no we need go up the table
	      repeat
	        // highlight current row it means the shift-clicked one
	        grid.SelectedRows.CurrentRowSelected := True;
	        dset.Prior;
	        posledni := dSet.recNo;
	        // keep going until we reach the first row
	      until posledni = prvni ;
    until true;
  finally
    dSet.FreeBookmark(soucPos);
    dSet.EnableControls;
  end;
end;

constructor TShiftSelectForGrid.create({ds: TDataset;} dg: TDBGrid);
begin
  //self.dataSet:=ds;   // dataset is referenced from dbgrid.DataSource.DataSet;
  self.dbgrid:=dg;
  self.previousRecNo:=0;
  self.previousBookmark:=nil; // nastaví se později v metodě dbGridShiftSelect
end;                // a taky potřeba obnovit v TForm1.DBGrid1CellClick(Column:TColumn)

initialization
  begin
    shiftSelectForGrid:=TShiftSelectForGrid.create({nil,}nil); // v čase inicializace není DBGrid1 vytvořena
    // !!!!! need to asign  real dbgrid used in form1 in TForm1.create
    // !!!!!  shiftSelectForGrid.dbgrid:=DBGrid1;
    wheelGridModification:=TWheelGridModification.create(nil); // does not exist in time of initialisation
    // !!!!! need to asign  real dbgrid used in form1 in TForm1.create
    // !!!!!  wheelGridModification.dbgrid:=DBGrid1;
    columnClickSorting:=TColumnClickSorting.create(nil); // does not exist in time of initialisation
    // !!!!! need to asign  real dbgrid used in form1 in TForm1.create
    // !!!!!  columnClickSorting.zquery:=ZQuery1;
  end;

finalization
  begin
    // not needeed own destructor(means override TObject destructor)
    // b/c classes does not allocate any custom memory resources
    shiftSelectForGrid.destroy;
    wheelGridModification.destroy;
    columnClickSorting.destroy;
  end;
end.

