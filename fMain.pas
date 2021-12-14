unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ExtCtrls, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, Vcl.ComCtrls, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Bde.DBTables,
  FireDAC.Comp.DataMove;

type
  TfrmDMLArrayTest = class(TForm)
    panTop: TPanel;
    lblDMLArraySize: TLabel;
    edtDMLArraySize: TEdit;
    lblNoOfRecords: TLabel;
    edtNoOfRecords: TEdit;
    lblHeader: TLabel;
    butDeleteAllRows: TButton;
    butRunSingleTest: TButton;
    memLog: TMemo;
    butRunArraySizeTest: TButton;
    cbUseTransactions: TCheckBox;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDConnection1: TFDConnection;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    FDQuery1: TFDQuery;
    FDQuery2: TFDQuery;
    FDConnection2: TFDConnection;
    FDDataMove1: TFDDataMove;
    procedure butRunSingleTestClick(Sender: TObject);
    procedure butDeleteAllRowsClick(Sender: TObject);
    procedure butRunArraySizeTestClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FDDataMove1Progress(ASender: TObject; APhase: TFDDataMovePhase);
  private
    FADConnection: TFDConnection;
    FNoOfRecords: Integer;
    procedure PerformTest;
    procedure DeleteAllRows;
    procedure OpenConnection;
    procedure CloseConnection;
    procedure AddLog(AStr: string);
    function GetDMLArraySize: Integer;
    function GetNoOfRecords: Integer;
  public
    { Public declarations }
  end;

var
  frmDMLArrayTest: TfrmDMLArrayTest;

implementation


uses FireDAC.ConsoleUI.Wait,
  FireDAC.Phys.Oracle, FireDAC.Stan.Consts;

{$R *.dfm}

procedure TfrmDMLArrayTest.OpenConnection;
var
  cConDefName: string;
begin
  cConDefName := 'Sayat-PC';
  FDManager.Active := True;
  if FDManager.ConnectionDefs.FindConnectionDef(cConDefName) = nil then begin
    with FDManager.ConnectionDefs.AddConnectionDef do begin
      // This code works for ORACLE ... please change the parameters according to your environment.
      // See http://www.da-soft.com/anydac/docu/Database_Connectivity.html for details.
      Name := cConDefName;
      Server := cConDefName;
      DriverID := S_FD_MSSQLId;
      Database := 'GOKLOGO2009';
      UserName := 'sa';
      Password := 'cracker';
    end;
  end;
  FADConnection := TFDConnection.Create(nil);
  FADConnection.ConnectionDefName := cConDefName;
  FADConnection.Connected := True;
end;

procedure TfrmDMLArrayTest.AddLog(AStr: string);
begin
  memLog.Lines.Add(AStr);
end;

procedure TfrmDMLArrayTest.CloseConnection;
begin
  FreeAndNil(FADConnection);
end;

function TfrmDMLArrayTest.GetDMLArraySize: Integer;
begin
  Result := StrToInt(edtDMLArraySize.Text);
end;

function TfrmDMLArrayTest.GetNoOfRecords: Integer;
begin
  Result := StrToInt(edtNoOfRecords.Text);
end;

procedure TfrmDMLArrayTest.butDeleteAllRowsClick(Sender: TObject);
begin
  OpenConnection;
  try
    DeleteAllRows;
  finally
    CloseConnection;
  end;
end;

procedure TfrmDMLArrayTest.butRunSingleTestClick(Sender: TObject);
var
  d1, d2: TDateTime;
begin
  FNoOfRecords := GetNoOfRecords;
  OpenConnection;
  try
    d1 := Now;
    PerformTest;
  finally
    CloseConnection;
  end;
  d2 := Now - d1;
  AddLog('DML Array Size: ' + IntToStr(GetDMLArraySize) + ' -> ' +
    TimeToStr(d2) + ' for ' + IntToStr(FNoOfRecords) + ' Recs -> ' +
    FloatToStr(FNoOfRecords / (d2 * 86400)) + ' per second');
end;

procedure TfrmDMLArrayTest.Button1Click(Sender: TObject);
var
  d1, d2: TDateTime;
