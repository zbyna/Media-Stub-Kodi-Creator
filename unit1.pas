unit Unit1;

{$mode objfpc}{$H+}
// {$DEFINE ZEOS_TEST_ONLY }    // zamezilo chybě Unknown property "TestMode"
                              // při upgradu z 4.8 na 5.2
                              // ale chybu způsoboval sandbox Keria :-)
interface

uses
  SysUtils, SdfData, db, fileutil, IDEWindowIntf, Forms, Controls, Dialogs,
  Menus, DBGrids, DbCtrls, StdCtrls, ExtCtrls, ComCtrls, ActnList, Unit2,
  unit3,unit5, unit6, unit7, ZConnection, ZDataset, ZSqlUpdate, Graphics,
  Classes,LCLIntf, LCLType, Grids, types, LCLTranslator, LazUTF8,
  LazFileUtils, LocalizedForms, usplashabout, eventlog,unHistory,unGridMod,
  unGlobalScraper;
{ Unity pro Form2, Form3 }

type

  { TForm1 }

  TForm1 = class(TLocalizedForm)
    Action1: TAction;
    ActionList1: TActionList;
    Datasource1: TDatasource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    frmeventLog: TEventLog;
    imageListDBColumns: TImageList;
    ImgListPopupMenu: TImageList;
    ImgListDBNavigator: TImageList;
    ImgListFileMenu: TImageList;
    ImgListToolBar: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItemHistoryShow: TMenuItem;
    MenuItemHistoryRedo: TMenuItem;
    MenuItemHistoryUndo: TMenuItem;
    MenuItemHistory: TMenuItem;
    MenuPomoc: TMenuItem;
    MenuObsah: TMenuItem;
    MenuOAplikaci: TMenuItem;
    MenuItemNastrojeUpravaFormatuCiselVName: TMenuItem;
    MenuItemNastrojeUpravaFormatuCiselVSerieName: TMenuItem;
    MenuItemNastrojeUpravaFormatuCiselVLocation: TMenuItem;
    MenuItemUpravUmisteniNazev: TMenuItem;
    MenuItemUpravUmisteniNazevSerialu: TMenuItem;
    MenuItemUpravUmisteniUmisteni: TMenuItem;
    MenuItemNastrojeHledej: TMenuItem;
    MenuItemNastrojeVytvorStubSoubory: TMenuItem;
    MenuItemNastrojeScrapujVyber: TMenuItem;
    MenuItemNastrojeUpravaFormatuCiselVUmisteni: TMenuItem;
    MenuItemNastrojeImportCSV: TMenuItem;
    MenuItemNastrojeExportCSV: TMenuItem;
    MenuItemNastroje: TMenuItem;
    MenuItemFilmyVytvorStubSoubory: TMenuItem;
    MenuItemFilmyHTStubfileDirectory: TMenuItem;
    MenuItemFilmyHZUmisteni: TMenuItem;
    MenuItemFilmyZmenFilmy: TMenuItem;
    MenuItemFilmyVytvorFilmy: TMenuItem;
    MenuItemFilmy: TMenuItem;
    MenuItemSerialyVytvorStubSoubory: TMenuItem;
    MenuItemSerialyHZKomplexni: TMenuItem;
    MenuItemSerialyHZRok: TMenuItem;
    MenuItemSerialyHZUmisteni: TMenuItem;
    MenuItemSerialyHZNazevSerialu: TMenuItem;
    MenuItemSerialyOznacSerial: TMenuItem;
    MenuItemSerialyVytvorSerial: TMenuItem;
    MenuItemSerialy: TMenuItem;
    MenuItemHledej: TMenuItem;
    MenuItemUpravUmisteni: TMenuItem;
    MenuNastaveni: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SdfDataSet1: TSdfDataSet;
    SplashAbout1: TSplashAbout;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolBtnNew: TToolButton;
    ToolBtnStubFile: TToolButton;
    ToolBtnHledej: TToolButton;
    ToolButtonOpenRecent: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolBtnScrapuj: TToolButton;
    ToolBtnOpen: TToolButton;
    ToolButton2: TToolButton;
    ToolButton20: TToolButton;
    ToolBtnSave: TToolButton;
    ToolBtnSaveAs: TToolButton;
    ToolBtnClose: TToolButton;
    ToolBtnExit: TToolButton;
    ToolBtnImport: TToolButton;
    ToolBtnExport: TToolButton;
    ToolBtnNastaveni: TToolButton;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    ZUpdateSQL1: TZUpdateSQL;

    procedure Action1Update(Sender: TObject);   {Akce pravidelně spouštěná když je aplikace idle}
    procedure DBGrid1CellClick(Column: TColumn);  {pro výběr pomocí clik + SHIFT}
    procedure DBGrid1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    //procedure DBGridShiftSelect(Sender: TObject; existingBookmarks: TBookmark); {obsluha clik+SHIFT}
    procedure DBGrid1TitleClick(Column: TColumn); {řazení po kliknutí na záhlaví}
    procedure DBNavigator1BeforeAction(Sender: TObject; Button: TDBNavButtonType
      );                                          {Přesměrování některých akci DBNavigator1}
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
                                                  {kontrola uložení poslední změny}
    procedure FormCreate(Sender: TObject);        {Při vytvoření Form1 inicializuj}
    procedure FormDestroy(Sender: TObject);        {Při ukončení Form1 vykonej}
    procedure MenuItem10Click(Sender: TObject);   {menu soubor - Ukončit}
    procedure MenuItem12Click(Sender: TObject);  {popup Seriály Hromadná změna "Název seriálu"}
    procedure MenuItem13Click(Sender: TObject);  {popup Seriály Hromadná změna "Umístění"}
    procedure MenuItem14Click(Sender: TObject);  {popup Seriály Vytvoř seriál }
    procedure MenuItem1Click(Sender: TObject);  {menu Soubor - viditelnost položek}
    procedure MenuItem24Click(Sender: TObject);   {popup Seriály Označ seriál}
    procedure MenuItem15Click(Sender: TObject);  {popup Seriály Hromadná změna ""Rok""}
    procedure MenuItem16Click(Sender: TObject);  {popup Seriály Hromadná změna Vytvoř stub soubory}
    procedure MenuItem17Click(Sender: TObject);  {popup Seriály Hromadná změna- komplexní}
    procedure MenuItem19Click(Sender: TObject);    {popup Filmy Vytvoř film (y)}
    procedure MenuItem20Click(Sender: TObject);    {popup Filmy Hromadná změna "Umístění"}
    procedure MenuItem21Click(Sender: TObject);    {popup Filmy Vytvoř stub soubory}
    procedure MenuItem22Click(Sender: TObject);    {popup Filmy Změň film (y)}
    procedure MenuItem23Click(Sender: TObject);    {popup Filmy Hromadná tvorba "Stubfile"+"Directory"}
    procedure MenuItem26Click(Sender: TObject);     {popup Nástroje Import CSV}
    procedure MenuItem27Click(Sender: TObject);     {popup Nástroje Export CSV}
    procedure MenuItem28Click(Sender: TObject);         {popup Smaž výběr}
    procedure MenuItem29Click(Sender: TObject);         {popup Scrapuj výběr}
    procedure MenuItem2Click(Sender: TObject);    {menu soubor - New}
    procedure MenuItem30Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);    {menu soubor - Open}
    procedure MenuItem5Click(Sender: TObject);    {menu soubor - Otevřít nedávné}
    procedure MenuItem6Click(Sender: TObject);    {menu soubor - Save}
    procedure MenuItem7Click(Sender: TObject);    {menu soubor - Save As}
    procedure MenuItem8Click(Sender: TObject);    {menu soubor - Close}
    procedure MenuItemFilmyClick(Sender: TObject);   {menu Filmy - viditelnost položek}
    procedure MenuItemHistoryClick(Sender: TObject);
    procedure MenuItemHistoryRedoClick(Sender: TObject);
    procedure MenuItemHistoryShowClick(Sender: TObject);
    procedure MenuItemHistoryUndoClick(Sender: TObject);
    procedure MenuItemHledejClick(Sender: TObject); {popUp Hledej}
    procedure MenuItemNastrojeClick(Sender: TObject); {menu Nastroje - viditelnost položek}
    procedure MenuItemSerialyClick(Sender: TObject); {menu Serialy - viditelnost položek}
    procedure MenuItemUpravUmisteniClick(Sender: TObject); {popup Nástroje Úprava čísel v Umístění}
    procedure MenuItemUpravUmisteniNazevClick(Sender: TObject);
    procedure MenuItemUpravUmisteniNazevSerialuClick(Sender: TObject);
    procedure MenuItemUpravUmisteniUmisteniClick(Sender: TObject);
    procedure MenuNastaveniClick(Sender: TObject);  {menu Nastavení}
    procedure MenuOAplikaciClick(Sender: TObject);
    procedure MenuObsahClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);      {PopUp menu - viditelnost položek}
    Procedure MojeOnClick(sender:TObject); {handler pro položky menu soubor - Otevřít nedávné}
    Procedure VlozDoHistoryFiles(PomString:string);  {aktualizace HistoryFiles objektu}
    Procedure UlozZmenySQL;                      {Uloží změny do databáze (souboru) transakčně}
    Function ZjistiPromNovySerial():boolean; {zjištění stavu NovySerial z jiných unitů :-)getter}
    procedure ZQuery1AfterDelete(DataSet: TDataSet);
    procedure ZQuery1AfterInsert(DataSet: TDataSet);
    procedure ZQuery1AfterOpen(DataSet: TDataSet);
    procedure ZQuery1AfterPost(DataSet: TDataSet);
    procedure ZQuery1AfterScroll(DataSet: TDataSet);
    procedure ZQuery1BeforeDelete(DataSet: TDataSet);
    procedure ZQuery1BeforeEdit(DataSet: TDataSet);
    procedure ZQuery1BeforePost(DataSet: TDataSet);
    procedure ZQuery1BeforeScroll(DataSet: TDataSet);
    procedure ZQuery1PostError(DataSet: TDataSet; E: EDatabaseError; // aby nebylo možné zadat duplicity
      var DataAction: TDataAction);
  private
    { private declarations }
    NovySerial:Boolean;        {pro přepínání Form3 Nový seriál/Hromadná změna komplexní}
  public
    { public declarations }
    pomColumnForNumFormatAdujstment:TColumn;
    procedure UpdateTranslation(ALang: String); override;
  end;


