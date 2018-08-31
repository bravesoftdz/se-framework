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
    procedure RegPackage(const AClass: TScriptPackageClass; const AName: string);
    /// <summary>
    ///   ִ��ĳ��lua�ű��ļ�
    /// </summary>
    /// <param name="ASetPackagePathMethodName">
    ///   lua������package.path�ķ�����, ����������������ұ����ǹ�������
    /// </param>
    /// <param name="AInitModuleMethodName">
    ///   lua��require����ģ��ķ�����, ����������������ұ����ǹ�������
    /// </param>
    /// <remark>
    ///   ���ֻ��������ʱ����һ��
    /// </remark>
    procedure Run(const AFileName, ASetPackagePathMethodName,
      AInitModuleMethodName: string);
  end;

implementation

{ TScriptSystem }

procedure TScriptSystem.InvokeLuaMethod(const ALuaMethodName, AData: string);
var
  LError: Integer;
begin
  lua_getglobal(Self.LuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  lua_pushstring(Self.LuaState, MarshaledAString(UTF8String(AData)));
  LError:= lua_pcall(Self.LuaState, 1, 0, 0);
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

procedure TScriptSystem.InvokeLuaMethod(const ALuaMethodName: string);
var
  LError: Integer;
begin
  lua_getglobal(Self.LuaState, MarshaledAString(UTF8String(ALuaMethodName)));
  LError:= lua_pcall(Self.LuaState, 0, 0, 0);
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

procedure TScriptSystem.RegPackage(const AClass: TScriptPackageClass; const AName: string);
var
  LPackage: TScriptPackage;
  LIndex: Integer;
begin
  if AName = '' then Exit;
  LPackage:= AClass.Create;
  LPackage.Name:= AName;
  LIndex:= IndexOfPackageName(AName);
  if LIndex >= 0 then FPackageList.Delete(LIndex);
  FPackageList.Add(LPackage);
end;

procedure TScriptSystem.Run(const AFileName, ASetPackagePathMethodName,
  AInitModuleMethodName: string);
begin
  Self.DoFile(AFileName);
  InvokeLuaMethod(ASetPackagePathMethodName, Self.FilePath);
  InvokeLuaMethod(AInitModuleMethodName);
end;

end.