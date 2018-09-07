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

unit se.game.script;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  VerySimple.Lua, VerySimple.Lua.Lib, se.game.script.package;

type
  TScriptSystem = class(TVerySimpleLua)
  private
    /// <summary>
    ///   ���б�
    /// </summary>
    FPackageList: TObjectList<TScriptPackage>;
    /// <summary>
    ///   ���ݰ�����ȡ���б��е�����
    /// </summary>
    function IndexOfPackageName(const AName: string): Integer;
    /// <summary>
    ///   ����Lua�еķ���, ��������
    /// </summary>
    procedure InvokeLuaMethod(const ALuaMethodName: string;
      const AData1, AData2: string); overload;
    /// <summary>
    ///   ����Lua�еķ���, һ������
    /// </summary>
    procedure InvokeLuaMethod(const ALuaMethodName: string;
      const AData: string); overload;
    /// <summary>
    ///   ����Lua�еķ���, �޲���
    /// </summary>
    procedure InvokeLuaMethod(const ALuaMethodName: string); overload;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    ///   �����������ע�������
    /// </summary>
    procedure Open; override;
    /// <summary>
    ///   ���⿪�ŵİ�ע�᷽��, ʵ����ֻ�ǰѰ����뵽FPackageList��
    ///   �������Ŀǰ������Run֮ǰ���ò���Ч
    /// </summary>
    function RegPackage(const AClass: TScriptPackageClass;
      const AName: string): TScriptPackage;
    /// <summary>
    ///   ִ��ĳ��lua�ű��ļ�
    /// </summary>
    /// <param name="AInitRunEnvironmentMethodName">
    ///   1������������package.path
    ///   2�������lua������require����ģ��
    ///   3������������������ұ����ǹ�������
    /// </param>
    /// <param name="AStartMethodName">
    ///   ������ڷ�����, ����������������ұ����ǹ�������
    /// </param>
    /// <remark>
    ///   ���ֻ��������ʱ����һ��
    /// </remark>
    procedure Run(const AFileName, AInitRunEnvironmentMethodName,
      AStartMethodName: string);
  end;

implementation

{ TScriptSystem }

procedure TScriptSystem.InvokeLuaMethod(const ALuaMethodName, AData1, AData2: string);
var
  LError: Integer;
begin
  lua_getglobal(Self.LuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  lua_pushstring(Self.LuaState, MarshaledAString(UTF8String(AData1)));
  lua_pushstring(Self.LuaState, MarshaledAString(UTF8String(AData2)));
  LError:= lua_pcall(Self.LuaState, 2, 0, 0);
end;

procedure TScriptSystem.InvokeLuaMethod(const ALuaMethodName, AData: string);
var
  LError: Integer;
begin
  lua_getglobal(Self.LuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  lua_pushstring(Self.LuaState, MarshaledAString(UTF8String(AData)));
  LError:= lua_pcall(Self.LuaState, 1, 0, 0);
end;

procedure TScriptSystem.InvokeLuaMethod(const ALuaMethodName: string);
var
  LError: Integer;
begin
  lua_getglobal(Self.LuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  LError:= lua_pcall(Self.LuaState, 0, 0, 0);
end;

constructor TScriptSystem.Create;
begin
  inherited Create;
  FPackageList:= TObjectList<TScriptPackage>.Create;
end;

destructor TScriptSystem.Destroy;
begin
  FreeAndNil(FPackageList);
  inherited;
end;

function TScriptSystem.IndexOfPackageName(const AName: string): Integer;
var
  I: Integer;
begin
  Result:= -1;
  for I:= 0 to FPackageList.Count -1 do
    if FPackageList[I].Name = AName then
      Exit(I);
end;

procedure TScriptSystem.Open;
var
  I: Integer;
begin
  inherited;
  for I:= 0 to FPackageList.Count -1 do
  begin
    FPackageList[I].LuaState:= Self.LuaState;
    RegisterPackage(FPackageList[I].Name, FPackageList[I], 'LoadPackage');
  end;
end;

function TScriptSystem.RegPackage(const AClass: TScriptPackageClass;
  const AName: string): TScriptPackage;
var
  LIndex: Integer;
begin
  if AName = '' then Exit(nil);
  Result:= AClass.Create;
  Result.Name:= AName;
  LIndex:= IndexOfPackageName(AName);
  if LIndex >= 0 then FPackageList.Delete(LIndex);
  FPackageList.Add(Result);
end;

procedure TScriptSystem.Run(const AFileName, AInitRunEnvironmentMethodName,
  AStartMethodName: string);
begin
  Self.DoFile(AFileName);
  InvokeLuaMethod(AInitRunEnvironmentMethodName, Self.FilePath, Self.LibraryPath);
  InvokeLuaMethod(AStartMethodName);
end;

end.