var
  Form1: TForm1;
   { pro scraping roku k seriálu a filumu, potřeba inicializovat při vytvoření Form1 }



resourcestring
  rsJmNoSouboruN = 'The file name can not be new.fdb%s';
  rsNeuloEnZmNy = 'Unsave changes';
  rsVSouboruJsou = 'There are unsaved changes in file,%sdo you want to save them'
    +' ?';
  rsSeAzenoDle = 'Sorted by:  ';
  rsVytvoEnNovPo = 'New item creation';
  rsVytvoItNovSe = 'Create new series of film ?';
  rsPoEtZZnam = 'Total records: %s';
  rsPoEtZZnam0 = 'Total records: 0 ';
  rsHromadnZmNaN = 'Bulk change of series name';
  rsNovNZev = 'New name ?';
  rsVytvoFilm = 'Create film';
  rsZmFilmY = 'Change film(s)';
  rsChybkaSeVlou = 'Something went wrong';
  rsAktuLnScrape = 'Actual scraper finds nothing.%sWhat next ?';
  rsZmNitScraper = 'Change scraper';
  rsPokraOvatBez = 'Scrape next item';
  //rsPokraOvatNaD = 'Scrape next item';
  rsHromadnZmNaR = 'Bulk change of year';
  rsNovRok = 'New year?';
  rsUndoBufferIt = 'Undo Buffer Items';
  rsRedoBufferIt = 'Redo Buffer Items';
  rsHelpHTMLEnIn = '\Help\en\Help.chm';
  //------------ unit 3 ------------------------------------------------
  rsVytvoSeriL = 'Create series';
  rsPoEtDiskVeVB = 'Number disks in selection is: %s';
  rsSeriLHromadn = 'Series - Bulk change complex';
  rsSezNa = 'Season n.';
  rsDisk = 'Disk n.';
  rsPoEtVybranCh = 'Number of disks chosen to change is %s';
  rsDL = 'Episode n.';
  rsProHledNRoku = 'For year scraping %sis neede to check also '
    +'field "Series name"';
  rsSezonyCelkem = 'Total seasons: %s';
  rsDiskyCelkem = 'Total disks: %s';
  rsDLyCelkem = 'Total episodes: %s';
  rsSezona = 'Season n.%s';
  rsDisk2 = 'Disk n.%s';
  rsDL2 = 'Episode n.%s';
  rsSezona1 = 'Season n.1';
  rsDisk1 = 'Disk n.1';
  rsSeasonDiskEp = 'Season : Disk : Episode';
  //------------- unit 6 ------------------------------------------------
  rsPouTIndexUmS = 'Use location index ?';
  rsBZeIndexu = 'Index base';
  rsIndexOd = 'Beginning index from ?';
  //-------------Záhlaví tabulky-----------------------------------------
  rsName = 'Name';
  rsSerieName = 'Series name';
  rsYear = 'Year';
  rsSort = 'Sort';
  rsLocation = 'Location';
  rsMedium = 'Medium';
  rsTotalEpisode = 'Total episodes';
  rsEpisodesOnDi = 'Episodes on disk';
  rsSeason = 'Season';
  rsStubfile = 'Stubfile';
  rsDirectory = 'Directory';
  //--------------unit 7-------------------------------------------------
  rsHighlightIni = 'Highlight initial position';
  rsDoNotHighlig = 'Do not highlight initial position';
  rsSeriesFilms = 'Series: %s Films: %s       ';
  //--------------unit 2-------------------------------------------------
  rsInintialInde = 'Initial index value';
  rsFixedPartOfL = 'Fixed part of Location (text)';
  //--------------unit 4-------------------------------------------------
  rsTotalSeasons = 'Total seasons:';
  rsNumberOfDisk = 'Number of disks for season:';
  rsNumberOfEpis = 'Number of episodes for disk:';
  //--------------unit 5-------------------------------------------------
  rsAlternativeT = 'Alternative title';
  rsMessageToBeD = 'Message to be displayed';
  rsDirectory2 = 'Directory :';
   //--------------unit 10------------------------------------------------
  rsChangeFormat = 'Change format of all numbers in field';
  rsIfHistoryExc = 'If  history exceeds number of 100 items%sit may slow down '
    +'program reaction time during%slarge database operations.%sHIDE HISTORY FORM';
  rsUndoHistoryI = 'Undo History Item name: ';



implementation

{$R *.lfm}
uses unit8,unit9,Unit10,       { chci pracovat s objekty v unit8 tzn. scrapovat rok k filmu }
     unHledej;                 { chci pracovat s objekty v unit9 tzn. naplnit tabulkaVysledku}



{ TForm1 }

var
  ZmenaVDatabazi:boolean;  {byla změněná základní tabulka ?
                              souvisí s SQLQuery1AfterEdit
                                        SQLQuery1AfterInsert
                                        SQLQuery1AfterPost }
 HistoryFiles:TStringList;   {seznam naposledy otevřených souborů}
 JmenoAktSoubor:String;      {jméno aktuálně otevřeného souboru}
 jednouPoOtevreni:Boolean; // pro roztahování tabulky
 NovySerial:Boolean;        {pro přepínání Form3 Nový seriál/Hromadná změna komplexní}
// moved to unGridMod.shiftSelectForGrid
// previousGridBookmark: TBookmark; {pro výběr pomocí clik + SHIFT }

// moved to unGridMod.ccolumnClickSorting
//GlobalSwitch:Boolean;       {pro přepínání třídění ASC / DES kliknutím na sloupec}
//minulyColumnTridici:TColumn; {pro přepínání třídění ASC / DES kliknutím na sloupec}





