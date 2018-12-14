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

unit se.game.tiled.map;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  XSuperObject,
  PXL.Types;

type
  TTexture = record

  end;

  TTileTexSet = record

  end;

  TTileSet = record

  end;

  TSprite = record

  end;

  TMapLayer = record

  end;

  TJsonLoader = record

  end;

  TTextureLoader = record

  end;

  TTiledMap = class
  public const
    /// <summary>
    ///   ��ͼ֧�ֵ�����(Ŀǰ֧���ı��Σ����Σ�������)
    /// </summary>
    /// <remark>
    ///   ORIENTATION_ORTHOGONAL   �ı��ε�ͼ
    ///   ORIENTATION_ISOMETRIC    ���ε�ͼ
    ///   ORIENTATION_STAGGERED    45�Ƚ����ͼ
    ///   ORIENTATION_HEXAGONAL    �����ε�ͼ
    /// </remark>
		ORIENTATION_ORTHOGONAL: string = 'orthogonal';
		ORIENTATION_ISOMETRIC : string = 'isometric';
		ORIENTATION_STAGGERED : string = 'staggered';
		ORIENTATION_HEXAGONAL : string = 'hexagonal';
    /// <summary>
    ///   ��ͼ����(tile)����Ⱦ˳��
    /// </summary>
    /// <remark>
    ///   RENDERORDER_RIGHTDOWN   �����Ͻǿ�ʼ��Ⱦ
    ///   RENDERORDER_RIGHTUP     �����½ǿ�ʼ��Ⱦ
    ///   RENDERORDER_LEFTDOWN    �����Ͻǿ�ʼ��Ⱦ
    ///   RENDERORDER_LEFTUP      �����½ǿ�ʼ��Ⱦ
    /// </remark>
		RENDERORDER_RIGHTDOWN : string = 'right-down';
		RENDERORDER_RIGHTUP   : string = 'right-up';
		RENDERORDER_LEFTDOWN  : string = 'left-down';
		RENDERORDER_LEFTUP    : string = 'left-up';
  private
		//json����
		_jsonData: ISuperObject;

		//��ŵ�ͼ���õ�����������������
		_tileTexSetArr: TStack<TTileTexSet>;

		//���������ݣ���Ҫ���ͷ�������Դʱʹ��
		_texArray: TStack<TTexture>;

		//��ͼ��Ϣ�е�һЩ��������
		_x       : Single;  //��ͼ������X
		_y       : Single;  //��ͼ������Y
		_width   : Integer; //��ͼ�Ŀ��
		_height  : Integer; //��ͼ�ĸ߶�
		_mapW    : Integer; //��ͼ�ĺ��������
		_mapH    : Integer; //��ͼ�����������
		_mapTileW: Integer; //tile�Ŀ��
		_mapTileH: Integer; //tile�ĸ߶�


		_rect: TIntRect; //������ŵ�ͼ���ӿ���Ϣ
		_paddingRect: TIntRect;  //������ŵ�ͼ���ӿ���������
		_mapSprite: TSprite; //��ͼ����ʾ����
		_layerArray: TStack<TMapLayer>; //���ﱣ�����е�MapLayer����
		_renderLayerArray: TStack<TMapLayer>;//���ﱣ����Ҫ��Ⱦ��MapLayer����
		_gridArray: array of array of Integer; //�������еĿ�����

		//��ͼ����ص�
		_showGridKey   : Boolean; //�Ƿ���ʾ��߽��ߣ����������ã�
		_totalGridNum  : Integer; //һ���е�GridSprite������
		_gridW         : Integer; //��ͼ�ĺ������
		_gridH         : Integer; //��ͼ�ļ������
		_gridWidth     : Single;  //���Ĭ�Ͽ��
		_gridHeight    : Single;  //���Ĭ�ϸ߶�

		_jsonLoader: TJsonLoader; //��������JSON�ļ��õ�LOADER
		_loader: TTextureLoader;  //�����������������õ�LOADER
		_tileSetArray: TStack<TTileSet>; //������Ż���Ҫ��Щ������ȴ�����
		_currTileSet: TTileSet; //���ڼ��ص�������Ҫ������Դ
		_completeHandler: TNotifyEvent; //��ͼ������ɵĻص�����
		//�����ü���������е�ǰ�ӿں��ϴ��ӿ���ʾ���ٵĿ飬������Щ������Ҫ��ʾ������
		_mapRect:GRect = new GRect(); //��ǰ�ӿ���ʾ�Ŀ鷶Χ
		_mapLogicRect:GRect = new GRect(); //��ǰ�ӿ���ʾ�ķ�Χ
		_mapLastRect:GRect = new GRect(); //�ϴ��ӿ���ʾ�Ŀ鷶Χ
		_index:int = 0;
		_animationDic:Object = {}; //��Ҫ�����Ķ�������
		_properties:*; //��ǰ��ͼ���Զ�������
		_tileProperties:Object = { }; //ͼ������
		_tileProperties2:Object = { };
		//Ĭ�ϵĵ�ͼ���ͣ�����Ҫ��JSON�ļ���
		_orientation:String = "orthogonal";
		//Ĭ�ϵ�tile��Ⱦ˳�򣨾���Ҫ��JSON�ļ���
		_renderOrder:String = "right-down";
		//�����õ���ɫ���
		_colorArray: array of string = ('FF', '00', '33', '66');
		//������صĲ���
		_scale: Single = 1;
		_pivotScaleX: Single = 0.5;
		_pivotScaleY: Single = 0.5;
		_centerX: Single = 0;
		_centerY: Single = 0;
  public
		_viewPortX: Single = 0;
		_viewPortY: Single = 0;
		_viewPortWidth: Single = 0;
		_viewPortHeight: Single = 0;
		//�Ƿ�������ȡ��
		_enableLinear:Boolean = true;
		//��Դ�����·��
		_resPath:String;
		_pathArray:Array;
		//�ѵ�ͼ��������ʾ����
		_limitRange:Boolean = false;
		//���ٸ���ģʽ�Ƿ񲻿���
		_fastDirty:Boolean = true;
		//�Ƿ��Զ�����û�ж����ĵؿ�
		autoCache:Boolean = true;
		//�Զ���������,��ͼ�ϴ�ʱ����ʹ��normal
		autoCacheType: string = 'normal';
		//�Ƿ�ϲ�ͼ��,�����ϲ�ͼ��ʱ��ͼ�������ڿ����layer���ԣ�����ʱ���Ὣ���ڵ�layer������ͬ��ͼ����кϲ����������
		enableMergeLayer:Boolean = false;
		//�Ƿ��Ƴ������ǵĸ���,�ؿ�����type���ԣ�type��Ϊ0ʱ��ʾ��͸��������͸���ؿ��ڵ��ĵؿ齫�ᱻ�޳����������
		removeCoveredTile:Boolean = false;
		//�Ƿ���ʾ���������ʾ����ͼ����
		showGridTextureCount:Boolean = false;
		//�Ƿ�����ؿ��Ե�������ŵ��µķ�϶
		antiCrack:Boolean = true;
		//�Ƿ��ڼ������֮��cache���д����
		cacheAllAfterInit:Boolean = false;
  public
    constructor Create;
    destructor Destroy; override;

		/// <summary>
		///   ������ͼ
    /// </summary>
    /// <params>
    ///   @param	mapName 		JSON�ļ�����
    ///   @param	viewRect 		�ӿ�����
    ///   @param	completeHandler ��ͼ������ɵĻص�����
    ///   @param	viewRectPadding �ӿ��������򣬰��ӿ������ϡ��¡���������һ�£���ֹ�ӿ��ƶ�ʱ�Ĵ���
    ///   @param	gridSize 		grid��С
    ///   @param	enableLinear 	�Ƿ�������ȡ����Ϊfalseʱ�����Խ����ͼ���ߵ����⣬�����ʻ��񻯣�
    ///   @param	limitRange		�ѵ�ͼ��������ʾ����
    /// <params>
		function createMap(const mapName: string;
                       const viewRect: TIntRect;
                       const completeHandler: TNotifyEvent;
                       const viewRectPadding: TIntRect;
                       const gridSize: TPoint2i;
                       const enableLinear: Boolean = True;
                       const limitRange: Boolean = False): Boolean;
  end;

