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

unit se.game.script.package;

interface

uses
  VerySimple.Lua, VerySimple.Lua.Lib;

type
  TScriptPackage = class abstract
  private
    FName: string;
    FLuaState: Lua_State;
  protected
    /// <summary>
    ///   ע�ắ��
    /// </summary>
    /// <param name="ANativeMethodName">
    ///   Delphi������
    /// </param>
    /// <param name="ALuaMethodName">
    ///   Lua������
    /// </param>
    procedure RegFunction(const ANativeMethodName, ALuaMethodName: string);
    /// <summary>
    ///   ע�����к���
    /// </summary>
    /// <remark>
    ///   ������󷽷�������ʵ��
    /// </remark>
    procedure RegFunctions; virtual; abstract;
    /// <summary>
    ///   ����Lua�еĹ�������
    /// </summary>
    /// <param name="ALuaMethodName">
    ///   Lua������
    /// </param>
    /// <param name="AMsgcode">
    ///   ��Ϣ����(Integer)
    /// </param>
    /// <param name="AData">
    ///   ����(string)
    /// </param>
    procedure InvokeLuaMethod(const ALuaMethodName: string;
      const AMsgcode: Integer; const AData: string); overload;
    /// <summary>
    ///   ����Lua�еĹ�������
    /// </summary>
    /// <param name="ALuaMethodName">
    ///   Lua������
    /// </param>
    /// <param name="AData">
    ///   ����(string)
    /// </param>
    procedure InvokeLuaMethod(const ALuaMethodName: string;
      const AMsgcode: Integer); overload;
    procedure InvokeLuaMethod(const ALuaMethodName: string;
      const AData: string); overload;
  public
    /// <summary>
    ///   �����ط���
    /// </summary>
    /// <remark>
    ///   ������Public����Published
    /// </remark>
    function LoadPackage: Integer; virtual;
    /// <summary>
    ///   ����
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    ///   Lua�ű�������
    /// </summary>
    property LuaState: Lua_State read FLuaState write FLuaState;
  end;

  TScriptPackageClass = class of TScriptPackage;

implementation

{ TScriptPackage }

procedure TScriptPackage.RegFunction(const ANativeMethodName,
  ALuaMethodName: string);
begin
  TVerySimpleLua.PushFunction(FLuaState, Self, MethodAddress(ANativeMethodName), ALuaMethodName);
  lua_rawset(FLuaState, -3);
end;

function TScriptPackage.LoadPackage: Integer;
begin
  lua_newtable(FLuaState);
  RegFunctions;
  result:= 1;
end;

procedure TScriptPackage.InvokeLuaMethod(const ALuaMethodName: string;
  const AMsgcode: Integer; const AData: string);
var
  LError: Integer;
begin
  lua_getglobal(FLuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  lua_pushinteger(FLuaState, AMsgcode);
  lua_pushstring(FLuaState, MarshaledAString(UTF8String(AData)));
  LError:= lua_pcall(FLuaState, 2, 0, 0);
end;

procedure TScriptPackage.InvokeLuaMethod(const ALuaMethodName: string;
  const AMsgcode: Integer);
var
  LError: Integer;
begin
  lua_getglobal(FLuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  lua_pushinteger(FLuaState, AMsgcode);
  LError:= lua_pcall(FLuaState, 1, 0, 0);
end;

procedure TScriptPackage.InvokeLuaMethod(const ALuaMethodName, AData: string);
var
  LError: Integer;
begin
  lua_getglobal(FLuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  lua_pushstring(FLuaState, MarshaledAString(UTF8String(AData)));
  LError:= lua_pcall(FLuaState, 1, 0, 0);
end;

end.