procedure TForm1.MenuItem2Click(Sender: TObject);         {menu soubor - New}
begin
 If opendialog1.Execute = true then
   begin
      ZQuery1.Close;
      ZQuery1.SQL.Text:= 'SELECT * FROM "Offlinemedia" ';
      ZQuery1.Close; {zavřít původní databázi - to samé je v menu Soubor - Close}
      //SQLTransaction1.Active:= False;
      ZConnection1.Connected:= False;
      If 'new' <> systoutf8(ExtractFileNameOnly(UTF8tosys(Opendialog1.FileName))) then
         begin
           CopyFile('new.fdb',Opendialog1.FileName);  {vytvořit kopii databáze, cesty v UTF8}
           JmenoAktSoubor := Opendialog1.FileName;
           Form1.Caption:= Form1.Caption + '  ' + JmenoAktSoubor;
           VlozDoHistoryFiles(JmenoAktSoubor);
           ZConnection1.Database:= (UTF8ToSys(Opendialog1.FileName));  {otevřít novou databázi}
           ZConnection1.Connected:= True;
           //SQLTransaction1.Active:= True;   {Zeos DB narozdíl od SQLDB implicitně automaticky}
           ZQuery1.Open;                       { používá transakce a ukládá po změně}
           ZmenaVDatabazi := false;   {žádná změna základní tabulky zatím neproběhla}
           DBGrid1.SelectedRows.CurrentRowSelected:=true;{po otevření vybrat celý řádek}
         end
                                        else
         MessageDlg(Format(rsJmNoSouboruN, [LineEnding]), mtError, [mbOK], 0);
      DBGrid1CellClick(DBGrid1.Columns[0]); // aby fungoval výběr pomoci SHIFT+click
   end;
end;

procedure TForm1.MenuItem30Click(Sender: TObject);
begin
  if  Form5.ShowModal = mrOK then
 begin
 end;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);           {menu soubor - Open}
begin
  If opendialog1.Execute = true then
   begin
        //SdfDataSet1.FirstLineAsSchema:= true;
        //SdfDataSet1.FileName := UTF8ToSys(OpenDialog1.FileName);
        //SdfDataSet1.Active := true;
        ZQuery1.Close;
        ZQuery1.SQL.Text:= 'SELECT * FROM  "Offlinemedia" ORDER BY '
                           + Dbgrid1.Columns.Items[0].FieldName  +' ASC';
        ZConnection1.Database:= UTF8ToSys(OpenDialog1.FileName);          //
        ZConnection1.Connected:= True;
        //SQLTransaction1.Active:= True;
        ZQuery1.Open;
        JmenoAktSoubor := Opendialog1.FileName;
        jednouPoOtevreni:=True;
        Form1.Caption:= Form1.Caption + '  ' + JmenoAktSoubor;
        VlozDoHistoryFiles(JmenoAktSoubor);
        ZmenaVDatabazi := false;         {žádná změna základní tabulky zatím neproběhla}
        DBGrid1.SelectedRows.CurrentRowSelected:=true;{po otevření vybrat celý řádek, ne jen
        buňka}
        DBGrid1CellClick(DBGrid1.Columns[0]); // aby fungoval výběr pomoci SHIFT+click
       // StatusBar1.Panels[0].Text:='Počet záznamů: '+inttostr(ZQuery1.RecordCount);
   end;
end;



procedure TForm1.MenuItem5Click(Sender: TObject); {menu soubor - Otevřít nedávné}

var
 PomMenu : TMenuItem;
 i: Integer;

begin
 {vytvoř položky menu  soubor - Otevřít nedávné ------ začátek}
 MenuItem5.Clear;
 PomMenu := TmenuItem.create(Self);
 HistoryFiles := Tstringlist.create;
 HistoryFiles.LoadFromfile('history.txt');
 for i:=0 to HistoryFiles.Count-1 do
  begin
    PomMenu := TmenuItem.create(Self);
    PomMenu.Caption :=SysToUTF8( HistoryFiles.Strings[i]);
    PomMenu.OnClick := @MojeOnClick;
    MenuItem5.Add(PomMenu);
  end;
 {vytvoř položky menu  soubor - Otevřít nedávné  ------ konec}
end;

procedure TForm1.MenuItem6Click(Sender: TObject);       {menu soubor - Save}
begin
    UlozZmenySQL
end;

procedure TForm1.MenuItem7Click(Sender: TObject);   {menu soubor - Save As}
var
  PomStr : String;
begin
   SaveDialog1.FileName:= ExtractFileNameOnly(JmenoAktSoubor);
   if SaveDialog1.execute  then      {}
   begin
     //SdfDataset1.SaveFileAs(UTF8ToSys(savedialog1.FileName));
      {uložit provedené změny - to samé je v menu Soubor - Save}
    UlozZmenySQL;
    PomStr:=SystoUTF8(ZConnection1.Database);
    ZQuery1.Close; {zavřít původní databázi - to samé je v menu Soubor - Close}
    ZConnection1.Connected:= False;
    if PomStr <> Savedialog1.FileName then
        CopyFile(PomStr,savedialog1.FileName);  {vytvořit kopii databáze, cesty v UTF8}
    ZConnection1.Database:= (UTF8ToSys(Savedialog1.FileName));  {otevřít novou databázi}
    ZConnection1.Connected:= True;
    //SQLTransaction1.Active:= True;
    ZQuery1.Open;
    JmenoAktSoubor := Savedialog1.FileName;
    Form1.Caption:= 'Media Stub Kodi Creator' + '  ' + JmenoAktSoubor;
    VlozDoHistoryFiles(JmenoAktSoubor);
    ZmenaVDatabazi := false    {vynulování změn základní tabulky }
   end;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);    {menu Close}
var
  PomStr : string;
begin
  if (ZmenaVDatabazi)  then
    if QuestionDlg(rsNeuloEnZmNy, Format(rsVSouboruJsou, [LineEnding]),
      mtWarning, [mrYes, 'Yes', mrNo, 'No'], 0)
                     = mrYes then
       begin
           SaveDialog1.FileName:= ExtractFileNameOnly(JmenoAktSoubor);
           if SaveDialog1.execute  then
            begin
             //SdfDataset1.SaveFileAs(UTF8ToSys(savedialog1.FileName));
             {uložit provedené změny - to samé je v menu Soubor - Save}
              UlozZmenySQL;
              PomStr:=SystoUTF8(ZConnection1.Database);
              ZQuery1.Close; {zavřít původní databázi - to samé je v menu Soubor - Close}
              //SQLTransaction1.Active:= False;
              ZConnection1.Connected:= False;
              If PomStr <> Savedialog1.FileName then
                CopyFile(PomStr,savedialog1.FileName);  {vytvořit kopii databáze, cesty v UTF8}
              ZmenaVDatabazi := false;    {vynulování změn základní tabulky }
            end;
       end;
  //sdfDataset1.Close;
  //SdfDataSet1.FileMustExist:=true;
  ZQuery1.Close;
  //SQLTransaction1.Active:= False;
  ZConnection1.Connected:= False;
  Form1.Caption:= 'Media Stub Kodi Creator  ';
  ZmenaVDatabazi := false;    {vynulování změn základní tabulky }
  StatusBar1.Panels[0].Text:=rsSeAzenoDle;
  JmenoAktSoubor:='';
  globalHistory.clearAndPrintUndoAndRedo;
end;

procedure TForm1.MenuItemFilmyClick(Sender: TObject);
begin
  if  JmenoAktSoubor='' then
   begin
    MenuItemFilmyVytvorFilmy.Enabled:=false;
    MenuItemFilmyZmenFilmy.Enabled:=false;
    MenuItemFilmyHZUmisteni.Enabled:=false;
    MenuItemFilmyHTStubfileDirectory.Enabled:=false;
    MenuItemFilmyVytvorStubSoubory.Enabled:=false;
   end
                       else
   begin
    MenuItemFilmyVytvorFilmy.Enabled:=True;
    MenuItemFilmyZmenFilmy.Enabled:=True;
    MenuItemFilmyHZUmisteni.Enabled:=True;
    MenuItemFilmyHTStubfileDirectory.Enabled:=True;
    MenuItemFilmyVytvorStubSoubory.Enabled:=True;
   end;

end;