implementation

{ TTiledMap }

constructor TTiledMap.Create;
begin
  inherited;
  _x       := 0;
  _y       := 0;
  _width   := 0;
  _height  := 0;
  _mapW    := 0;
  _mapH    := 0;
  _mapTileW:= 0;
  _mapTileH:= 0;

  _showGridKey:= False;
  _totalGridNum:= 0;
  _gridW:= 0;
  _gridH:= 0;
  _gridWidth:= 450;
  _gridHeight:= 450;


end;

destructor TTiledMap.Destroy;
begin

  inherited;
end;

function TTiledMap.createMap(const mapName: string; const viewRect: TIntRect;
  const completeHandler: TNotifyEvent; const viewRectPadding: TIntRect;
  const gridSize: TPoint2i; const enableLinear, limitRange: Boolean): Boolean;
begin
  _enableLinear = enableLinear;
  _limitRange = limitRange;
  _rect.x = viewRect.x;
  _rect.y = viewRect.y;
  _rect.width = viewRect.width;
  _rect.height = viewRect.height;
  _viewPortWidth = viewRect.width / _scale;
  _viewPortHeight = viewRect.height / _scale;
  _completeHandler = completeHandler;
  if (viewRectPadding) {
    _paddingRect.copyFrom(viewRectPadding);
  }
  else {
    _paddingRect.setTo(0, 0, 0, 0);
  }
  if (gridSize) {
    _gridWidth = gridSize.x;
    _gridHeight = gridSize.y;
  }
  var tIndex:int = mapName.lastIndexOf("/");
  if (tIndex > -1) {
    _resPath = mapName.substr(0, tIndex);
    _pathArray = _resPath.split("/");
  }
  else {
    _resPath = "";
    _pathArray = [];
  }

  _jsonLoader = new Loader();
  _jsonLoader.once("complete", this, onJsonComplete);
  _jsonLoader.load(mapName, Loader.JSON, false);
end;

end.
