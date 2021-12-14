object frmDMLArrayTest: TfrmDMLArrayTest
  Left = 0
  Top = 0
  BorderWidth = 7
  Caption = 'Array DML Test'
  ClientHeight = 439
  ClientWidth = 790
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object panTop: TPanel
    Left = 0
    Top = 0
    Width = 790
    Height = 133
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 754
    object lblDMLArraySize: TLabel
      Left = 16
      Top = 53
      Width = 69
      Height = 13
      Caption = 'DML ArraySize'
    end
    object lblNoOfRecords: TLabel
      Left = 17
      Top = 80
      Width = 68
      Height = 13
      Caption = 'No of Records'
    end
    object lblHeader: TLabel
      Left = 16
      Top = 16
      Width = 162
      Height = 13
      Caption = 'Input for the DML Array Test'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDMLArraySize: TEdit
      Left = 120
      Top = 50
      Width = 81
      Height = 21
      TabOrder = 0
      Text = '100'
    end
    object edtNoOfRecords: TEdit
      Left = 120
      Top = 75
      Width = 81
      Height = 21
      TabOrder = 1
      Text = '100000'
    end
    object butDeleteAllRows: TButton
      Left = 416
      Top = 44
      Width = 105
      Height = 25
      Caption = 'Delete all Rows'
      TabOrder = 2
      OnClick = butDeleteAllRowsClick
    end
    object butRunSingleTest: TButton
      Left = 264
      Top = 44
      Width = 113
      Height = 25
      Caption = 'Run Single Test'
      TabOrder = 3
      OnClick = butRunSingleTestClick
    end
    object butRunArraySizeTest: TButton
      Left = 264
      Top = 75
      Width = 113
      Height = 25
      Caption = 'Run Array Size Test'
      TabOrder = 4
      OnClick = butRunArraySizeTestClick
    end
    object cbUseTransactions: TCheckBox
      Left = 16
      Top = 104
      Width = 185
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Use Transactions'
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 5
    end
    object ProgressBar1: TProgressBar
      Left = 28
      Top = 1
      Width = 717
      Height = 17
      TabOrder = 6
    end
    object Button1: TButton
      Left = 416
      Top = 75
      Width = 105
      Height = 25
      Caption = 'Batch Move'
      TabOrder = 7
      OnClick = Button1Click
    end
  end
  object memLog: TMemo
    Left = 0
    Top = 133
    Width = 790
    Height = 306
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    Ctl3D = False
    Lines.Strings = (
      'Log of the Test Run ...')
    ParentCtl3D = False
    ScrollBars = ssBoth
    TabOrder = 1
    ExplicitWidth = 754
    ExplicitHeight = 193
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 560
    Top = 24
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrHourGlass
    Left = 600
    Top = 24
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=GOKLOGO2009'
      'User_Name=sa'
      'Password=cracker'
      'Server=Sayat-pc'
      'DriverID=MSSQL')
    Connected = True
    LoginPrompt = False
    Left = 520
    Top = 72
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 376
    Top = 176
  end
  object DataSource2: TDataSource
    DataSet = FDQuery2
    Left = 376
    Top = 208
  end
  object FDQuery1: TFDQuery
    Active = True
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems, evRowsetSize, evCache, evUnidirectional]
    FetchOptions.Unidirectional = True
    FetchOptions.RowsetSize = 100
    FetchOptions.Items = [fiBlobs, fiDetails]
    FetchOptions.Cache = []
    SQL.Strings = (
      'SELECT CODE  AS CUSTCARDNO,'
      '       NAME  AS NAME_'
      'FROM   LK_002_CRMCUSTOMER'
      'WHERE  LOGICALREF >= 136886')
    Left = 408
    Top = 176
  end
  object FDQuery2: TFDQuery
    Connection = FDConnection2
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmManual
    FetchOptions.Items = [fiMeta]
    UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvRefreshMode, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable]
    UpdateOptions.UpdateChangedFields = False
    UpdateOptions.RefreshMode = rmManual
    UpdateOptions.CheckRequired = False
    UpdateOptions.CheckReadOnly = False
    UpdateOptions.CheckUpdatable = False
    SQL.Strings = (
      'SELECT CUSTCARDNO,'
      '       NAME_'
      'FROM   CLNT_CUSTOMER')
    Left = 408
    Top = 208
  end
  object FDConnection2: TFDConnection
    Params.Strings = (
      'Database=MPOSSUBE'
      'User_Name=sa'
      'Password=test123'
      'Server=Sayat-pc'
      'DriverID=MSSQL')
    Connected = True
    LoginPrompt = False
    Left = 520
    Top = 104
  end
  object FDDataMove1: TFDDataMove
    TextDataDef.Fields = <>
    TextFileName = 'Data.txt'
    Mappings = <
      item
        SourceFieldName = 'CUSTCARDNO'
        DestinationFieldName = 'CUSTCARDNO'
      end
      item
        SourceFieldName = 'NAME_'
        DestinationFieldName = 'NAME_'
      end>
    Options = [poOptimiseDest, poOptimiseSrc, poClearDestNoUndo, poAbortOnExc, poIdentityInsert]
    LogFileName = 'Data.log'
    CommitCount = 0
    Source = FDQuery1
    Destination = FDQuery2
    OnProgress = FDDataMove1Progress
    Left = 520
    Top = 184
  end
end