procedure TForm1.MenuItemHistoryClick(Sender: TObject);
begin
  if globalHistory.undoPolozky.historyVector.Size = 0 then
     MenuItemHistoryUndo.Enabled:=False
                                        else
     MenuItemHistoryUndo.Enabled:=True;
   if globalHistory.redoPolozky.historyVector.Size = 0 then
     MenuItemHistoryRedo.Enabled:=False
                                        else
     MenuItemHistoryRedo.Enabled:=True;
end;

procedure TForm1.MenuItemHistoryRedoClick(Sender: TObject);

begin
  globalHistory.doRedo;
end;

procedure TForm1.MenuItemHistoryShowClick(Sender: TObject);
begin
  //frmUkazHistorii.FormStyle:=fsStayOnTop;
  //frmUkazHistorii.Show;
  globalHistory.showHistoryBuffers;
end;

procedure TForm1.MenuItemHistoryUndoClick(Sender: TObject);

begin
  globalHistory.doUndo;
end;

procedure TForm1.MenuItemHledejClick(Sender: TObject);  {popUp Hledej}
begin
  //  vytvořit frmHledej;
  Application.CreateForm(TfrmHledej,frmHledej);
  frmHledej.Show;
  // ZQuery1.Locate();
  // uvolnit frmHledej;
  // Application.ReleaseComponent(frmHledej);
end;

procedure TForm1.MenuItemNastrojeClick(Sender: TObject);
begin
 if  JmenoAktSoubor='' then
   begin
    MenuItemNastrojeImportCSV.Enabled:=false;
    MenuItemNastrojeExportCSV.Enabled:=false;
    MenuItemNastrojeUpravaFormatuCiselVUmisteni.Enabled:=false;
    MenuItemNastrojeScrapujVyber.Enabled:=false;
    MenuItemNastrojeVytvorStubSoubory.Enabled:=false;
    MenuItemNastrojeHledej.Enabled:=false;
   end
                       else
   begin
    MenuItemNastrojeImportCSV.Enabled:=True;
    MenuItemNastrojeExportCSV.Enabled:=True;
    MenuItemNastrojeUpravaFormatuCiselVUmisteni.Enabled:=True;
    MenuItemNastrojeScrapujVyber.Enabled:=True;
    MenuItemNastrojeVytvorStubSoubory.Enabled:=True;
    MenuItemNastrojeHledej.Enabled:=True;

   end;
end;

procedure TForm1.MenuItemSerialyClick(Sender: TObject);
begin
  if  JmenoAktSoubor='' then
   begin
    MenuItemSerialyVytvorSerial.Enabled:=false;
    MenuItemSerialyOznacSerial.Enabled:=false;
    MenuItemSerialyHZNazevSerialu.Enabled:=false;
    MenuItemSerialyHZUmisteni.Enabled:=false;
    MenuItemSerialyHZRok.Enabled:=false;
    MenuItemSerialyHZKomplexni.Enabled:=false;
    MenuItemSerialyVytvorStubSoubory.Enabled:=false;
   end
                       else
   begin
    MenuItemSerialyVytvorSerial.Enabled:=True;
    MenuItemSerialyOznacSerial.Enabled:=True;
    MenuItemSerialyHZNazevSerialu.Enabled:=True;
    MenuItemSerialyHZUmisteni.Enabled:=True;
    MenuItemSerialyHZRok.Enabled:=True;
    MenuItemSerialyHZKomplexni.Enabled:=True;
    MenuItemSerialyVytvorStubSoubory.Enabled:=True;
   end;

end;

procedure TForm1.MenuItemUpravUmisteniClick(Sender: TObject);
                                                    {popup Nástroje Úprava čísel v Umístění}
begin
  // tady se nic neděje :-) ale dělo se :-)
end;

procedure TForm1.MenuItemUpravUmisteniNazevClick(Sender: TObject);
begin
  pomColumnForNumFormatAdujstment:=DBGrid1.Columns.Items[0];
  if  FormUpravUmisteni.ShowModal = mrOK then
         begin
         end;
end;

procedure TForm1.MenuItemUpravUmisteniNazevSerialuClick(Sender: TObject);
begin
  pomColumnForNumFormatAdujstment:=DBGrid1.Columns.Items[1];
  if  FormUpravUmisteni.ShowModal = mrOK then
         begin
         end;
end;

procedure TForm1.MenuItemUpravUmisteniUmisteniClick(Sender: TObject);
begin
  pomColumnForNumFormatAdujstment:=DBGrid1.Columns.Items[4];
  if  FormUpravUmisteni.ShowModal = mrOK then
         begin
         end;
end;

procedure TForm1.MenuNastaveniClick(Sender: TObject);   {menu Nastavení}
begin
  if FormNastaveni.ShowModal = mrOK then
  begin

  end;
end;

procedure TForm1.MenuOAplikaciClick(Sender: TObject);
begin
  SplashAbout1.ShowAbout;
end;

procedure TForm1.MenuObsahClick(Sender: TObject);
begin
  OpenURL(GetCurrentDirUTF8+rsHelpHTMLEnIn);
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);  {PopUp menu - viditelnost položek}
begin
  If JmenoAktSoubor='' then
  begin
    MenuItem11.Enabled:=False;
    MenuItem18.Enabled:=False;
    MenuItem25.Enabled:=False;
    MenuItem28.Enabled:=False;
    MenuItem29.Enabled:=False;
    MenuItem30.Enabled:=False;
    MenuItemHledej.Enabled:=False;
  end
                       else
  begin
    //DBGrid1.SelectedRows.CurrentRowSelected:=True;
    MenuItem11.Enabled:=True;
    MenuItem18.Enabled:=True;
    MenuItem25.Enabled:=True;
    MenuItem28.Enabled:=True;
    MenuItem29.Enabled:=True;
    MenuItem30.Enabled:=True;
    MenuItemHledej.Enabled:=True;
  end;
end;

procedure TForm1.MenuItem10Click(Sender: TObject);   {menu soubor - Ukončit}
begin
 Form1.Close;
end;

procedure TForm1.DBGrid1TitleClick(Column: TColumn);  {řazení po kliknutí na záhlaví}
var
  pomWidth: array[0..10] of integer;
  i:Byte;
begin
  if JmenoAktSoubor = '' then exit;
  for i:=0 to 10 do   // aby se skokově neměnila velikost sloupců
      pomWidth[i]:=DBGrid1.Columns.Items[i].Width;

  columnClickSorting.dbColumnTitleClick(Column);

  for i:=0 to 10 do    // aby se skokově neměnila velikost sloupců
      DBGrid1.Columns.Items[i].Width:=pomWidth[i];
  DBGrid1.SelectedRows.CurrentRowSelected:=true;{po otevření vybrat celý řádek, ne jen buňka}
end;

procedure TForm1.DBNavigator1BeforeAction(Sender: TObject;          {Přesměrování některých }
                                          Button: TDBNavButtonType);{akci DBNavigator1}
begin
 // DBNavigator1.BtnClick();
  case Button  of
    nbDelete   : begin
                    MenuItem28.Click;
                    SysUtils.Abort;             //zruší provedení původní akce pro tlačítko
                 end;
    nbEdit     : begin
                  ZQuery1.GotoBookmark(Dbgrid1.SelectedRows.Items[0]);
                  If ZQuery1.FieldByName('DRUH').AsString='series'
                          then MenuItem17.Click
                          else MenuItem22.Click;
                  SysUtils.Abort;
                 end;    // když seriál a jeden řádek tak vybrat celý seriál
    nbInsert   : begin
                   case QuestionDlg(rsVytvoEnNovPo, rsVytvoItNovSe
                     , mtWarning, [mrYes, 'Series', mrNo,
                     'Film'], 'HelpKeyWordEdit') of
                    mrYes:MenuItem14.Click ;
                    mrNo:MenuItem19.Click ;
                   end;       // rozhodnout podle druhu
                   SysUtils.Abort;             //zruší provedení původní akce pro tlačítko
                 end;
    end;


end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin                            {kontrola uložení poslední změny}
  canClose:=not zmenaVDatabazi;
  if zmenaVDatabazi then Form1.MenuItem8.Click;
end;

procedure TForm1.Action1Update(Sender: TObject);
                                         {Akce pravidelně spouštěná když je aplikace idle}
