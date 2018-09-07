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

unit se.game.window;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.UITypes, System.UIConsts, System.Generics.Defaults,
  FMX.Types, FMX.Objects, FMX.Ani, FMX.Controls, FMX.Graphics, FMX.Forms,
  se.game.window.style;

type
  TWindow = class(TRectangle)
  private
    FOnControlClick: TNotifyEvent;
    procedure RegisterClickEvent(const AControl: string; const AMsgcode: Integer);
  protected
    FControlMap: TObjectDictionary<string, TControl>;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    /// <summary>
    ///   ���ô�С
    /// </summary>
    procedure Resize(const AScale: Single);
    /// <summary>
    ///   ��ʾ
    /// </summary>
    procedure ShowMe;  virtual;
    /// <summary>
    ///   ����
    /// </summary>
    procedure HideMe; virtual;
    /// <summary>
    ///   �����еĿؼ�����¼�
    /// </summary>
    property OnControlClick: TNotifyEvent read FOnControlClick write FOnControlClick;
  end;

  TWindowFactory = class
  private
    FOwnerForm: TForm;
    FMask: TRectangle;
    FWindowMap: TObjectDictionary<string, TWindow>;
    procedure SetOwnerForm(const Value: TForm);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    ///   ���ô�С
    /// </summary>
    procedure Resize(const AScale: Single);
    /// <summary>
    ///   ע��һ������ʵ��
    /// </summary>
    function RegWindow(const AName: string; AWindow: TWindow): Boolean;
    /// <summary>
    ///   ���ڴ���,һ�㴫��������Application.MainForm
    /// </summary>
    property OwnerForm: TForm read FOwnerForm write SetOwnerForm;
  public
    /// <summary>
    ///   ע�ᴰ����ָ���ؼ��ĵ���¼�
    /// </summary>
    /// <param name="AWindowName">
    ///   ��������
    /// </param>
    /// <param name="AControlName">
    ///   �ؼ�����
    /// </param>
    /// <param name="AMsgcode">
    ///   ��������Ϣ����
    /// </param>
    procedure RegisterClickEvent(const AWindowName, AControlName: string;
      const AMsgcode: Integer);
    /// <summary>
    ///   ��ʾ����
    /// </summary>
    procedure ShowWindow(const AWindowName: string);
    /// <summary>
    ///   �رմ���
    /// </summary>
    procedure CloseWindow(const AWindowName: string);
  end;

implementation

{ TWindow }

constructor TWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FControlMap:= TObjectDictionary<string, TControl>.Create([doOwnsValues]);
  Self.Opacity:= 0;
  Self.Width:= 320;
  Self.Height:= 240;
  Self.Align:= TAlignLayout.Center;
  Self.Fill.Kind:= TBrushKind.Bitmap;
  Self.Stroke.Kind:= TBrushKind.None;
end;

destructor TWindow.Destroy;
begin
  FreeAndNil(FControlMap);
  inherited;
end;

procedure TWindow.RegisterClickEvent(const AControl: string;
  const AMsgcode: Integer);
var
  LControl: TControl;
begin
  if FControlMap.TryGetValue(AControl, LControl) then
  begin
    LControl.OnClick:= FOnControlClick;
    LControl.Tag:= AMsgcode;
  end;
end;

procedure TWindow.Resize(const AScale: Single);
begin
  Self.Scale.X:= AScale;
  Self.Scale.Y:= AScale;
end;

procedure TWindow.ShowMe;
begin
  Self.Visible:= True;
  Self.BringToFront;
  TAnimator.AnimateFloat(Self, 'Opacity', 1.0, 1.0);
end;

procedure TWindow.HideMe;
begin
  Self.Visible:= False;
end;

{ TWindowFactory }

constructor TWindowFactory.Create;
begin
  inherited Create;
  FOwnerForm:= nil;
  FWindowMap:= TObjectDictionary<string, TWindow>.Create([doOwnsValues]);
  FMask:= TRectangle.Create(nil);
  FMask.Align:= TAlignLayout.Contents;
  FMask.Fill.Color:= claBlack;
  FMask.Stroke.Kind:= TBrushKind.None;
  FMask.Opacity:= 0.5;
  FMask.Visible:= False;
end;

destructor TWindowFactory.Destroy;
begin
  FreeAndNil(FMask);
  FreeAndNil(FWindowMap);
  inherited;
end;

procedure TWindowFactory.Resize(const AScale: Single);
var
  LPair: TPair<string,TWindow>;
begin
  for LPair in FWindowMap do
    LPair.Value.Resize(AScale);
end;

procedure TWindowFactory.SetOwnerForm(const Value: TForm);
begin
  FOwnerForm:= Value;
  FMask.Parent:= FOwnerForm;
end;

function TWindowFactory.RegWindow(const AName: string; AWindow: TWindow): Boolean;
begin
  if AName.IsEmpty then
  begin
    if Assigned(AWindow) then
      FreeAndNil(AWindow);
    Exit(False);
  end;
  if not Assigned(AWindow) then
    Exit(False);
  //
  AWindow.Visible:= False;
  FWindowMap.AddOrSetValue(AName, AWindow);
  Result:= True;
end;

procedure TWindowFactory.RegisterClickEvent(const AWindowName,
  AControlName: string; const AMsgcode: Integer);
var
  LWindow: TWindow;
begin
  if FWindowMap.TryGetValue(AWindowName, LWindow) then
    LWindow.RegisterClickEvent(AControlName, AMsgcode);
end;

procedure TWindowFactory.ShowWindow(const AWindowName: string);
var
  LWindow: TWindow;
begin
  if FWindowMap.TryGetValue(AWindowName, LWindow) then
  begin
    FMask.Visible:= True;
    LWindow.ShowMe;
  end;
end;

procedure TWindowFactory.CloseWindow(const AWindowName: string);
var
  LWindow: TWindow;
begin
  if FWindowMap.TryGetValue(AWindowName, LWindow) then
  begin
    LWindow.HideMe;
    FMask.Visible:= False;
  end;
end;

end.
