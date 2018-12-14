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

unit se.game.script.package.ui;

interface

uses
  System.Classes, System.SysUtils, FMX.Forms, FMX.Controls,
  VerySimple.Lua, VerySimple.Lua.Lib,
  se.game.types, se.game.script.package, se.game.window, se.game.sprite, se.game.scene;

type
  TUIPackage = class(TScriptPackage)
  private
    FWindowFactory: TWindowFactory;
    FSpriteManager: TSpriteManager;
    FSceneManager : TSceneManager;
  private
    /// <summary>
    ///   ע��ָ������ĵ���¼�
    /// </summary>
    procedure RegisterSpriteClickEvent(const ASpriteName: string;
      const AMsgcode: Integer);
    /// <summary>
    ///   �������¼�
    /// </summary>
    procedure DoSpriteClick(Sender: TObject);
    /// <summary>
    ///   FMX�ؼ�����¼�
    /// </summary>
    procedure DoControlClick(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure RegFunctions; override;
    /// <summary>
    ///   ע��һ������ʵ����WindowFactory
    /// </summary>
    function RegWindow(const AName: string; AWindow: TWindow): Boolean; overload;
    /// <summary>
    ///   ע��һ������ʵ����WindowFactory(ͨ�����������ļ�)
    /// </summary>
    function RegWindow(const AFileName: string): Boolean; overload;
    /// <summary>
    ///   ���ڹ�����
    /// </summary>
    property WindowFactory: TWindowFactory read FWindowFactory write FWindowFactory;
    /// <summary>
    ///   ���������
    /// </summary>
    property SpriteManager: TSpriteManager read FSpriteManager write FSpriteManager;
    /// <summary>
    ///   ����������
    /// </summary>
    property SceneManager: TSceneManager read FSceneManager write FSceneManager;
  published
    /// <summary>
    ///   ע�ᴰ����ָ���ؼ��ĵ���¼�
    /// </summary>
    function registerClickEvent(L: lua_State): Integer;
    /// <summary>
    ///   ��ʾ����
    /// </summary>
    function showWindow(L: lua_State): Integer;
    /// <summary>
    ///   �رմ���
    /// </summary>
    function closeWindow(L: lua_State): Integer;
    /// <summary>
    ///   �л�����
    /// </summary>
    function switchScene(L: lua_State): Integer;
  end;

implementation

{ TUIPackage }

constructor TUIPackage.Create;
begin
  inherited;

end;

destructor TUIPackage.Destroy;
begin

  inherited;
end;

procedure TUIPackage.DoControlClick(Sender: TObject);
begin
  if Sender is TControl then
    Self.InvokeLuaMethod('execClick', TControl(Sender).Tag);
end;

procedure TUIPackage.DoSpriteClick(Sender: TObject);
begin
  if Sender is TCustomSprite then
    Self.InvokeLuaMethod('execClick', TCustomSprite(Sender).Tag);
end;

procedure TUIPackage.RegFunctions;
begin
  inherited;
  RegFunction('registerClickEvent','registerClickEvent');
  RegFunction('showWindow','showWindow');
  RegFunction('closeWindow','closeWindow');
  RegFunction('switchScene','switchScene');
end;

function TUIPackage.RegWindow(const AName: string; AWindow: TWindow): Boolean;
begin
  AWindow.Parent:= FWindowFactory.OwnerForm;
  AWindow.OnControlClick:= DoControlClick;
  Result:= FWindowFactory.RegWindow(AName, AWindow);
end;

function TUIPackage.RegWindow(const AFileName: string): Boolean;
var
  LWindow: TWindow;
begin
  LWindow:= TWindow.Create(nil, AFileName);
  Result:= Self.RegWindow(LWindow.Name, LWindow);
end;

procedure TUIPackage.RegisterSpriteClickEvent(const ASpriteName: string;
  const AMsgcode: Integer);
var
  LSprite: TCustomSprite;
begin
  LSprite:= FSpriteManager.Sprite[ASpriteName];
  if Assigned(LSprite) then
  begin
    LSprite.Tag:= AMsgcode;
    LSprite.OnClick:= DoSpriteClick;
  end;
end;

function TUIPackage.registerClickEvent(L: lua_State): Integer;
var
  LFormName, LControlName: string;
  LMsgcode: Integer;
begin
  LFormName:= lua_tostring(L, 2);
  LControlName:= lua_tostring(L, 3);
  LMsgcode:= lua_tointeger(L, 4);
  //
  if Assigned(FWindowFactory.OwnerForm) and
     Assigned(FSpriteManager) and
     LFormName.Equals(FWindowFactory.OwnerForm.Name) then
    RegisterSpriteClickEvent(LControlName, LMsgcode)
  else
    FWindowFactory.RegisterClickEvent(LFormName, LControlName, LMsgcode);
  //
  Result:= 0;
end;

function TUIPackage.showWindow(L: lua_State): Integer;
var
  LFormName: string;
begin
  LFormName:= lua_tostring(L, 2);
  FWindowFactory.Show(LFormName);
  Result:= 0;
end;

function TUIPackage.closeWindow(L: lua_State): Integer;
var
  LFormName: string;
begin
  LFormName:= lua_tostring(L, 2);
  FWindowFactory.Close(LFormName);
  Result:= 0;
end;

function TUIPackage.switchScene(L: lua_State): Integer;
var
  LSceneName: string;
begin
  LSceneName:= lua_tostring(L, 2);
  FSceneManager.Switch(LSceneName);
  Result:= 0;
end;

end.