// OBROVSKY DULEŽITÉ:
// TCustomAction.DisableIfNoHandler musí být false (default je true)
// jinak se po druhém clicku na holý Form1 aplikace zasekne
// tzn. formálně běží, ale nereaguje, zřejmě používáš Action jinak než
// jsou zamýšlené :-) viz.
// http://docs.embarcadero.com/products/rad_studio/radstudio2007/RS2007_helpupdates/HUpdate4/EN/html/delphivclwin32/ActnList_TCustomAction_DisableIfNoHandler.html
var

  sloupceCelkem:integer;
  i: Byte;
  pomWidth: Integer;
begin
  sloupceCelkem:=0;
  for i:=0 to dbgrid1.Columns.Count-1 do
      sloupceCelkem:=sloupceCelkem+dbgrid1.Columns.Items[i].Width;
  pomWidth:= (Form1.Left + sloupceCelkem + 55) - Screen.Width;
  if pomWidth > 0  then
    begin
      if Form1.Left - pomWidth >= 0 then
        begin
           Form1.Width:=sloupceCelkem+55-pomWidth;
           If jednouPoOtevreni then
             begin
              Form1.Left:= Form1.Left-pomWidth; // zkusit přepínač jendou a jenom po otevření
              jednouPoOtevreni:=not(jednouPoOtevreni);
             end;
        end;
    end
                  else
    Form1.Width:=sloupceCelkem+55;
   //DBGrid1.AutoAdjustColumns;

  if  JmenoAktSoubor='' then
   begin
    ToolBtnSave.Enabled:=false;
    ToolBtnSaveAs.Enabled:=false;
    ToolBtnClose.Enabled:=false;
    ToolBtnImport.Enabled:=false;
    ToolBtnExport.Enabled:=false;
    ToolBtnScrapuj.Enabled:=false;
    ToolBtnStubFile.Enabled:=false;
    ToolBtnHledej.Enabled:=false;

   end
                       else
   begin
    ToolBtnSave.Enabled:=true;
    ToolBtnSaveAs.Enabled:=true;
    ToolBtnClose.Enabled:=true;
    ToolBtnImport.Enabled:=true;
    ToolBtnExport.Enabled:=true;
    ToolBtnScrapuj.Enabled:=true;
    ToolBtnStubFile.Enabled:=true;
    ToolBtnHledej.Enabled:=true;
    // StatusBar1.Panels[0].Text:='Počet záznamů: '+inttostr(ZQuery1.RecordCount);
   end;
end;

procedure TForm1.DBGrid1CellClick(Column: TColumn);

begin
  //DBGridShiftSelect(DBGrid1, previousGridBookmark);  {pro výběr pomocí clik + SHIFT}
  shiftSelectForGrid.dbGridShiftSelect; {pro výběr pomocí clik + SHIFT}
  ////previousGridBookmark := DBGrid1.DataSource.DataSet.GetBookmark; je to depreciated
  //previousGridBookmark := ZQuery1.Bookmark; // save last selected bookmark
  shiftSelectForGrid.previousBookmark:=ZQuery1.Bookmark;  // save last selected bookmark
  ////if minulyColumnKliknuty <> nil then minulyColumnKliknuty.Title.Color:=clWindow;
  ////Column.Title.Color:=cl3DLight;
  ////minulyColumnKliknuty:=Column;
end;

procedure TForm1.DBGrid1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  {spolupracuje s TForm1.ZQuery1.AfterScroll a TForm1.ZQuery1.BeforeScroll}
    // při otočení kolečkem nezůstává první řádek vybraný
  // zkusit přidat parametr výběr kolečkem myši, aby se dalo chování vybrat
  if FormNastaveni.mysKoleckoOznaceni.ItemIndex = 1 then
                                     wheelGridModification.kolecko:=true;
end;

procedure TForm1.MojeOnClick(sender: TObject);  {handler pro položky menu
                                               soubor - Otevřít nedávné }
var
   PomString : string;
begin
  PomString := (Sender as TmenuItem).Caption ;
  jednouPoOtevreni:=True;

  if ZQuery1.Active then
       MenuItem8.Click;  {Vyvolá událost obsouženou TForm1.MenuItem8Click tj. soubor - zavřít}
  ZQuery1.Close;
  ZQuery1.SQL.Text:= 'SELECT * FROM  "Offlinemedia" ORDER BY NAZEV ASC ';
  ZConnection1.Database:= UTF8ToSys(PomString);
  ZConnection1.Connected:= True;
  //SQLTransaction1.Active:= True;
  ZQuery1.Open;
  JmenoAktSoubor := PomString;
  VlozDoHistoryFiles(JmenoAktSoubor);
  Form1.Caption:= Form1.Caption + '  ' + JmenoAktSoubor;
  ZmenaVDatabazi := false;
  DBGrid1.SelectedRows.CurrentRowSelected:=true;{po otevření vybrat celý řádek, ne jen buňka}
  DBGrid1CellClick(DBGrid1.Columns[0]); // aby fungoval výběr pomoci SHIFT+click
  //StatusBar1.Panels[0].Text:='Počet záznamů: '+inttostr(ZQuery1.RecordCount);
end;



procedure TForm1.VlozDoHistoryFiles(PomString: string);  {aktualizace HistoryFiles objektu}
var
  i: byte;
begin
  for i:=HistoryFiles.Count-1 downto 1  do
    HistoryFiles.Strings[i] := HistoryFiles.Strings[i-1];
  HistoryFiles.Strings[0] := UTF8ToSys(PomString);
  HistoryFiles.SaveToFile('history.txt');
end;

procedure TForm1.UlozZmenySQL;                      {Uloží transakčně změny v SQLQuery1}
 begin                                              {SQLQuery1 je DataSet descendant}
  try                  {Zeos DB narozdíl od SQLDB implicitně automaticky}
                 { používá transakce a ukládá po změně takže je tahle procedura zbytečná :-)}
    //if SQLTransaction1.Active then
    //  begin
        ZConnection1.Commit;            //Pass user-generated changes back to database...
        //SQLTransaction1.Commit;           //... and commit them using the transaction.
        ZConnection1.Connected:= True;   //SQLTransaction1.Active now is false
        //SQLTransaction1.Active:= True;
        ZQuery1.Open;                    {znovu obnovit spojení a naplnit DBgrid}
        ZmenaVDatabazi := false    {vynulování změn základní tabulky }
      //end;
  except
  on E: EDatabaseError do
    begin
      MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
        E.Message, mtError, [mbOK], 0);
    end;
  end;
 end;

function TForm1.ZjistiPromNovySerial(): boolean; {zjištění stavu NovySerial z jiných unitů :-)getter}
begin
  ZjistiPromNovySerial:=NovySerial;
end;

procedure TForm1.ZQuery1AfterDelete(DataSet: TDataSet);
begin
  ZmenaVDatabazi:=true;    {ano proběhla změna základní tabulky je třeba ji uložit, to  }
  DBGrid1.SelectedRows.CurrentRowSelected:=true;{po otevření vybrat celý řádek, ne jen buňka}
  StatusBar1.Panels[0].Text:=Format(rsPoEtZZnam, [inttostr(ZQuery1.RecordCount)]);
end;

procedure TForm1.ZQuery1AfterInsert(DataSet: TDataSet);
begin
  StatusBar1.Panels[0].Text:=Format(rsPoEtZZnam, [inttostr(ZQuery1.RecordCount)]);
end;

procedure TForm1.ZQuery1AfterOpen(DataSet: TDataSet);
begin
  StatusBar1.Panels[0].Text:=Format(rsPoEtZZnam, [inttostr(ZQuery1.RecordCount)]);
end;

procedure TForm1.ZQuery1AfterPost(DataSet: TDataSet);
begin
  ZmenaVDatabazi:=true;    {ano proběhla změna základní tabulky je třeba ji uložit, to  }
  DBGrid1.SelectedRows.CurrentRowSelected:=true;{po otevření vybrat celý řádek, ne jen buňka}
  StatusBar1.Panels[0].Text:=Format(rsPoEtZZnam, [inttostr(ZQuery1.RecordCount)]);
  Dbgrid1.AutoSizeColumns; // aby se po zadání hodnoty přizpůsobil sloupec