begin
  FDConnection2.Connected := True;
  ProgressBar1.Max := 500000;
  FNoOfRecords := 500000;
  OpenConnection;
  try
    d1 := Now;
    FDConnection2.StartTransaction;
    FDDataMove1.CommitCount := FNoOfRecords;
//    FDConnection1.StartTransaction;
    FDDataMove1.Execute;
    FDConnection2.Commit;
//    FDConnection1.Commit;
  finally
    CloseConnection;
  end;
  d2 := Now - d1;
  FNoOfRecords := 500000;
  AddLog('Batch Move: ' + IntToStr(GetDMLArraySize) + ' -> ' +
    TimeToStr(d2) + ' for ' + IntToStr(FNoOfRecords) + ' Recs -> ' +
    FloatToStr(FNoOfRecords / (d2 * 86400)) + ' per second');
  FDConnection2.Connected := False;
end;

procedure TfrmDMLArrayTest.PerformTest;
var
  oADQuery: TFDQuery;
  iRecTest, iRecArray: Integer;
begin
  oADQuery := TFDQuery.Create(nil);
  try
    ProgressBar1.Position := 0;
    ProgressBar1.Max := FNoOfRecords;
    oADQuery.Connection := FADConnection;
    // write your own table information here
    oADQuery.SQL.Text := 'insert into LK_002_CRMCART (CARTREF, CARTNO, PRICETYPE, GROUPCODE) values(:f1, :f2, :f3, :f4) ';
    oADQuery.Params.ArraySize := GetDMLArraySize;
    // record index in the test
    iRecTest := 0;
    // record index in a current array
    iRecArray := 0;
    // define size of the parameter (in order that not a default size is assumed for the transport)
    oADQuery.Params[1].Size := 20;
    while iRecTest < FNoOfRecords do begin
      Application.ProcessMessages;
      ProgressBar1.Position := iRecTest;
      oADQuery.Params[0].AsIntegers[iRecArray] := iRecTest;
      oADQuery.Params[1].AsStrings[iRecArray] := 'Test' + IntToStr(iRecTest);
      oADQuery.Params[2].AsIntegers[iRecArray] := 1;
      oADQuery.Params[3].AsStrings[iRecArray] := 'GrpCode' + IntToStr(iRecTest);
      inc(iRecTest);
      Inc(iRecArray);
      // execute the command for a next array
      if (iRecArray >= oADQuery.Params.ArraySize - 1) or (iRecTest = FNoOfRecords) then begin
        if (oADQuery.Params.ArraySize > 1) and cbUseTransactions.Checked then
          FADConnection.StartTransaction;
        try
          oADQuery.Execute(iRecArray);
        finally
          if (oADQuery.Params.ArraySize > 1) and cbUseTransactions.Checked then
            FADConnection.Commit;
        end;
        // reset the record index in an array to zero
        iRecArray := 0;
      end;
    end;
  finally
    oADQuery.Free;
  end;
end;

procedure TfrmDMLArrayTest.butRunArraySizeTestClick(Sender: TObject);
var
  iLoop: Integer;
begin
  for iLoop := 0 to 9 do begin
    butDeleteAllRowsClick(nil);
    case iLoop of
      0: edtDMLArraySize.Text := '1';
      1: edtDMLArraySize.Text := '2';
      2: edtDMLArraySize.Text := '5';
      3: edtDMLArraySize.Text := '10';
      4: edtDMLArraySize.Text := '50';
      5: edtDMLArraySize.Text := '100';
      6: edtDMLArraySize.Text := '500';
      7: edtDMLArraySize.Text := '1000';
      8: edtDMLArraySize.Text := '5000';
      9: edtDMLArraySize.Text := '10000';
    end;
    butRunSingleTestClick(nil);
  end;
end;

procedure TfrmDMLArrayTest.DeleteAllRows;
begin
  FADConnection.ExecSQL('TRUNCATE TABLE LK_002_CRMCART');
  AddLog('all records deleted from the test table');
end;

procedure TfrmDMLArrayTest.FDDataMove1Progress(ASender: TObject;
  APhase: TFDDataMovePhase);
begin
  memLog.Lines.Add('2- ' + (ASender as TFDDataMove).InsertCount.ToString());
  ProgressBar1.Position := (ASender as TFDDataMove).InsertCount;
end;

end.
