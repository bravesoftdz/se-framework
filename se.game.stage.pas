{******************************************************************************}
{                                                                              }
{       SE Network Development Framework                                       }
{                                                                              }
{       Copyright (c) 2018 looper(2031056602@qq.com)                           }
{                                                                              }
{       Source: https://github.com/looper/se-framework                         }
{       Homepage: http://www.asphyre.cn                                        }
{                                                                              }
{******************************************************************************}

unit se.game.stage;

interface

uses
  System.Classes, System.SysUtils, System.UITypes, System.Math,
  FMX.Forms, FMX.Dialogs,
  PXL.Types, PXL.Timing, PXL.Devices, PXL.Canvas, PXL.Providers, PXL.FMBridge,
  se.utils.client, se.game.types, se.game.helper, se.game.assetsmanager,
  se.game.script, se.game.script.package, se.game.sprite, se.game.window,
  se.game.scene;

type
  TGameStage = class
  private
    FForm: TForm;
    FBridge: TFMBridge;
    FDeviceProvider: TGraphicsDeviceProvider;
    FDevice: TCustomDevice;
    FCanvas: TCustomCanvas;
    FMultiTimer: TMultimediaTimer;
    FTicks: Integer;
    FDisplaySize: TPoint2i;
    FOnUpdate, FOnRender: TNotifyEvent;
    procedure EngineTiming(const Sender: TObject);
    procedure EngineProcess(const Sender: TObject);
    procedure RenderScene;
    function GetScreenScale: Single;
    function GetFullDeviceTechString: string;
    function GetFrameRate: Integer;
  private
    procedure DoPrint(AMsg: string);
    procedure DoErrorPrint(AMsg: string);
  private
    /// <remark>
    ///   ��Դ����
    /// </remark>
    FAssetsRoot: string;
    FAssetsMode: TAssetsModes;
    FAssetsType: TAssetsTypes;
    procedure SetAssetsType(const Value: TAssetsTypes);
    procedure SetAssetsMode(const Value: TAssetsModes);
    procedure SetAssetsRoot(const Value: string);
  private
    /// <remark>
    ///   �ű�ϵͳ(LUA)
    /// </remark>
    FScriptSystem: TScriptSystem;
    FScriptRoot: string;
    procedure SetScriptRoot(const Value: string);
    function GetScriptPackage(const Name: string): TScriptPackage;
  private
    /// <remark>
    ///   ���������
    /// </remark>
    FSpriteManager: TSpriteManager;
  private
    /// <remark>
    ///   ����������
    /// </remark>
    FSceneManager: TSceneManager;
  private
    /// <remark>
    ///   ���ڹ�����
    /// </remark>
    FWindowFactory: TWindowFactory;
  private
    /// <remark>
    ///   ��־
    /// </remark>
    FLogs: TStrings;
    function GetLogs: TArray<string>;
  public
    constructor Create(const AForm: TForm);
    destructor Destroy; override;

    /// <summary>
    ///   ��ʱ
    /// </summary>
    procedure NotifyTick;
    /// <summary>
    ///   ��Ⱦ���ڴ�С�����ı�ʱ�����������ˢ����Ļ�������
    /// </summary>
    procedure Resize;
    /// <summary>
    ///   ע��ű���
    /// </summary>
    function RegScriptPackage(const AClass: TScriptPackageClass;
      const AName: string): TScriptPackage;
    /// <summary>
    ///   �ӽű�����
    /// </summary>
    procedure DriveWithScript(const ALuaFile, AInitRunEnvironmentMethodName,
      AStartMethodName: string);
    /// <summary>
    ///   ����ָ������
    /// </summary>
    function RunWith(const AScene: TSceneData): Boolean;
  public
    /// <summary>
    ///   ���ݸ����¼�
    /// </summary>
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
    /// <summary>
    ///   ��Ⱦ�¼�
    /// </summary>
    property OnRender: TNotifyEvent read FOnRender write FOnRender;
    /// <summary>
    ///   ����, PXL�Ļ���
    /// </summary>
    property Canvas: TCustomCanvas read FCanvas;
    /// <summary>
    ///   ��ʾ��С, ����Ҫ��Ⱦ�������С
    /// </summary>
    property DisplaySize: TPoint2i read FDisplaySize;
    /// <summary>
    ///   ��Ļ����, winƽ̨һ����1.0, �ƶ�ƽ̨����ݷֱ��ʽ��м���
    /// </summary>
    property ScreenScale: Single read GetScreenScale;
    /// <summary>
    ///   ������׼(DX or OpenGL...)
    /// </summary>
    property FullDeviceTechString: string read GetFullDeviceTechString;
    /// <summary>
    ///   FPS
    /// </summary>
    property FrameRate: Integer read GetFrameRate;
  public
    /// <summary>
    ///   ��Դ����, �����TAssetsType����
    /// </summary>
    property AssetsType: TAssetsTypes read FAssetsType write SetAssetsType;
    /// <summary>
    ///   ��Դ����ģʽ, �����TAssetsMode����
    /// </summary>
    property AssetsMode: TAssetsModes read FAssetsMode write SetAssetsMode;
    /// <summary>
    ///   ��Դ�ļ��ĸ�Ŀ¼
    /// </summary>
    property AssetsRoot: string read FAssetsRoot write SetAssetsRoot;
  public
    /// <summary>
    ///   �ű��ļ��ĸ�Ŀ¼
    /// </summary>
    property ScriptRoot: string read FScriptRoot write SetScriptRoot;
    /// <summary>
    ///   ��ȡ�ű���
    /// </summary>
    property ScriptPackage[const Name: string]: TScriptPackage read GetScriptPackage;
  public
    /// <summary>
    ///   ���������
    /// </summary>
    property SpriteManager: TSpriteManager read FSpriteManager;
  public
    /// <summary>
    ///   ����������
    /// </summary>
    property SceneManager: TSceneManager read FSceneManager;
  public
    /// <summary>
    ///   ���ڹ�����
    /// </summary>
    property WindowFactory: TWindowFactory read FWindowFactory;
  public
    /// <summary>
    ///   Log
    /// </summary>
    property Logs: TArray<string> read GetLogs;
  end;

implementation

{ TGameStage }

constructor TGameStage.Create(const AForm: TForm);
begin
  inherited Create;
  FLogs:= TStringList.Create;
  FTicks:= 0;
  FAssetsRoot:= '';
  FAssetsType:= [atTTF, atPng, atJpg, atOgg, atScene, atLayout];
  FAssetsMode:= [TAssetsMode.amNormal];
  //
  if AForm = nil then
  begin
    MessageDlg('Owner form cannot be null.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Application.Terminate;
    Exit;
  end;
  FForm:= AForm;
  //
  FBridge:= TFMBridge.Create;
  FDeviceProvider:= FBridge.CreateProvider;
  //
  FDevice:= FDeviceProvider.CreateDevice;
  if (FDevice is TCustomStateDevice) and (not TCustomStateDevice(FDevice).Initialize) then
  begin
    MessageDlg('Failed to initialize PXL Device.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Application.Terminate;
    Exit;
  end;
  //
  FCanvas:= FDeviceProvider.CreateCanvas(FDevice);
  if not FCanvas.Initialize then
  begin
    MessageDlg('Failed to initialize PXL Canvas.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Application.Terminate;
    Exit;
  end;
  //
  FMultiTimer:= TMultimediaTimer.Create;
  FMultiTimer.OnTimer  := EngineTiming;
  FMultiTimer.OnProcess:= EngineProcess;
  FMultiTimer.MaxFPS:= 4000;
  //
  AssetsManager.Canvas:= FCanvas;
  AssetsManager.OnPrint:= DoPrint;
  //
  FScriptSystem:= TScriptSystem.Create;
  FScriptSystem.OnPrint:= DoPrint;
  FScriptSystem.OnError:= DoErrorPrint;
  //
  FSpriteManager:= TSpriteManager.Create(AForm);
  FSpriteManager.Canvas:= FCanvas;
  FSpriteManager.OnPrint:= DoPrint;
  //
  FSceneManager:= TSceneManager.Create(FSpriteManager);
  FSceneManager.OnPrint:= DoPrint;
  //
  FWindowFactory:= TWindowFactory.Create;
  FWindowFactory.OwnerForm:= AForm;
  FWindowFactory.OnPrint:= DoPrint;
  //
  Self.Resize;
end;

destructor TGameStage.Destroy;
begin
  FreeAndNil(FMultiTimer);
  FreeAndNil(FScriptSystem);
  FreeAndNil(FSpriteManager);
  FreeAndNil(FSceneManager);
  FreeAndNil(FWindowFactory);
  FreeAndNil(FCanvas);
  FreeAndNil(FDevice);
  FreeAndNil(FDeviceProvider);
  FreeAndNil(FBridge);
  FreeAndNil(FLogs);
  inherited;
end;

procedure TGameStage.EngineProcess(const Sender: TObject);
begin
  Inc(FTicks);
  FSpriteManager.Move(1);
  FSpriteManager.Dead;
  if Assigned(FOnUpdate) then FOnUpdate(Sender);
end;

procedure TGameStage.EngineTiming(const Sender: TObject);
begin
  if FCanvas.BeginScene then
  try
    FCanvas.Device.Clear([TClearType.Color], IntColorWhite);
    RenderScene;
    FMultiTimer.Process;
  finally
    FCanvas.EndScene;
  end;
end;

procedure TGameStage.RenderScene;
begin
  FSpriteManager.Render;
  if Assigned(FOnRender) then FOnRender(nil);
  FCanvas.Flush;
end;

procedure TGameStage.NotifyTick;
begin
  FMultiTimer.NotifyTick;
end;

procedure TGameStage.Resize;
begin
  TClientUtils.SetMainForm(FForm);
{$IFDEF MSWINDOWS}
  FDisplaySize:= Point2i(Round(FForm.ClientWidth  * TClientUtils.ScreenScale),
                         Round(FForm.ClientHeight * TClientUtils.ScreenScale));
//  FWindowFactory.Resize(Min(FDisplaySize.X/960, FDisplaySize.Y/540));
{$ELSE}
  FDisplaySize.X:= TClientUtils.PhysicalScreenSize.cx;
  FDisplaySize.Y:= TClientUtils.PhysicalScreenSize.cy;
{$ENDIF}
  FSpriteManager.Resize(FDisplaySize.X, FDisplaySize.Y);
end;

function TGameStage.RunWith(const AScene: TSceneData): Boolean;
begin
  if not Assigned(AScene) then
    Exit(False);
  Result:= FSceneManager.Switch(AScene);
end;

function TGameStage.GetScreenScale: Single;
begin
  Result:= TClientUtils.ScreenScale;
end;

function TGameStage.GetScriptPackage(const Name: string): TScriptPackage;
begin
  Result:= FScriptSystem.Package[Name];
end;

function TGameStage.GetFullDeviceTechString: string;
begin
  Result:= PXL.Devices.GetFullDeviceTechString(FDevice);
end;

function TGameStage.GetFrameRate: Integer;
begin
  Result:= FMultiTimer.FrameRate;
end;

procedure TGameStage.SetAssetsMode(const Value: TAssetsModes);
begin
  if FAssetsMode <> Value then
  begin
    FAssetsMode:= Value;
    if FAssetsRoot <> '' then
      AssetsManager.Mapping(FAssetsRoot, FAssetsType, FAssetsMode);
  end;
end;

procedure TGameStage.SetAssetsType(const Value: TAssetsTypes);
begin
  if FAssetsType <> Value then
  begin
    FAssetsType:= Value;
    if FAssetsRoot <> '' then
      AssetsManager.Mapping(FAssetsRoot, FAssetsType, FAssetsMode);
  end;
end;

procedure TGameStage.SetAssetsRoot(const Value: string);
begin
  if FAssetsRoot <> Value then
  begin
    FAssetsRoot:= Value;
    AssetsManager.Mapping(FAssetsRoot, FAssetsType, FAssetsMode);
  end;
end;

procedure TGameStage.SetScriptRoot(const Value: string);
begin
  if FScriptRoot <> Value then
  begin
    FScriptRoot:= Value;
    FScriptSystem.FilePath:= IncludeTrailingPathDelimiter(FScriptRoot);
  end;
end;

function TGameStage.GetLogs: TArray<string>;
begin
  Result:= FLogs.ToStringArray;
end;

procedure TGameStage.DoPrint(AMsg: string);
begin
  FLogs.Add('[INFO] ' + AMsg);
end;

procedure TGameStage.DoErrorPrint(AMsg: string);
begin
  FLogs.Add('[ERROR] ' + AMsg);
end;

function TGameStage.RegScriptPackage(const AClass: TScriptPackageClass;
  const AName: string): TScriptPackage;
begin
  Result:= FScriptSystem.RegPackage(AClass, AName);
end;

procedure TGameStage.DriveWithScript(const ALuaFile, AInitRunEnvironmentMethodName,
  AStartMethodName: string);
begin
  FScriptSystem.Run(ALuaFile, AInitRunEnvironmentMethodName, AStartMethodName);
end;

end.