end;

procedure TForm1.ZQuery1AfterScroll(DataSet: TDataSet);
begin
 wheelGridModification.dbAfterScroll;
end;

procedure TForm1.ZQuery1BeforeDelete(DataSet: TDataSet);
begin
 globalHistory.beforeDelete;
end;

procedure TForm1.ZQuery1BeforeEdit(DataSet: TDataSet);
begin
 globalHistory.beforeEdit;
end;

procedure TForm1.ZQuery1BeforePost(DataSet: TDataSet);
begin
 globalHistory.beforePost;
end;

procedure TForm1.ZQuery1BeforeScroll(DataSet: TDataSet);
begin
 wheelGridModification.dbBeforeScroll;
end;

procedure TForm1.ZQuery1PostError(DataSet: TDataSet; E: EDatabaseError;
  var DataAction: TDataAction);
begin
 E.Message:='Data nejdou uložit, pravděpodobně duplicitní položka';
 dataset.Cancel;
end;

procedure TForm1.UpdateTranslation(ALang: String);
begin
  inherited UpdateTranslation(ALang);
  Form1.DBGrid1.Columns.Items[0].Title.Caption:=rsName;
  Form1.DBGrid1.Columns.Items[1].Title.Caption:=rsSerieName;
  Form1.DBGrid1.Columns.Items[2].Title.Caption:=rsYear;
  Form1.DBGrid1.Columns.Items[3].Title.Caption:=rsSort;
  Form1.DBGrid1.Columns.Items[4].Title.Caption:=rsLocation;
  Form1.DBGrid1.Columns.Items[5].Title.Caption:=rsMedium;
  Form1.DBGrid1.Columns.Items[6].Title.Caption:=rsTotalEpisode;
  Form1.DBGrid1.Columns.Items[7].Title.Caption:=rsEpisodesOnDi;
  Form1.DBGrid1.Columns.Items[8].Title.Caption:=rsSeason;
  Form1.DBGrid1.Columns.Items[9].Title.Caption:=rsStubfile;
  Form1.DBGrid1.Columns.Items[10].Title.Caption:=rsDirectory;
  StatusBar1.Panels[0].Text:=rsPoEtZZnam0;
end;

procedure TForm1.FormCreate(Sender: TObject);  {Při vytvoření Form1 inicializuj}
var
 PomMenu : TMenuItem;
 i: Integer;

begin
 //SetDefaultLang('cs');
 //SplashAbout1.ShowSplash;
 DBGrid1.Columns.Items[0].Title.Caption:=rsName;
 DBGrid1.Columns.Items[1].Title.Caption:=rsSerieName;
 DBGrid1.Columns.Items[2].Title.Caption:=rsYear;
 DBGrid1.Columns.Items[3].Title.Caption:=rsSort;
 DBGrid1.Columns.Items[4].Title.Caption:=rsLocation;
 DBGrid1.Columns.Items[5].Title.Caption:=rsMedium;
 DBGrid1.Columns.Items[6].Title.Caption:=rsTotalEpisode;
 DBGrid1.Columns.Items[7].Title.Caption:=rsEpisodesOnDi;
 DBGrid1.Columns.Items[8].Title.Caption:=rsSeason;
 DBGrid1.Columns.Items[9].Title.Caption:=rsStubfile;
 DBGrid1.Columns.Items[10].Title.Caption:=rsDirectory;
 Form1.Caption:= 'Media Stub Kodi Creator  ';
 StatusBar1.Panels[0].Text:=rsPoEtZZnam0;
 //funkcionalita třídění po klinutí na záhlaví přenesena do unGridMod
  //GlobalSwitch:=true;          // was moved to unGridMod
  //minulyColumnTridici:=nil;    // was moved to unGridMod
 columnClickSorting.zquery:=ZQuery1;  {global object from unGridMod}
 pomColumnForNumFormatAdujstment:=nil; // pomocná proměnna pro unit10
 //---začátek-------objekty pro historii operací------
  //undoPolozky:=THistory.Create('Undo Buffer Items'); // was moved to unGridMod
  //redoPolozky:=THistory.Create('Redo Buffer Items'); // was moved to unGridMod
  //multiPolozkaHistorie:=False;                       // was moved to unGridMod
  //probihaUndo:=False;                                // was moved to unGridMod
  //probihaRedo:=False;                                // was moved to unGridMod
 //---konec---------objekty pro historii operací------
  globalHistory.dataSet:=ZQuery1;      {global history object from unHistory}
 // funkcionalita shift+click přenesena do unGridMod
  shiftSelectForGrid.dbgrid:=DBGrid1;   {global object from unGridMod}
 // funkcionalita modifikace chování ukazatel kolečka myši přenesena do unGridMod
  wheelGridModification.dbgrid:=DBGrid1; {global object from unGridMod}
 // funkcionalita scrapování přenesena do unGlobalScraper
  globalScraper.dbGrid:=DBGrid1; {global object from unGlobalScraper}
  globalScraper.zQuery:=ZQuery1; {global object from unGlobalScraper}
 {vytvoř položky menu  soubor - Otevřít nedávné ------ začátek}
 MenuItem5.Clear;
 PomMenu := TmenuItem.create(Self);
 HistoryFiles := Tstringlist.create;
 HistoryFiles.LoadFromfile('history.txt');
 for i:=0 to HistoryFiles.Count-1 do
  begin
    PomMenu := TmenuItem.create(Self);
    PomMenu.Caption :=SysToUTF8( HistoryFiles.Strings[i]);
    PomMenu.OnClick := @MojeOnClick;
    MenuItem5.Add(PomMenu);
  end;
 {vytvoř položky menu  soubor - Otevřít nedávné  ------ konec}

end;

procedure TForm1.FormDestroy(Sender: TObject);   {Při ukončení Form1 vykonej}
begin
  HistoryFiles.SaveToFile('history.txt');
end;

procedure TForm1.MenuItem12Click(Sender: TObject);  {popup menu Seriály }
var  PomS : string;                                 {Hromadná změna "Název seriálu"}
     I:byte;                                     {ZQuery1 je DataSet descendant}
begin

 {MessageDlg('Jméno sender je ... ' +
                                 (Sender as TMenuItem).Name,mtInformation, [mbOK, mbCancel],0);}

 PomS:=InputBox(rsHromadnZmNaN, rsNovNZev, 'DefaultEdit');
 if  PomS <> 'DefaultEdit' then
 begin
   for i:=0 to dbgrid1.SelectedRows.Count-1 do
   begin
    //Showmessage(ansiString(dbgrid1.SelectedRows.Items[i])+sLineBreak+IntToStr(i));
     ZQuery1.GotoBookmark(dbgrid1.SelectedRows.Items[i]);
    // ShowMessage(ZQuery1.FieldByName('Název').AsString +sLineBreak+
    //              ZQuery1.FieldByName('Druh').AsString );
     ZQuery1.Edit;
     ZQuery1.FieldByName('NAZEV_SERIALU').AsString:= PomS;
     ZQuery1.Post;  {Pouze podrží změny v dbgrid1-v paměti, neuloží je do databáze}
   end;
  //UlozZmenySQL;     {Uloží změny do databáze transakčně}
  //ZmenaVDatabazi := false    {vynulování změn základní tabulky }
 end;
end;

procedure TForm1.MenuItem13Click(Sender: TObject);  {popup menu Seriály }
var   I: byte;
  PomUm: String;
  Pom: Integer;
                                                    {Hromadná změna UMISTENI}
begin
 if  Form2.Showmodal = mrOK then
 begin
  for i:=0 to dbgrid1.SelectedRows.Count-1 do
   begin
     ZQuery1.GotoBookmark(dbgrid1.SelectedRows.Items[i]);
     Pom:=dbgrid1.SelectedRows.IndexOf(dbgrid1.SelectedRows.Items[i]);
     //Showmessage(inttostr(Pom));
     ZQuery1.Edit;
     if Form2.CheckBox1.Checked then
       begin
         PomUm:=inttostr(Form2.JLabeledIntegerEdit1.Value+i);
         if length(PomUm) =1 then PomUm:='00'+PomUm;
         if length(PomUm) =2 then PomUm:='0'+PomUm;
         ZQuery1.FieldByName('UMISTENI').AsString:= Form2.LabeledEdit1.Text+PomUm;
       end
                                 else
         ZQuery1.FieldByName('UMISTENI').AsString:= Form2.LabeledEdit1.Text;
         //ShowMessage(ZQuery1.FieldByName('NAZEV').AsString);
     ZQuery1.Post;
   end;
  //UlozZmenySQL;     {Uloží změny do databáze transakčně}
  // ZmenaVDatabazi := false    {vynulování změn základní tabulky }
 end;
end;

procedure TForm1.MenuItem14Click(Sender: TObject); {popup Seriály Vytvoř seriál }
begin
 NovySerial:=true;
 if  Form3.Showmodal = mrOK then
 begin
  DbGrid1.AutoSizeColumns;
 end;
end;

procedure TForm1.MenuItem1Click(Sender: TObject); {menu Soubor - viditelnost položek}
begin

 if  JmenoAktSoubor='' then
   begin
    MenuItem6.Enabled:=false;
    MenuItem7.Enabled:=false;
    MenuItem8.Enabled:=false;
   end
                       else
   begin
    MenuItem6.Enabled:=true;
    MenuItem7.Enabled:=true;
    MenuItem8.Enabled:=true;
   end;
end;

procedure TForm1.MenuItem17Click(Sender: TObject);{popup Seriály Hromadná změna- komplexní}
begin
 NovySerial:=false;
 if  Form3.Showmodal = mrOK then
  begin
  end;
end;

procedure TForm1.MenuItem19Click(Sender: TObject);    {popup Filmy Vytvoř film}
var
  Pom,I: Integer;
  PomPng: TBitmap;
begin
  PomPng:=TBitmap.Create;
  Form6.ImgListForm6.GetBitmap(1,PomPng);       { Ikonka pro Vytvoř film}
  Form6.Icon.Assign(PomPng);
  PomPng.Free;
  Form6.Caption:=rsVytvoFilm;
  I:=0;
  Form6.LabeledEdit1.Text:= '';
  Form6.LabeledEdit2.Text:= '';
  Form6.LabeledEdit3.Text:= '';
  Form6.StaticText1.Caption:='Stubfile';
  Form6.StaticText2.Caption:='Directory';
  Form6.indexSwitch:=true;   {použij index}
  repeat
   Form6.indexHodnota:=I;
   Pom:=Form6.ShowModal;
   if pom = mrCancel then Exit;
   ZQuery1.insert;
   ZQuery1.FieldByName('NAZEV').AsString:=Form6.LabeledEdit1.Text ;
   ZQuery1.FieldByName('ROK').AsString:=Form6.LabeledEdit2.Text ;
   ZQuery1.FieldByName('DRUH').AsString:= 'film';
   ZQuery1.FieldByName('UMISTENI').AsString:= Form6.LabeledEdit3.Text;
   ZQuery1.FieldByName('MEDIUM').AsString:=Form6.ComboBox1.Text;
   ZQuery1.FieldByName('STUBFILE').AsString:=Form6.StaticText1.Caption;
   ZQuery1.FieldByName('DIRECTORY').AsString:=Form6.StaticText2.Caption;
   ZQuery1.FieldByName('NAZEV_SERIALU').AsString:='';
   ZQuery1.FieldByName('DILY_CELKEM').AsString:= '';
   ZQuery1.FieldByName('DILY_NA_DISKU').AsString:= '';
   ZQuery1.FieldByName('SEZONA').AsString:= '';
   //try
     ZQuery1.Post;
     //except
     //  on E:Exception do
     //  begin
     //   ShowMessage('Duplicate item'); // přidat timer nebo nic nezobrazovat
     //   ZQuery1.Cancel;
     //  end;
     //end;
   I:=I+1;
  until pom = mrOK;
  Form6.indexSwitch:=false;  {zakaž index}
  Form6.indexBaze:=0;
  Form6.indexDefinovan:=false; {index není definován}
  Form6.umisteniStare:='';
  DbGrid1.AutoSizeColumns;
end;

procedure TForm1.MenuItem20Click(Sender: TObject);  {popup Filmy Hromadná změna "Umístění"}
begin
 MenuItem13.Click;
end;

procedure TForm1.MenuItem21Click(Sender: TObject);  {popup Filmy  Vytvoř stub soubory}
begin
  if  Form5.ShowModal = mrOK then
 begin
 end;
end;

procedure TForm1.MenuItem22Click(Sender: TObject);    {popup Filmy  Změň film (y)}
var
  Pom: Integer;
  I: Integer;
  PomPng:Tbitmap;
begin
  PomPng:=TBitmap.Create;
  Form6.ImgListForm6.GetBitmap(1,PomPng);       { Ikonka pro Změň film(y)}
  Form6.Icon.Assign(PomPng);
  PomPng.Free;
  Form6.Caption:=rsZmFilmY;
  I:=0;
  repeat
    ZQuery1.GotoBookmark(dbgrid1.SelectedRows.Items[i]);
    Form6.LabeledEdit1.Text:= ZQuery1.FieldByName('NAZEV').AsString;
    Form6.LabeledEdit2.Text:= ZQuery1.FieldByName('ROK').AsString;
    Form6.LabeledEdit3.Text:= ZQuery1.FieldByName('UMISTENI').AsString;
    Form6.ComboBox1.Text:= ZQuery1.FieldByName('MEDIUM').AsString;
    Form6.StaticText1.Caption:=Form6.LabeledEdit1.Text +'.disc';
    Form6.StaticText2.Caption:='\'+Form6.LabeledEdit1.Text+'('+Form6.LabeledEdit2.Text+')\';
     Pom:=Form6.ShowModal;
     if pom = mrCancel then Exit;
     ZQuery1.Edit;
     ZQuery1.FieldByName('NAZEV').AsString:=Form6.LabeledEdit1.Text ;
     ZQuery1.FieldByName('ROK').AsString:=Form6.LabeledEdit2.Text ;
     ZQuery1.FieldByName('DRUH').AsString:= 'film';
     ZQuery1.FieldByName('UMISTENI').AsString:= Form6.LabeledEdit3.Text;
     ZQuery1.FieldByName('MEDIUM').AsString:=Form6.ComboBox1.Text;
     ZQuery1.FieldByName('STUBFILE').AsString:=Form6.StaticText1.Caption;
     ZQuery1.FieldByName('DIRECTORY').AsString:=Form6.StaticText2.Caption;
     //ZQuery1.FieldByName('NAZEV_SERIALU').AsString:='';
     //ZQuery1.FieldByName('DILY_CELKEM').AsString:= '';
     //ZQuery1.FieldByName('DILY_NA_DISKU').AsString:= '';
     //ZQuery1.FieldByName('SEZONA').AsString:= '';
     ZQuery1.Post;
     I:=I+1;
  until (pom = mrOK) or (i>(DBGrid1.SelectedRows.Count-1));
end;

procedure TForm1.MenuItem23Click(Sender: TObject);
                                   {popup Filmy Hromadná tvorba "Stubfile"+"Directory"}
var
  i: Integer;
begin
  for i:=0 to dbgrid1.SelectedRows.Count-1 do
   begin
     ZQuery1.GotoBookmark(dbgrid1.SelectedRows.Items[i]);
     ZQuery1.Edit;
     ZQuery1.FieldByName('STUBFILE').AsString:=ZQuery1.FieldByName('NAZEV').AsString +'.disc';;
     ZQuery1.FieldByName('DIRECTORY').AsString:='\'+ZQuery1.FieldByName('NAZEV').AsString
                                                 +'('+ZQuery1.FieldByName('ROK').AsString+')\';
     ZQuery1.Post;
   end;
end;

procedure TForm1.MenuItem26Click(Sender: TObject); {popup Nástroje Import CSV}

begin
  OpenDialog1.FilterIndex:= 2;
  If OpenDialog1.Execute then
   begin
    SdfDataSet1.FileMustExist:=true;
    SdfDataSet1.FileName:=UTF8ToSys(OpenDialog1.FileName);
    SdfDataSet1.Active:=true;
    While not(SdfDataSet1.EOF) do
        begin
         ZQuery1.Insert;
         ZQuery1.FieldByName('NAZEV').AsString:= SdfDataSet1.FieldByName('Nazev').AsString;
         ZQuery1.FieldByName('NAZEV_SERIALU').AsString:=SdfDataSet1.FieldByName('Nazev_serialu').AsString;
         ZQuery1.FieldByName('ROK').AsString:=SdfDataSet1.FieldByName('Rok').AsString;
         ZQuery1.FieldByName('DRUH').AsString:=SdfDataSet1.FieldByName('Druh').AsString;
         ZQuery1.FieldByName('UMISTENI').AsString:=SdfDataSet1.FieldByName('Umisteni').AsString;
         ZQuery1.FieldByName('MEDIUM').AsString:=SdfDataSet1.FieldByName('Medium').AsString;
         ZQuery1.FieldByName('DILY_CELKEM').AsString:=SdfDataSet1.FieldByName('Dily_celkem').AsString;
         ZQuery1.FieldByName('DILY_NA_DISKU').AsString:=SdfDataSet1.FieldByName('Dily_na_disku').AsString;
         ZQuery1.FieldByName('SEZONA').AsString:=SdfDataSet1.FieldByName('Sezona').AsString;
         ZQuery1.FieldByName('STUBFILE').AsString:=SdfDataSet1.FieldByName('Stubfile').AsString;
         ZQuery1.FieldByName('DIRECTORY').AsString:=SdfDataSet1.FieldByName('Directory').AsString;
         try   // musí být zde protože v onPostError() se přeruší běh cyklu
         ZQuery1.Post;
         except
           on E:Exception do
           begin
            ShowMessage('Duplicate item: ' + LineEnding +
                        SdfDataSet1.FieldByName('NAZEV').AsString);
            // přidat timer nebo nic nezobrazovat,toť otázka :-)
            ZQuery1.Cancel;
            // odstranit položku historie s duplicitní hodnotou
            globalHistory.undoPolozky.historyVector.Back.polePolozek.PopBack;
           end;
         end;
         globalHistory.multiPolozkaHistorie:=True; // aby přidávalo do té samé položky historie THistoryItem;
         SdfDataSet1.Next;
        end;
    SdfDataSet1.Active:=False;
   end;
  globalHistory.multiPolozkaHistorie:=False; // je možnos přidávat další THistoryItem;
  OpenDialog1.FilterIndex:=1;
  dbgrid1.SelectedRows.Clear;
  dbgrid1.SelectedRows.CurrentRowSelected:=true;
  DbGrid1.AutoSizeColumns;
end;

procedure TForm1.MenuItem27Click(Sender: TObject);  {popup Nástroje Export CSV}
var
  i: Integer;

begin
  SaveDialog1.FilterIndex:=2;
  SaveDialog1.FileName:= ExtractFileNameOnly(JmenoAktSoubor);
  If SaveDialog1.Execute then
   begin
    SdfDataSet1.FileMustExist:=False;
    SdfDataSet1.FileName:=UTF8ToSys(SaveDialog1.FileName);
    SdfDataSet1.Active:=true;
    for i:=0 to DBGrid1.SelectedRows.Count-1 do
        begin
         ZQuery1.GotoBookmark(DBGrid1.SelectedRows.Items[i]);
         SdfDataSet1.append;
         SdfDataSet1.FieldByName('Nazev').AsString:=ZQuery1.FieldByName('NAZEV').AsString;
         SdfDataSet1.FieldByName('Nazev_serialu').AsString:=ZQuery1.FieldByName('NAZEV_SERIALU').AsString;
         SdfDataSet1.FieldByName('Rok').AsString:=ZQuery1.FieldByName('ROK').AsString;
         SdfDataSet1.FieldByName('Druh').AsString:=ZQuery1.FieldByName('DRUH').AsString;
         SdfDataSet1.FieldByName('Umisteni').AsString:=ZQuery1.FieldByName('UMISTENI').AsString;
         SdfDataSet1.FieldByName('Medium').AsString:=ZQuery1.FieldByName('MEDIUM').AsString;
         SdfDataSet1.FieldByName('Dily_celkem').AsString:=ZQuery1.FieldByName('DILY_CELKEM').AsString;
         SdfDataSet1.FieldByName('Dily_na_disku').AsString:=ZQuery1.FieldByName('DILY_NA_DISKU').AsString;
         SdfDataSet1.FieldByName('Sezona').AsString:=ZQuery1.FieldByName('SEZONA').AsString;
         SdfDataSet1.FieldByName('Stubfile').AsString:=ZQuery1.FieldByName('STUBFILE').AsString;
         SdfDataSet1.FieldByName('Directory').AsString:=ZQuery1.FieldByName('DIRECTORY').AsString;
         SdfDataset1.Post;
        end;
    SdfDataSet1.Active:=False;
   end;
  SaveDialog1.FilterIndex:=1;
  dbgrid1.SelectedRows.Clear;
  dbgrid1.SelectedRows.CurrentRowSelected:=true;
end;

procedure TForm1.MenuItem28Click(Sender: TObject); {popup Smaž výběr}
var
  i: Integer;
begin
  for i:=DBGrid1.SelectedRows.Count-1 downto 0  do
  begin
    ZQuery1.GotoBookmark(DBGrid1.SelectedRows.Items[i]);
    ZQuery1.Delete;
  end;
  ZQuery1.Refresh;                              // aby fungovaly bookmarky
  dbgrid1.SelectedRows.Clear;                   // a šlo ihned bez
  dbgrid1.SelectedRows.CurrentRowSelected:=true;// překliknutí mazat
  DBGrid1CellClick(Dbgrid1.SelectedColumn);  // aby šlo ihned vybírat pomocí SHIFT

end;

procedure TForm1.MenuItem29Click(Sender: TObject);   {popup Scrapuj výběr}

begin
  globalScraper.scrapujVyber;
end;

procedure TForm1.MenuItem24Click(Sender: TObject);{popup Seriály Označ seriál}
var
  PomS : String;
  PomB: Boolean;
begin
  PomB:=false;
  repeat
    PomS:= ZQuery1.FieldByName('NAZEV_SERIALU').AsString;
    ZQuery1.Prior;
    If (ZQuery1.BOF) and (PomS=ZQuery1.FieldByName('NAZEV_SERIALU').AsString) then break;
    If (PomS<>ZQuery1.FieldByName('NAZEV_SERIALU').AsString) then
      begin
       ZQuery1.Next;
       PomB:=true;
      end;
  until PomB;
  PomB:=false;
  repeat
    PomS:=ZQuery1.FieldByName('NAZEV_SERIALU').AsString;
    DBGrid1.SelectedRows.CurrentRowSelected:=true;
    ZQuery1.Next;
    If (ZQuery1.EOF) and (PomS=ZQuery1.FieldByName('NAZEV_SERIALU').AsString) then break;
    If (PomS<>ZQuery1.FieldByName('NAZEV_SERIALU').AsString) then
      begin
       ZQuery1.Prior;
       PomB:=true;
      end;
  until PomB;


end;

procedure TForm1.MenuItem15Click(Sender: TObject);     {popup menu Seriály }
var  PomS : string;                                 {Hromadná změna "Rok"}
     I: byte;
begin
 PomS:=InputBox(rsHromadnZmNaR, rsNovRok, 'DefaultEdit');
 if  PomS <> 'DefaultEdit' then
 begin
   for i:=0 to dbgrid1.SelectedRows.Count-1 do
   begin
     ZQuery1.GotoBookmark(dbgrid1.SelectedRows.Items[i]);
     ZQuery1.Edit;
     ZQuery1.FieldByName('ROK').AsString:= PomS;
     ZQuery1.Post;
   end;
  //UlozZmenySQL;     {Uloží změny do databáze transakčně}
  //ZmenaVDatabazi := false    {vynulování změn základní tabulky }
 end;
end;
procedure TForm1.MenuItem16Click(Sender: TObject);
                                         {popup Seriály Hromadná změna Vytvoř stub soubory}
begin
 if  Form5.ShowModal = mrOK then
 begin
 end;
end;



end.

