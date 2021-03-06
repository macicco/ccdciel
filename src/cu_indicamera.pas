unit cu_indicamera;

{$mode objfpc}{$H+}

{
Copyright (C) 2015 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. 

}

// {$define camera_debug}

interface

uses cu_camera, indibaseclient, indibasedevice, indiapi, indicom,
     u_global, math, ExtCtrls, Classes, SysUtils, LCLType, u_translation;

type

T_indicamera = class(T_camera)
private
   indiclient: TIndiBaseClient;
   InitTimer: TTimer;
   ConnectTimer: TTimer;
   CCDDevice: Basedevice;
   CCDport: ITextVectorProperty;
   CCDexpose: INumberVectorProperty;
   CCDexposeValue: INumber;
   CCDbinning: INumberVectorProperty;
   CCDbinX,CCDbinY: INumber;
   CCDframe: INumberVectorProperty;
   CCDframeX,CCDframeY,CCDframeWidth,CCDframeHeight: INumber;
   CCDframeReset: ISwitchVectorProperty;
   CCDFrameType: ISwitchVectorProperty;
   FrameLight, FrameBias, FrameDark,FrameFlat: ISwitch;
   CCDCompression: ISwitchVectorProperty;
   CCDcompress, CCDraw: ISwitch;
   CCDAbortExposure: ISwitchVectorProperty;
   CCDAbort: ISwitch;
   CCDCooler: ISwitchVectorProperty;
   CCDCoolerOn,CCDCoolerOff: ISwitch;
   CCDTemperature: INumberVectorProperty;
   CCDinfo: INumberVectorProperty;
   CCDmaxx,CCDmaxy,CCDpixelsize,CCDpixelsizex,CCDpixelsizey,CCDbitperpixel : INumber;
   CCDColorSpace: ISwitchVectorProperty;
   CCDColorGray,CCDColorRGB: ISwitch;
   CCDVideoStream: ISwitchVectorProperty;
   VideoStreamOn,VideoStreamOff: ISwitch;
   RecordOptions: INumberVectorProperty;
   RecordOptionDuration,RecordOptionFrames: INumber;
   RecordFile: ITextVectorProperty;
   RecordFileDir,RecordFilename: IText;
   RecordStream: ISwitchVectorProperty;
   RecordStreamOn,RecordStreamOff,RecordDuration,RecordFrames: ISwitch;
   CCDVideoSize:ISwitchVectorProperty;
   CCDVideoRates:ISwitchVectorProperty;
   VideoFPS: INumberVectorProperty;
   FPSest,FPSavg: INumber;
   ImageAdjustments: INumberVectorProperty;
   IBrightness,IGamma,IGain,IExposure:INumber;
   StreamOptions: INumberVectorProperty;
   StreamRate:INumber;
   CCDIso: ISwitchVectorProperty;

   Guiderexpose: INumberVectorProperty;
   GuiderexposeValue: INumber;
   Guiderbinning: INumberVectorProperty;
   GuiderbinX,GuiderbinY: INumber;
   GuiderCompression: ISwitchVectorProperty;
   Guidercompress, Guiderraw: ISwitch;
   GuiderAbortExposure: ISwitchVectorProperty;
   GuiderAbort: ISwitch;
   Guiderinfo: INumberVectorProperty;
   Guidermaxx,Guidermaxy,Guiderpixelsize,Guiderpixelsizex,Guiderpixelsizey,Guiderbitperpixel : INumber;
   WheelSlot: INumberVectorProperty;
   Slot: INumber;
   FilterName: ITextVectorProperty;
   ActiveDevices: ITextVectorProperty;
   UploadMode: ISwitchVectorProperty;
   UploadClient, UploadLocal, UploadBoth: ISwitch;
   UploadSettings: ITextVectorProperty;
   UploadDir, UploadPrefix: IText;
   CCDfilepath: ITextVectorProperty;
   configprop: ISwitchVectorProperty;
   configload,configsave: ISwitch;
   FhasBlob,Fready,Fconnected,UseMainSensor: boolean;
   Findiserver, Findiserverport, Findidevice, Findisensor, Findideviceport: string;
   FVideoMsg: boolean;
   lockvideostream:boolean;
   procedure CreateIndiClient;
   procedure InitTimerTimer(Sender: TObject);
   procedure ConnectTimerTimer(Sender: TObject);
   procedure ClearStatus;
   procedure CheckStatus;
   procedure NewDevice(dp: Basedevice);
   procedure NewMessage(mp: IMessage);
   procedure NewProperty(indiProp: IndiProperty);
   procedure NewNumber(nvp: INumberVectorProperty);
   procedure NewText(tvp: ITextVectorProperty);
   procedure NewSwitch(svp: ISwitchVectorProperty);
   procedure NewLight(lvp: ILightVectorProperty);
   procedure NewBlob(bp: IBLOB);
   procedure DeleteDevice(dp: Basedevice);
   procedure DeleteProperty(indiProp: IndiProperty);
   procedure ServerConnected(Sender: TObject);
   procedure ServerDisconnected(Sender: TObject);
   procedure LoadConfig;
 protected
   function GetBinX:integer; override;
   function GetBinY:integer; override;
   procedure SetFrametype(f:TFrameType); override;
   function  GetFrametype:TFrameType; override;
   function GetBinXrange:TNumRange; override;
   function GetBinYrange:TNumRange; override;
   function GetExposureRange:TNumRange; override;
   function GetTemperatureRange:TNumRange; override;
   procedure SetFilter(num:integer); override;
   function  GetFilter:integer; override;
   procedure SetFilterNames(value:TStringList); override;
   function  GetTemperature: double; override;
   procedure SetTemperature(value:double); override;
   function  GetCooler: boolean; override;
   procedure SetCooler(value:boolean); override;
   function GetMaxX: double; override;
   function GetMaxY: double; override;
   function GetMaxADU: double; override;
   function GetPixelSize: double; override;
   function GetPixelSizeX: double; override;
   function GetPixelSizeY: double; override;
   function GetBitperPixel: double; override;
   function GetColor: boolean;  override;
   procedure SetTimeout(num:integer); override;
   function GetVideoPreviewRunning: boolean;  override;
   function GetMissedFrameCount: cardinal; override;
   function GetVideoRecordDuration:integer; override;
   procedure SetVideoRecordDuration(value:integer); override;
   function GetVideoRecordFrames:integer; override;
   procedure SetVideoRecordFrames(value:integer); override;
   function GetVideoSize:string; override;
   procedure SetVideoSize(value:string); override;
   function GetVideoRate:string;override;
   procedure SetVideoRate(value:string); override;
   function GetFPS:double; override;
   function GetVideoRecordDir:string; override;
   procedure SetVideoRecordDir(value:string); override;
   function GetVideoRecordFile:string; override;
   procedure SetVideoRecordFile(value:string); override;
   function GetVideoExposure:integer; override;
   function GetVideoGain:integer; override;
   function GetVideoGamma:integer; override;
   function GetVideoBrightness:integer; override;
   procedure SetVideoExposure(value:integer); override;
   procedure SetVideoGain(value:integer); override;
   procedure SetVideoGamma(value:integer); override;
   procedure SetVideoBrightness(value:integer); override;
   function GetVideoExposureRange:TNumRange; override;
   function GetVideoGainRange:TNumRange; override;
   function GetVideoGammaRange:TNumRange; override;
   function GetVideoBrightnessRange:TNumRange; override;
   function GetVideoPreviewDivisor:integer; override;
   procedure SetVideoPreviewDivisor(value:integer); override;
   procedure SetGain(value: integer); override;
   function GetGain: integer; override;

 public
   constructor Create(AOwner: TComponent);override;
   destructor  Destroy; override;
   Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string=''); override;
   Procedure Disconnect; override;
   Procedure StartExposure(exptime: double); override;
   Procedure SetBinning(sbinX,sbinY: integer); override;
   procedure SetFrame(x,y,width,height: integer); override;
   procedure GetFrame(out x,y,width,height: integer); override;
   procedure GetFrameRange(out xr,yr,widthr,heightr: TNumRange); override;
   procedure ResetFrame; override;
   function  CheckGain:boolean; override;
   Procedure AbortExposure; override;
   Procedure SetActiveDevices(afocuser,afilters,atelescope: string); override;
   procedure StartVideoPreview; override;
   procedure StopVideoPreview; override;
   procedure StartVideoRecord(mode:TVideoRecordMode); override;
   procedure StopVideoRecord; override;
end;

implementation

procedure T_indicamera.CreateIndiClient;
begin
if csDestroying in ComponentState then exit;
  indiclient:=TIndiBaseClient.Create;
  indiclient.Timeout:=FTimeOut;
  indiclient.onNewDevice:=@NewDevice;
  indiclient.onNewMessage:=@NewMessage;
  indiclient.onNewProperty:=@NewProperty;
  indiclient.onNewNumber:=@NewNumber;
  indiclient.onNewText:=@NewText;
  indiclient.onNewSwitch:=@NewSwitch;
  indiclient.onNewLight:=@NewLight;
  indiclient.onNewBlob:=@NewBlob;
  indiclient.onDeleteDevice:=@DeleteDevice;
  indiclient.onDeleteProperty:=@DeleteProperty;
  indiclient.onServerConnected:=@ServerConnected;
  indiclient.onServerDisconnected:=@ServerDisconnected;
  {$ifdef camera_debug}
  indiclient.ProtocolTrace:=true;
  indiclient.ProtocolRawFile:='/tmp/ccdciel_indicamera.raw';
  indiclient.ProtocolTraceFile:='/tmp/ccdciel_indicamera.log';
  indiclient.ProtocolErrorFile:='/tmp/ccdciel_indicamera.err';
  {$endif}
  ClearStatus;
end;

constructor T_indicamera.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FCameraInterface:=INDI;
 FVerticalFlip:=true;
 ClearStatus;
 Findiserver:='localhost';
 Findiserverport:='7624';
 Findidevice:='';
 Findisensor:='';
 Findideviceport:='';
 InitTimer:=TTimer.Create(nil);
 InitTimer.Enabled:=false;
 InitTimer.Interval:=60000;
 InitTimer.OnTimer:=@InitTimerTimer;
 ConnectTimer:=TTimer.Create(nil);
 ConnectTimer.Enabled:=false;
 ConnectTimer.Interval:=3000;
 ConnectTimer.OnTimer:=@ConnectTimerTimer;
 CreateIndiClient;
 lockvideostream:=false;
 FVideoMsg:=false;
end;

destructor  T_indicamera.Destroy;
begin
 InitTimer.Enabled:=false;
 ConnectTimer.Enabled:=false;
 indiclient.onServerDisconnected:=nil;
 indiclient.Free;
 FreeAndNil(InitTimer);
 FreeAndNil(ConnectTimer);
 inherited Destroy;
end;

procedure T_indicamera.ClearStatus;
begin
    CCDDevice:=nil;
    CCDport:=nil;
    CCDexpose:=nil;
    CCDbinning:=nil;
    CCDframe:=nil;
    CCDframeReset:=nil;
    CCDFrameType:=nil;
    CCDCompression:=nil;
    CCDAbortExposure:=nil;
    CCDColorSpace:=nil;
    CCDVideoStream:=nil;
    RecordOptions:=nil;
    RecordFile:=nil;
    RecordStream:=nil;
    CCDVideoSize:=nil;
    CCDVideoRates:=nil;
    VideoFPS:=nil;
    ImageAdjustments:=nil;
    IBrightness:=nil;
    IGamma:=nil;
    IGain:=nil;
    IExposure:=nil;
    StreamOptions:=nil;
    CCDCooler:=nil;
    CCDTemperature:=nil;
    CCDinfo:=nil;
    Guiderexpose:=nil;
    Guiderbinning:=nil;
    GuiderCompression:=nil;
    GuiderAbortExposure:=nil;
    Guiderinfo:=nil;
    WheelSlot:=nil;
    FilterName:=nil;
    ActiveDevices:=nil;
    UploadMode:=nil;
    UploadSettings:=nil;
    CCDfilepath:=nil;
    configprop:=nil;
    FhasBlob:=false;
    FhasVideo:=false;
    Fready:=false;
    Fconnected := false;
    FStatus := devDisconnected;
    FWheelStatus:=devDisconnected;
    CCDIso:=nil;
    FhasGainISO:=false;
    FhasGain:=false;
    FISOList.Clear;
    if Assigned(FonStatusChange) then FonStatusChange(self);
    if Assigned(FonWheelStatusChange) then FonWheelStatusChange(self);
end;

procedure T_indicamera.CheckStatus;
begin
    if Fconnected and
       (configprop<>nil) and
       FhasBlob and (
       ((Findisensor='CCD2')and(Guiderexpose<>nil))or
       ((Findisensor<>'CCD2')and(CCDexpose<>nil)) )
    then begin
       UseMainSensor:=(Findisensor<>'CCD2');
       if (not Fready) then begin
         Fready:=true;
         if FAutoloadConfig then begin
           LoadConfig;
         end;
         if Assigned(FonStatusChange) then FonStatusChange(self);
         if (WheelSlot<>nil) and (FilterName<>nil) then begin
           FWheelStatus:=devConnected;
           if Assigned(FonWheelStatusChange) then FonWheelStatusChange(self);
         end;
       end;
    end;
    if Fconnected and
       (not hasVideo) and
       (CCDVideoStream<>nil) and
       (RecordOptions <>nil) and
       (RecordFile<>nil) and
       (RecordStream<>nil)then begin
         FhasVideo:=true;
         if Assigned(FonStatusChange) then FonStatusChange(self);
       end;
end;

Procedure T_indicamera.Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''; cp5:string='');
begin
if (indiclient=nil)or(indiclient.Terminated) then CreateIndiClient;
if not indiclient.Connected then begin
  Findiserver:=cp1;
  Findiserverport:=cp2;
  Findidevice:=cp3;
  Fdevice:=cp3;
  Findisensor:=cp4;
  Findideviceport:=cp5;
  FStatus := devDisconnected;
  FWheelStatus:=devDisconnected;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  if Assigned(FonWheelStatusChange) then FonWheelStatusChange(self);
  indiclient.SetServer(Findiserver,Findiserverport);
  indiclient.watchDevice(Findidevice);
  indiclient.ConnectServer;
  FStatus := devConnecting;
  FWheelStatus := devConnecting;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  if Assigned(FonWheelStatusChange) then FonWheelStatusChange(self);
  InitTimer.Enabled:=true;
end
else msg('Camera already connected',0);
end;

procedure T_indicamera.InitTimerTimer(Sender: TObject);
begin
  InitTimer.Enabled:=false;
  if (not Fready) then begin
    msg(rsError2,0);
    if not Fconnected then begin
       msg(rsNoResponseFr,0);
       msg('Is "'+Findidevice+'" a running camera driver?',0);
    end
    else if (configprop=nil) then
       msg('Missing property CONFIG_PROCESS',0)
    else if not FhasBlob then
       msg('Missing property INDI_BLOB',0)
    else if ((Findisensor='CCD2')and(Guiderexpose=nil)) then
       msg(Findisensor+' missing property GUIDER_EXPOSURE',0)
    else if ((Findisensor<>'CCD2')and(CCDexpose=nil)) then
       msg(Findisensor+' missing property CCD_EXPOSURE',0);
    Disconnect;
  end;
end;

Procedure T_indicamera.Disconnect;
begin
InitTimer.Enabled:=False;
ConnectTimer.Enabled:=False;
indiclient.Terminate;
ClearStatus;
end;

procedure T_indicamera.ServerConnected(Sender: TObject);
begin
   ConnectTimer.Enabled:=True;
end;

procedure T_indicamera.ConnectTimerTimer(Sender: TObject);
begin
 ConnectTimer.Enabled:=False;
 if ((not FhasBlob) or (CCDport=nil)) and (not Fready) and InitTimer.Enabled then begin
   ConnectTimer.Enabled:=true;
 end;
 if (CCDport<>nil)and(Findideviceport<>'') then begin
     CCDport.tp[0].text:=Findideviceport;
     indiclient.sendNewText(CCDport);
     msg('Set port '+Findideviceport);
 end;
 indiclient.connectDevice(Findidevice);
 if FhasBlob then begin
   if (Findisensor='CCD1')or(Findisensor='CCD2') then
       indiclient.setBLOBMode(B_ALSO,Findidevice,Findisensor)
   else
       indiclient.setBLOBMode(B_ALSO,Findidevice);
 end;
 FStatus := devConnected;
 if Assigned(FonStatusChange) then FonStatusChange(self);
end;

procedure T_indicamera.ServerDisconnected(Sender: TObject);
begin
  FStatus := devDisconnected;
  FWheelStatus := devDisconnected;
  if Assigned(FonStatusChange) then FonStatusChange(self);
  if Assigned(FonWheelStatusChange) then FonWheelStatusChange(self);
  msg(rsServer+' '+rsDisconnected3,0);
  CreateIndiClient;
end;

procedure T_indicamera.NewDevice(dp: Basedevice);
begin
  //writeln('Newdev: '+dp.getDeviceName);
  if dp.getDeviceName=Findidevice then begin
     Fconnected:=true;
     CCDDevice:=dp;
  end;
end;

procedure T_indicamera.DeleteDevice(dp: Basedevice);
begin
  if dp.getDeviceName=Findidevice then begin
     Disconnect;
  end;
end;

procedure T_indicamera.DeleteProperty(indiProp: IndiProperty);
begin
  { TODO :  check if a vital property is removed ? }
end;

procedure T_indicamera.NewMessage(mp: IMessage);
begin
  if FVideoMsg then begin
    msg(mp.msg,3);
  end
  else begin
    if Assigned(FonDeviceMsg) then FonDeviceMsg(Findidevice+': '+mp.msg);
  end;
  mp.Free;
end;

procedure T_indicamera.NewProperty(indiProp: IndiProperty);
var propname: string;
    proptype: INDI_TYPE;
    i: integer;
begin
  propname:=indiProp.getName;
  proptype:=indiProp.getType;

  if (proptype = INDI_BLOB) then begin
     FhasBlob:=true;
  end
  else if (proptype=INDI_TEXT)and(CCDport=nil)and(propname='DEVICE_PORT') then begin
     CCDport:=indiProp.getText;
  end
  else if (proptype=INDI_SWITCH)and(configprop=nil)and(propname='CONFIG_PROCESS') then begin
     configprop:=indiProp.getSwitch;
     configload:=IUFindSwitch(configprop,'CONFIG_LOAD');
     configsave:=IUFindSwitch(configprop,'CONFIG_SAVE');
     if (configload=nil)or(configsave=nil) then configprop:=nil;
  end
  else if (proptype=INDI_NUMBER)and(CCDexpose=nil)and(propname='CCD_EXPOSURE') then begin
     CCDexpose:=indiProp.getNumber;
     CCDexposeValue:=IUFindNumber(CCDexpose,'CCD_EXPOSURE_VALUE');
     if CCDexposeValue=nil then CCDexpose:=nil;
  end
  else if (proptype=INDI_NUMBER)and(CCDbinning=nil)and(propname='CCD_BINNING') then begin
     CCDbinning:=indiProp.getNumber;
     CCDbinX:=IUFindNumber(CCDbinning,'HOR_BIN');
     CCDbinY:=IUFindNumber(CCDbinning,'VER_BIN');
     if (CCDbinX=nil)or(CCDbinY=nil) then CCDbinning:=nil;
  end
  else if (proptype=INDI_NUMBER)and(CCDframe=nil)and(propname='CCD_FRAME') then begin
     CCDframe:=indiProp.getNumber;
     CCDframeX:=IUFindNumber(CCDframe,'X');
     CCDframeY:=IUFindNumber(CCDframe,'Y');
     CCDframeWidth:=IUFindNumber(CCDframe,'WIDTH');
     CCDframeHeight:=IUFindNumber(CCDframe,'HEIGHT');
     if (CCDframeX=nil)or(CCDframeY=nil)or(CCDframeWidth=nil)or(CCDframeHeight=nil) then CCDframe:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CCDframeReset=nil)and(propname='CCD_FRAME_RESET') then begin
     CCDframeReset:=indiProp.getSwitch;
  end
  else if (proptype=INDI_SWITCH)and(CCDFrameType=nil)and(propname='CCD_FRAME_TYPE') then begin
     CCDFrameType:=indiProp.getSwitch;
     FrameLight:=IUFindSwitch(CCDFrameType,'FRAME_LIGHT');
     FrameBias:=IUFindSwitch(CCDFrameType,'FRAME_BIAS');
     FrameDark:=IUFindSwitch(CCDFrameType,'FRAME_DARK');
     FrameFlat:=IUFindSwitch(CCDFrameType,'FRAME_FLAT');
     if (FrameLight=nil)or(FrameBias=nil)or(FrameDark=nil)or(FrameFlat=nil) then CCDFrameType:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CCDCompression=nil)and(propname='CCD_COMPRESSION') then begin
     CCDCompression:=indiProp.getSwitch;
     CCDcompress:=IUFindSwitch(CCDCompression,'CCD_COMPRESS');
     if CCDcompress=nil then CCDcompress:=IUFindSwitch(CCDCompression,'COMPRESS');;
     CCDraw:=IUFindSwitch(CCDCompression,'CCD_RAW');
     if CCDraw=nil then CCDraw:=IUFindSwitch(CCDCompression,'RAW');
     if (CCDcompress=nil)or(CCDraw=nil) then CCDCompression:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CCDAbortExposure=nil)and(propname='CCD_ABORT_EXPOSURE') then begin
     CCDAbortExposure:=indiProp.getSwitch;
     CCDAbort:=IUFindSwitch(CCDAbortExposure,'ABORT');
     if (CCDAbort=nil) then CCDAbortExposure:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CCDCooler=nil)and(propname='CCD_COOLER') then begin
     CCDCooler:=indiProp.getSwitch;
     CCDCoolerOn:=IUFindSwitch(CCDCooler,'COOLER_ON');
     CCDCoolerOff:=IUFindSwitch(CCDCooler,'COOLER_OFF');
     if (CCDCoolerOn=nil)or(CCDCoolerOff=nil) then CCDCooler:=nil;
  end
  else if (proptype=INDI_NUMBER)and(CCDTemperature=nil)and(propname='CCD_TEMPERATURE') then begin
     CCDTemperature:=indiProp.getNumber;
  end
  else if (proptype=INDI_NUMBER)and(CCDinfo=nil)and(propname='CCD_INFO') then begin
     CCDinfo:=indiProp.getNumber;
     CCDmaxx:=IUFindNumber(CCDinfo,'CCD_MAX_X');
     CCDmaxy:=IUFindNumber(CCDinfo,'CCD_MAX_Y');
     CCDpixelsize:=IUFindNumber(CCDinfo,'CCD_PIXEL_SIZE');
     CCDpixelsizex:=IUFindNumber(CCDinfo,'CCD_PIXEL_SIZE_X');
     CCDpixelsizey:=IUFindNumber(CCDinfo,'CCD_PIXEL_SIZE_Y');
     CCDbitperpixel:=IUFindNumber(CCDinfo,'CCD_BITSPERPIXEL');
     if (CCDmaxx=nil)or(CCDmaxy=nil)or(CCDpixelsize=nil)or(CCDpixelsizex=nil)or(CCDpixelsizey=nil)or(CCDbitperpixel=nil) then CCDinfo:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CCDColorSpace=nil)and(propname='CCD_COLOR_SPACE') then begin
     CCDColorSpace:=indiProp.getSwitch;
     CCDColorGray:=IUFindSwitch(CCDColorSpace,'CCD_COLOR_GRAY');
     CCDColorRGB:=IUFindSwitch(CCDColorSpace,'CCD_COLOR_RGB');
     if (CCDColorGray=nil)or(CCDColorRGB=nil) then CCDColorSpace:=nil;
  end
  else if (proptype=INDI_NUMBER)and(Guiderexpose=nil)and(propname='GUIDER_EXPOSURE') then begin
     Guiderexpose:=indiProp.getNumber;
     GuiderexposeValue:=IUFindNumber(Guiderexpose,'GUIDER_EXPOSURE_VALUE');
     if GuiderexposeValue=nil then Guiderexpose:=nil;
  end
  else if (proptype=INDI_NUMBER)and(Guiderbinning=nil)and(propname='GUIDER_BINNING') then begin
     Guiderbinning:=indiProp.getNumber;
     GuiderbinX:=IUFindNumber(Guiderbinning,'HOR_BIN');
     GuiderbinY:=IUFindNumber(Guiderbinning,'VER_BIN');
     if (GuiderbinX=nil)or(GuiderbinY=nil) then Guiderbinning:=nil;
  end
  else if (proptype=INDI_SWITCH)and(GuiderCompression=nil)and(propname='GUIDER_COMPRESSION') then begin
     GuiderCompression:=indiProp.getSwitch;
     Guidercompress:=IUFindSwitch(GuiderCompression,'GUIDER_COMPRESS');
     if Guidercompress=nil then Guidercompress:=IUFindSwitch(GuiderCompression,'COMPRESS');;
     Guiderraw:=IUFindSwitch(GuiderCompression,'GUIDER_RAW');
     if Guiderraw=nil then Guiderraw:=IUFindSwitch(GuiderCompression,'RAW');
     if (Guidercompress=nil)or(Guiderraw=nil) then GuiderCompression:=nil;
  end
  else if (proptype=INDI_SWITCH)and(GuiderAbortExposure=nil)and(propname='GUIDER_ABORT_EXPOSURE') then begin
     GuiderAbortExposure:=indiProp.getSwitch;
     GuiderAbort:=IUFindSwitch(GuiderAbortExposure,'ABORT');
     if (GuiderAbort=nil) then GuiderAbortExposure:=nil;
  end
  else if (proptype=INDI_NUMBER)and(Guiderinfo=nil)and(propname='GUIDER_INFO') then begin
     Guiderinfo:=indiProp.getNumber;
     Guidermaxx:=IUFindNumber(CCDinfo,'GUIDER_MAX_X');
     Guidermaxy:=IUFindNumber(CCDinfo,'GUIDER_MAX_Y');
     Guiderpixelsize:=IUFindNumber(CCDinfo,'GUIDER_PIXEL_SIZE');
     Guiderpixelsizex:=IUFindNumber(CCDinfo,'GUIDER_PIXEL_SIZE_X');
     Guiderpixelsizey:=IUFindNumber(CCDinfo,'GUIDER_PIXEL_SIZE_Y');
     Guiderbitperpixel:=IUFindNumber(CCDinfo,'GUIDER_BITSPERPIXEL');
     if (Guidermaxx=nil)or(Guidermaxy=nil)or(Guiderpixelsize=nil)or(Guiderpixelsizex=nil)or(Guiderpixelsizey=nil)or(Guiderbitperpixel=nil) then Guiderinfo:=nil;
  end
  else if (proptype=INDI_NUMBER)and(WheelSlot=nil)and(propname='FILTER_SLOT') then begin
     WheelSlot:=indiProp.getNumber;
     Slot:=IUFindNumber(WheelSlot,'FILTER_SLOT_VALUE');
     if Slot=nil then WheelSlot:=nil;
  end
  else if (proptype=INDI_TEXT)and(FilterName=nil)and(propname='FILTER_NAME') then begin
     FilterName:=indiProp.getText;
     FFilterNames.Clear;
     FFilterNames.Add(Filter0);
     for i:=0 to FilterName.ntp-1 do begin
        FFilterNames.Add(FilterName.tp[i].text);
     end;
  end
  else if (proptype=INDI_SWITCH)and(UploadMode=nil)and(propname='UPLOAD_MODE') then begin
     UploadMode:=indiProp.getSwitch;
     UploadClient:=IUFindSwitch(UploadMode,'UPLOAD_CLIENT');
     UploadLocal:=IUFindSwitch(UploadMode,'UPLOAD_LOCAL');
     UploadBoth:=IUFindSwitch(UploadMode,'UPLOAD_BOTH');
     if (UploadClient=nil)or(UploadLocal=nil)or(UploadBoth=nil) then UploadMode:=nil;
  end
  else if (proptype=INDI_TEXT)and(UploadSettings=nil)and(propname='UPLOAD_SETTINGS') then begin
     UploadSettings:=indiProp.getText;
     UploadDir:=IUFindText(UploadSettings,'UPLOAD_DIR');
     UploadPrefix:=IUFindText(UploadSettings,'UPLOAD_PREFIX');
     if (UploadDir=nil)or(UploadPrefix=nil) then UploadSettings:=nil;
  end
  else if (proptype=INDI_TEXT)and(CCDfilepath=nil)and(propname='CCD_FILE_PATH') then begin
     CCDfilepath:=indiProp.getText;
  end
  else if (proptype=INDI_SWITCH)and(CCDVideoStream=nil)and(propname='CCD_VIDEO_STREAM') then begin
     CCDVideoStream:=indiProp.getSwitch;
     VideoStreamOn:=IUFindSwitch(CCDVideoStream,'STREAM_ON');
     VideoStreamOff:=IUFindSwitch(CCDVideoStream,'STREAM_OFF');
     if (VideoStreamOn=nil)or(VideoStreamOff=nil) then CCDVideoStream:=nil;
  end
  else if (proptype=INDI_NUMBER)and(RecordOptions=nil)and(propname='RECORD_OPTIONS') then begin
     RecordOptions:=indiProp.getNumber;
     RecordOptionDuration:=IUFindNumber(RecordOptions,'RECORD_DURATION');
     RecordOptionFrames:=IUFindNumber(RecordOptions,'RECORD_FRAME_TOTAL');
     if (RecordOptionDuration=nil)or(RecordOptionFrames=nil) then RecordOptions:=nil;
  end
  else if (proptype=INDI_TEXT)and(RecordFile=nil)and(propname='RECORD_FILE') then begin
     RecordFile:=indiProp.getText();
     RecordFileDir:=IUFindText(RecordFile,'RECORD_FILE_DIR');
     RecordFilename:=IUFindText(RecordFile,'RECORD_FILE_NAME');
     if (RecordFileDir=nil)or(RecordFilename=nil) then RecordFile:=nil;
  end
  else if (proptype=INDI_SWITCH)and(RecordStream=nil)and(propname='RECORD_STREAM') then begin
     RecordStream:=indiProp.getSwitch;
     RecordStreamOn:=IUFindSwitch(RecordStream,'RECORD_ON');
     RecordStreamOff:=IUFindSwitch(RecordStream,'RECORD_OFF');
     RecordDuration:=IUFindSwitch(RecordStream,'RECORD_DURATION_ON');
     RecordFrames:=IUFindSwitch(RecordStream,'RECORD_FRAME_ON');
     if (RecordStreamOn=nil)or(RecordStreamOff=nil)or(RecordDuration=nil)or(RecordFrames=nil) then RecordStream:=nil;
  end
  else if (proptype=INDI_SWITCH)and(CCDVideoSize=nil)and(propname='V4L2_SIZE_DISCRETE') then begin
     CCDVideoSize:=indiProp.getSwitch;
     FVideoSizes.Clear;
     if CCDVideoSize<>nil then for i:=0 to CCDVideoSize.nsp-1 do begin
        FVideoSizes.Add(CCDVideoSize.sp[i].name);
     end;
  end
  else if (proptype=INDI_SWITCH)and(CCDVideoRates=nil)and(propname='V4L2_FRAMEINT_DISCRETE') then begin
     CCDVideoRates:=indiProp.getSwitch;
     FVideoRates.Clear;
     if CCDVideoRates<>nil then for i:=0 to CCDVideoRates.nsp-1 do begin
        FVideoRates.Add(CCDVideoRates.sp[i].name);
     end;
  end
  else if (proptype=INDI_NUMBER)and(VideoFPS=nil)and(propname='FPS') then begin
     VideoFPS:=indiProp.getNumber;
     FPSest:=IUFindNumber(VideoFPS,'EST_FPS');
     FPSavg:=IUFindNumber(VideoFPS,'AVG_FPS');
     if (FPSest=nil)or(FPSavg=nil) then VideoFPS:=nil;
  end
  else if (proptype=INDI_NUMBER)and(StreamOptions=nil)and(propname='STREAM_OPTIONS') then begin
     StreamOptions:=indiProp.getNumber;
     StreamRate:=IUFindNumber(StreamOptions,'STREAM_RATE');
     if (StreamRate=nil) then StreamOptions:=nil;
  end
  else if (proptype=INDI_NUMBER)and(ImageAdjustments=nil)and((propname='CCD_CONTROLS')or(propname='Image Adjustments')) then begin
     ImageAdjustments:=indiProp.getNumber;
     IBrightness:=IUFindNumber(ImageAdjustments,'Brightness');
     IGamma:=IUFindNumber(ImageAdjustments,'Gamma');
     IGain:=IUFindNumber(ImageAdjustments,'Gain');
     IExposure:=IUFindNumber(ImageAdjustments,'Exposure');
     if IExposure=nil then IExposure:=IUFindNumber(ImageAdjustments,'Exposure (Absolute)');
     FhasGain:=(IGain<>nil);
     if FhasGain then begin
        FGainMin:=round(IGain.min);
        FGainMax:=round(IGain.max);
     end;
  end
  else if (proptype=INDI_SWITCH)and(CCDIso=nil)and(propname='CCD_ISO') then begin
     CCDIso:=indiProp.getSwitch;
     FISOList.Clear;
     for i:=0 to CCDIso.nsp-1 do begin
        {$ifdef camera_debug}msg(CCDIso.sp[i].lbl);{$endif}
        FISOList.Add(CCDIso.sp[i].lbl);
     end;
     FhasGainISO:=(FISOList.Count>0);
  end
  else if (proptype=INDI_TEXT)and(ActiveDevices=nil)and(propname='ACTIVE_DEVICES') then begin
     ActiveDevices:=indiProp.getText;
  end;
  CheckStatus;
end;

procedure T_indicamera.NewNumber(nvp: INumberVectorProperty);
begin
  if (UseMainSensor and (nvp=CCDexpose))or((not UseMainSensor) and (nvp=Guiderexpose)) then begin
     {$ifdef camera_debug}msg('progress: '+formatfloat(f1,nvp.np[0].value));{$endif}
     if Assigned(FonExposureProgress) then FonExposureProgress(nvp.np[0].value);
  end
  else if nvp=CCDframe then begin
     if Assigned(FonFrameChange) then FonFrameChange(self);
  end
  else if nvp=WheelSlot then begin
     if Assigned(FonFilterChange) then FonFilterChange(Slot.value);
  end
  else if nvp=CCDTemperature then begin
     if Assigned(FonTemperatureChange) then FonTemperatureChange(nvp.np[0].value);
  end
  else if nvp=VideoFPS then begin
     if Assigned(FonFPSChange) then FonFPSChange(self);
  end
  else if nvp=ImageAdjustments then begin
     if Assigned(FonVideoExposureChange) then FonVideoExposureChange(self);
  end
  ;
 end;

procedure T_indicamera.NewText(tvp: ITextVectorProperty);
var i: integer;
begin
if tvp=CCDfilepath then begin
  FImgStream.Clear;
  FImgStream.Position:=0;
  FImgStream.LoadFromFile(CCDfilepath.tp[0].text);
  DeleteFile(CCDfilepath.tp[0].text);
  NewImage;
end
else if tvp=FilterName then begin
    FFilterNames.Clear;
    FFilterNames.Add(Filter0);
    for i:=0 to tvp.ntp-1 do begin
       FFilterNames.Add(tvp.tp[i].text);
    end;
    if Assigned(FonFilterNameChange) then FonFilterNameChange(self);
end;
end;

procedure T_indicamera.NewSwitch(svp: ISwitchVectorProperty);
var propname: string;
    sw: ISwitch;
    cool: boolean;
begin
  //  writeln('NewSwitch: '+svp.name);
  propname:=svp.name;
  if (propname='CONNECTION') then begin
    sw:=IUFindOnSwitch(svp);
    if (sw<>nil)and(sw.name='DISCONNECT') then begin
      if Assigned(FonCameraDisconnected) then FonCameraDisconnected(self);
    end;
  end
  else if svp=CCDAbortExposure then begin
    if UseMainSensor then begin
      if Assigned(FonAbortExposure) then FonAbortExposure(self);
    end;
  end
  else if svp=GuiderAbortExposure then begin
    if (not UseMainSensor) then begin
      if Assigned(FonAbortExposure) then FonAbortExposure(self);
    end;
  end
  else if svp=CCDCooler then begin
      cool:=GetCooler;
      if Assigned(FonCoolerChange) then FonCoolerChange(cool);
  end
  else if svp=CCDVideoStream then begin
      if Assigned(FonVideoPreviewChange) then FonVideoPreviewChange(self);
  end
  else if svp=CCDVideoSize then begin
      if Assigned(FonVideoSizeChange) then FonVideoSizeChange(self);
  end
  else if svp=CCDVideoRates then begin
      if Assigned(FonVideoRateChange) then FonVideoRateChange(self);
  end
  ;
end;

procedure T_indicamera.NewLight(lvp: ILightVectorProperty);
begin
//  writeln('NewLight: '+lvp.name);
end;

procedure T_indicamera.NewBlob(bp: IBLOB);
var source,dest: array of char;
    sourceLen,destLen:UInt64;
    i: integer;
begin
 {$ifdef camera_debug}msg('receive blob');{$endif}
 if bp.bloblen>0 then begin
   if assigned(FonExposureProgress) then FonExposureProgress(0);
   bp.blob.Position:=0;
   if pos('.fits',bp.format)>0 then begin // receive a FITS file
     {$ifdef camera_debug}msg('this is a fits file');{$endif}
     if pos('.z',bp.format)>0 then begin //compressed
         {$ifdef camera_debug}msg('uncompress file');{$endif}
         FImgStream.Clear;
         FImgStream.Position:=0;
         if zlibok then begin
           sourceLen:=bp.bloblen;
           destLen:=bp.size;
           SetLength(source,sourceLen);
           SetLength(dest,destLen);
           bp.blob.Read(source[0],sourceLen);
           i:=uncompress(@dest[0],@destLen,@source[0],sourceLen);
           if i=0 then
              FImgStream.Write(dest[0],destLen);
           SetLength(source,0);
           SetLength(dest,0);
         end;
     end
     else begin  //uncompressed
        {$ifdef camera_debug}msg('copy stream');{$endif}
        FImgStream.Clear;
        FImgStream.Position:=0;
        FImgStream.CopyFrom(bp.blob,bp.size);
     end;
     {$ifdef camera_debug}msg('NewImage');{$endif}
     NewImage;
   end
   else if pos('.stream',bp.format)>0 then begin // video stream
     {$ifdef camera_debug}msg('this is a video stream');{$endif}
     if lockvideostream then exit; // skip extra frames if we cannot follow the rate
     lockvideostream:=true;
     {$ifdef camera_debug}msg('process this frame');{$endif}
     try
     if pos('.z',bp.format)>0 then begin //compressed
         {$ifdef camera_debug}msg('uncompress frame');{$endif}
         if zlibok then begin
           FVideoStream.Clear;
           FVideoStream.Position:=0;
           sourceLen:=bp.bloblen;
           destLen:=bp.size;
           SetLength(source,sourceLen);
           SetLength(dest,destLen);
           bp.blob.Read(source[0],sourceLen);
           i:=uncompress(@dest[0],@destLen,@source[0],sourceLen);
           if i=0 then
              FVideoStream.Write(dest[0],destLen);
           SetLength(source,0);
           SetLength(dest,0);
         end;
     end
     else begin  //uncompressed
       {$ifdef camera_debug}msg('copy frame');{$endif}
       FVideoStream.Clear;
       FVideoStream.Position:=0;
       FVideoStream.CopyFrom(bp.blob,bp.size);
     end;
     {$ifdef camera_debug}msg('NewVideoFrame');{$endif}
     NewVideoFrame;
     finally
       lockvideostream:=false;
     end;
   end
   else begin
        msg('Invalid file format '+bp.format+', a FITS file is required',0);
        AbortExposure;
        NewImage;
   end;
 end;
end;

Procedure T_indicamera.StartExposure(exptime: double);
begin
if FIndiTransfert=itDisk then begin
   if (UploadSettings=nil)or(UploadMode=nil) then
      FIndiTransfert:=itNetwork;
end;
case FIndiTransfert of
  itNetwork:begin
            if (UploadMode<>nil)and(UploadLocal.s=ISS_ON) then begin
               IUResetSwitch(UploadMode);
               UploadClient.s:=ISS_ON;
               indiclient.sendNewSwitch(UploadMode);
            end;
            end;
  itDisk:   begin
            if (UploadClient.s=ISS_ON) then begin
               IUResetSwitch(UploadMode);
               UploadLocal.s:=ISS_ON;
               indiclient.sendNewSwitch(UploadMode);
            end;
            if (UploadDir.text<>FIndiTransfertDir)or(UploadPrefix.text<>FIndiTransfertPrefix) then begin
               UploadDir.text:=FIndiTransfertDir;
               UploadPrefix.text:=FIndiTransfertPrefix;
               indiclient.sendNewText(UploadSettings);
            end;
            end;
end;
if UseMainSensor then begin
  if (not zlibok)and(CCDCompression<>nil)and(CCDcompress.s=ISS_ON) then begin
    IUResetSwitch(CCDCompression);
    CCDraw.s:=ISS_ON;
    indiclient.sendNewSwitch(CCDCompression);
    indiclient.WaitBusy(CCDCompression);
  end;
  if CCDexpose<>nil then begin;
    CCDexposeValue.value:=exptime;
    indiclient.sendNewNumber(CCDexpose);
  end;
end else begin
  if (not zlibok)and(GuiderCompression<>nil)and(Guidercompress.s=ISS_ON) then begin
    IUResetSwitch(GuiderCompression);
    Guiderraw.s:=ISS_ON;
    indiclient.sendNewSwitch(GuiderCompression);
    indiclient.WaitBusy(GuiderCompression);
  end;
  if Guiderexpose<>nil then begin;
    GuiderexposeValue.value:=exptime;
    indiclient.sendNewNumber(Guiderexpose);
  end;
end;
end;

function T_indicamera.GetExposureRange:TNumRange;
begin
if UseMainSensor then begin
 if CCDexpose<>nil then begin
    result.min:=CCDexposeValue.min;
    result.max:=CCDexposeValue.max;
    result.step:=CCDexposeValue.step;
 end
 else result:=NullRange;
end else begin
   if Guiderexpose<>nil then begin
      result.min:=GuiderexposeValue.min;
      result.max:=GuiderexposeValue.max;
      result.step:=GuiderexposeValue.step;
   end
   else result:=NullRange;
end;
end;

Procedure T_indicamera.AbortExposure;
begin
msg(rsAbortExposur);
if UseMainSensor then begin
  if CCDAbortExposure<>nil then begin
    IUResetSwitch(CCDAbortExposure);
    CCDAbort.s:=ISS_ON;
    indiclient.sendNewSwitch(CCDAbortExposure);
  end;
end else begin
   if GuiderAbortExposure<>nil then begin
     IUResetSwitch(GuiderAbortExposure);
     GuiderAbort.s:=ISS_ON;
     indiclient.sendNewSwitch(GuiderAbortExposure);
   end;
end;
end;

function T_indicamera.GetBinX:integer;
begin
if UseMainSensor then begin
 if CCDbinning<>nil then begin
    result:=round(CCDbinX.value);
 end
 else result:=1;
end else begin
   if Guiderbinning<>nil then begin
      result:=round(GuiderbinX.value);
   end
   else result:=1;
end;
end;

function T_indicamera.GetBinY:integer;
begin
if UseMainSensor then begin
 if CCDbinning<>nil then begin
    result:=round(CCDbinY.value);
 end
 else result:=1;
end else begin
   if Guiderbinning<>nil then begin
      result:=round(GuiderbinY.value);
   end
   else result:=1;
end;
end;

function T_indicamera.GetBinXrange:TNumRange;
begin
if UseMainSensor then begin
 if CCDbinning<>nil then begin
    result.min:=CCDbinX.min;
    result.max:=CCDbinX.max;
    result.step:=CCDbinX.step;
 end
 else result:=UnitRange;
end else begin
   if Guiderbinning<>nil then begin
      result.min:=GuiderbinX.min;
      result.max:=GuiderbinX.max;
      result.step:=GuiderbinX.step;
   end
   else result:=UnitRange;
end;
end;

function T_indicamera.GetBinYrange:TNumRange;
begin
if UseMainSensor then begin
 if CCDbinning<>nil then begin
    result.min:=CCDbinY.min;
    result.max:=CCDbinY.max;
    result.step:=CCDbinY.step;
 end
 else result:=UnitRange;
end else begin
   if Guiderbinning<>nil then begin
      result.min:=GuiderbinY.min;
      result.max:=GuiderbinY.max;
      result.step:=GuiderbinY.step;
   end
   else result:=UnitRange;
end;
end;

Procedure T_indicamera.SetBinning(sbinX,sbinY: integer);
begin
msg(Format(rsSetBinningX, [inttostr(sbinX), inttostr(sbinY)]));
if UseMainSensor then begin
 if CCDbinning<>nil then begin
    CCDbinX.value:=sbinX;
    CCDbinY.value:=sbinY;
    indiclient.sendNewNumber(CCDbinning);
    indiclient.WaitBusy(CCDbinning);
 end;
end else begin
 if Guiderbinning<>nil then begin
    GuiderbinX.value:=sbinX;
    GuiderbinY.value:=sbinY;
    indiclient.sendNewNumber(Guiderbinning);
    indiclient.WaitBusy(Guiderbinning);
 end;
end;
end;

procedure T_indicamera.SetFrametype(f:TFrameType);
begin
  if UseMainSensor and (CCDFrameType<>nil) then begin
     msg(Format(rsSetFrameType, [FrameName[ord(f)]]));
     IUResetSwitch(CCDFrameType);
     case f of
        LIGHT : FrameLight.s:=ISS_ON;
        BIAS  : FrameBias.s:=ISS_ON;
        DARK  : FrameDark.s:=ISS_ON;
        FLAT  : FrameFlat.s:=ISS_ON;
        else FrameLight.s:=ISS_ON;
     end;
     indiclient.sendNewSwitch(CCDFrameType);
  end;
end;

function  T_indicamera.GetFrametype:TFrameType;
begin
  if UseMainSensor and (CCDFrameType<>nil) then begin
     if FrameLight.s=ISS_ON then result:=LIGHT
     else if FrameBias.s=ISS_ON then result:=BIAS
     else if FrameDark.s=ISS_ON then result:=DARK
     else if FrameFlat.s=ISS_ON then result:=FLAT;
  end
  else result:=LIGHT;
end;

procedure T_indicamera.SetFrame(x,y,width,height: integer);
begin
  if UseMainSensor and (CCDframe<>nil) then begin
     // force even values
     x:=round(x+0.5);
     y:=round(y+0.5);
     // check range
     if (x+width)>CCDframeWidth.max then width:=round(CCDframeWidth.max-x);
     if (y+height)>CCDframeHeight.max then height:=round(CCDframeHeight.max-y);
     CCDframeX.value:=x;
     CCDframeY.value:=y;
     CCDframeWidth.value:=width;
     CCDframeHeight.value:=height;
     indiclient.sendNewNumber(CCDframe);
  end;
end;

procedure T_indicamera.GetFrame(out x,y,width,height: integer);
begin
  if UseMainSensor and (CCDframe<>nil) then begin
     x      := round(CCDframeX.value);
     y      := round(CCDframeY.value);
     width  := round(CCDframeWidth.value);
     height := round(CCDframeHeight.value);
  end else begin
     x:= 0;
     y:= 0;
     width:=0;
     height:=0;
  end;
end;

procedure T_indicamera.GetFrameRange(out xr,yr,widthr,heightr: TNumRange);
begin
  if UseMainSensor and (CCDframe<>nil) then begin
     xr.min:=CCDframeX.min;
     xr.max:=CCDframeX.max;
     xr.step:=CCDframeX.step;
     yr.min:=CCDframeY.min;
     yr.max:=CCDframeY.max;
     yr.step:=CCDframeY.step;
     widthr.min:=CCDframeWidth.min;
     widthr.max:=CCDframeWidth.max;
     widthr.step:=CCDframeWidth.step;
     heightr.min:=CCDframeHeight.min;
     heightr.max:=CCDframeHeight.max;
     heightr.step:=CCDframeHeight.step;
  end else begin
     xr:= NullRange;
     yr:= NullRange;
     widthr:=NullRange;
     heightr:=NullRange;
  end;
end;

procedure T_indicamera.ResetFrame;
begin
  if UseMainSensor then begin
     // Must not set the binning to 1x1 as CCD_FRAME_RESET do
     if CCDframe<>nil then begin
       CCDframeX.value:=CCDframeX.min;
       CCDframeY.value:=CCDframeY.min;
       CCDframeWidth.value:=CCDframeWidth.max;
       CCDframeHeight.value:=CCDframeHeight.max;
       indiclient.sendNewNumber(CCDframe);
    end;
  end;
end;

function T_indicamera.GetTemperatureRange:TNumRange;
begin
 if CCDTemperature<>nil then begin
    result.min:=CCDTemperature.np[0].min;
    result.max:=CCDTemperature.np[0].max;
    result.step:=CCDTemperature.np[0].step;
 end
 else result:=NullRange;
end;

function  T_indicamera.GetTemperature: double;
begin
 if CCDTemperature<>nil then begin
    result:=CCDTemperature.np[0].value;
 end
 else result:=NullCoord;
end;

procedure T_indicamera.SetTemperature(value:double);
begin
 if CCDTemperature<>nil then begin
    CCDTemperature.np[0].value:=value;
    indiclient.sendNewNumber(CCDTemperature);
 end;
end;

function  T_indicamera.GetCooler: boolean;
begin
 if CCDCooler<>nil then begin
    result:=(CCDCoolerOn.s=ISS_ON)and((CCDCoolerOn.s=ISS_ON)xor(CCDCoolerOff.s=ISS_ON)); // sometime both are ON, bug in driver?
 end
 else result:=false;
end;

procedure T_indicamera.SetCooler(value:boolean);
begin
 if CCDCooler<>nil then begin
    msg(Format(rsSetCooler, [': '+BoolToStr(value, rsTrue, rsFalse)]));
    IUResetSwitch(CCDCooler);
    if value then CCDCoolerOn.s:=ISS_ON
             else CCDCoolerOff.s:=ISS_ON;
    indiclient.sendNewSwitch(CCDCooler);
 end;
end;

Procedure T_indicamera.SetActiveDevices(afocuser,afilters,atelescope: string);
var tp:IText;
begin
  if ActiveDevices<>nil then begin
     if afocuser<>'' then begin
        tp:=IUFindText(ActiveDevices,'ACTIVE_FOCUSER');
        if tp<>nil then begin
           tp.text:=afocuser;
        end;
     end;
     if afilters<>'' then begin
        tp:=IUFindText(ActiveDevices,'ACTIVE_FILTER');
        if tp<>nil then begin
           tp.text:=afilters;
        end;
     end;
     if atelescope<>'' then begin
        tp:=IUFindText(ActiveDevices,'ACTIVE_TELESCOPE');
        if tp<>nil then begin
           tp.text:=atelescope;
        end;
     end;
     indiclient.sendNewText(ActiveDevices);
  end;
end;

procedure T_indicamera.SetFilter(num:integer);
begin
if WheelSlot<>nil then begin;
  msg(Format(rsSetFilterPos, [inttostr(num)]));
  Slot.value:=num;
  indiclient.sendNewNumber(WheelSlot);
  indiclient.WaitBusy(WheelSlot);
end;
end;

function  T_indicamera.GetFilter:integer;
begin
if WheelSlot<>nil then begin;
  result:=round(Slot.value);
end
else result:=0;
end;

procedure T_indicamera.SetFilterNames(value:TStringList);
var i:integer;
begin
if (FilterName<>nil)and(value.Count=FilterName.ntp) then begin
  for i:=0 to value.Count-1 do begin
     FilterName.tp[i].text:=FFilterNames[i];
  end;
  indiclient.sendNewText(FilterName);
  indiclient.WaitBusy(FilterName);
end;
end;

function T_indicamera.GetMaxX: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=CCDmaxx.value;
   end
   else result:=-1;
  end else begin
     if Guiderinfo<>nil then begin
        result:=Guidermaxx.value;
     end
     else result:=-1;
  end;
end;

function T_indicamera.GetMaxY: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=CCDmaxy.value;
   end
   else result:=-1;
  end else begin
     if Guiderinfo<>nil then begin
        result:=Guidermaxy.value;
     end
     else result:=-1;
  end;
end;

function T_indicamera.GetMaxADU: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=2**CCDbitperpixel.value-1;
   end
   else result:=MAXWORD;
  end else begin
     if Guiderinfo<>nil then begin
        result:=2**Guiderbitperpixel.value-1;
     end
     else result:=MAXWORD;
  end;
end;

function T_indicamera.GetPixelSize: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=CCDpixelsize.value;
   end
   else result:=-1;
  end else begin
     if Guiderinfo<>nil then begin
        result:=Guiderpixelsize.value;
     end
     else result:=-1;
  end;
end;

function T_indicamera.GetPixelSizeX: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=CCDpixelsizex.value;
   end
   else result:=-1;
  end else begin
     if Guiderinfo<>nil then begin
        result:=Guiderpixelsizex.value;
     end
     else result:=-1;
  end;
end;

function T_indicamera.GetPixelSizeY: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=CCDpixelsizey.value;
   end
   else result:=-1;
  end else begin
     if Guiderinfo<>nil then begin
        result:=Guiderpixelsizey.value;
     end
     else result:=-1;
  end;
end;

function T_indicamera.GetBitperPixel: double;
begin
  if UseMainSensor then begin
   if CCDinfo<>nil then begin
      result:=CCDbitperpixel.value;
   end
   else result:=-1;
  end else begin
     if Guiderinfo<>nil then begin
        result:=Guiderbitperpixel.value;
     end
     else result:=-1;
  end;
end;

function T_indicamera.GetColor: boolean;
begin
  if CCDColorSpace<>nil then begin
     result:=(CCDColorRGB.s=ISS_ON);
  end
  else begin
    result:=false;
  end;
end;

procedure T_indicamera.SetTimeout(num:integer);
begin
 FTimeOut:=num;
 indiclient.Timeout:=FTimeOut;
end;

function T_indicamera.CheckGain:boolean;
begin
  result:=(FhasGainISO or FhasGain);
end;

procedure T_indicamera.SetGain(value: integer);
begin
  if (CCDIso<>nil) and FhasGainISO then begin
    IUResetSwitch(CCDIso);
    CCDIso.sp[value].s := ISS_ON;
    indiclient.sendNewSwitch(CCDIso);
  end
  else if (IGain<>nil) and FhasGain then begin
    IGain.value:=value;
    indiclient.sendNewNumber(ImageAdjustments);
  end;
end;

function T_indicamera.GetGain: integer;
var i: integer;
begin
  result:=NullInt;
  if (CCDIso<>nil) and FhasGainISO then begin
    for i := 0 to CCDIso.nsp - 1 do
      if CCDIso.sp[i].s = ISS_ON then begin
         result:=i;
         break;
      end;
  end
  else if (IGain<>nil) and FhasGain then begin
      result:=round(IGain.value);
  end;
end;

procedure T_indicamera.LoadConfig;
begin
  if configprop<>nil then begin
    IUResetSwitch(configprop);
    configload.s:=ISS_ON;
    indiclient.sendNewSwitch(configprop);
  end;
end;

procedure T_indicamera.StartVideoPreview;
begin
 if CCDVideoStream<>nil then begin
  FVideoMsg:=true;
  IUResetSwitch(CCDVideoStream);
  VideoStreamOn.s:=ISS_ON;
  indiclient.sendNewSwitch(CCDVideoStream);
 end;
end;

procedure T_indicamera.StopVideoPreview;
begin
 if CCDVideoStream<>nil then begin
  IUResetSwitch(CCDVideoStream);
  VideoStreamOff.s:=ISS_ON;
  indiclient.sendNewSwitch(CCDVideoStream);
 end;
end;

function T_indicamera.GetVideoPreviewRunning: boolean;
begin
 result:=false;
 if CCDVideoStream<>nil then begin
   result:=(VideoStreamOn.s=ISS_ON);
 end;
end;

function T_indicamera.GetMissedFrameCount: cardinal;
begin
 result:=indiclient.MissedFrameCount;
end;

function T_indicamera.GetVideoRecordDuration:integer;
begin
 result:=0;
 if RecordOptions<>nil then begin
    result:=round(RecordOptionDuration.value);
 end;
end;

procedure T_indicamera.SetVideoRecordDuration(value:integer);
begin
 if RecordOptions<>nil then begin;
   RecordOptionDuration.value:=value;
   indiclient.sendNewNumber(RecordOptions);
 end;
end;

function T_indicamera.GetVideoRecordFrames:integer;
begin
  result:=0;
  if RecordOptions<>nil then begin
     result:=round(RecordOptionFrames.value);
  end;
end;

procedure T_indicamera.SetVideoRecordFrames(value:integer);
begin
  if RecordOptions<>nil then begin;
    RecordOptionFrames.value:=value;
    indiclient.sendNewNumber(RecordOptions);
  end;
end;

procedure T_indicamera.StartVideoRecord(mode:TVideoRecordMode);
begin
  if RecordStream<>nil then begin
    FVideoMsg:=true;
    IUResetSwitch(RecordStream);
    case mode of
       rmDuration : RecordDuration.s:=ISS_ON;
       rmFrame    : RecordFrames.s:=ISS_ON;
       rmUnlimited: RecordStreamOn.s:=ISS_ON;
    end;
    indiclient.sendNewSwitch(RecordStream);
  end;
end;

procedure T_indicamera.StopVideoRecord;
begin
  if RecordStream<>nil then begin
    IUResetSwitch(RecordStream);
    RecordStreamOff.s:=ISS_ON;
    indiclient.sendNewSwitch(RecordStream);
  end;
end;

function T_indicamera.GetVideoSize:string;
var sw:ISwitch;
begin
  result:='';
  if CCDVideoSize<>nil then begin
     sw:=IUFindOnSwitch(CCDVideoSize);
     if sw<>nil then result:=sw.name;
  end;
end;

procedure T_indicamera.SetVideoSize(value:string);
var sw:ISwitch;
begin
  if CCDVideoSize<>nil then begin
    sw:=IUFindSwitch(CCDVideoSize,value);
    if sw<>nil then begin
      IUResetSwitch(CCDVideoSize);
      sw.s:=ISS_ON;
      indiclient.sendNewSwitch(CCDVideoSize);
    end;
  end;
end;

function T_indicamera.GetVideoRate:string;
var sw:ISwitch;
begin
  result:='';
  if CCDVideoRates<>nil then begin
     sw:=IUFindOnSwitch(CCDVideoRates);
     if sw<>nil then result:=sw.name;
  end;
end;

procedure T_indicamera.SetVideoRate(value:string);
var sw:ISwitch;
begin
  if CCDVideoRates<>nil then begin
    sw:=IUFindSwitch(CCDVideoRates,value);
    if sw<>nil then begin
      IUResetSwitch(CCDVideoRates);
      sw.s:=ISS_ON;
      indiclient.sendNewSwitch(CCDVideoRates);
    end;
  end;
end;

function T_indicamera.GetFPS:double;
begin
 result:=0;
 if VideoFPS<>nil then begin
   result:=FPSavg.value;
 end;
end;

function T_indicamera.GetVideoRecordDir:string;
begin
 result:='';
 if RecordFile<>nil then begin
   result:=RecordFileDir.text;
 end;
end;

procedure T_indicamera.SetVideoRecordDir(value:string);
begin
 if RecordFile<>nil then begin
   RecordFileDir.text:=value;
   indiclient.sendNewText(RecordFile);
 end;
end;

function T_indicamera.GetVideoRecordFile:string;
begin
 result:='';
 if RecordFile<>nil then begin
   result:=RecordFilename.text;
 end;
end;

procedure T_indicamera.SetVideoRecordFile(value:string);
begin
 if RecordFile<>nil then begin
   RecordFilename.text:=value;
   indiclient.sendNewText(RecordFile);
 end;
end;


function T_indicamera.GetVideoExposure:integer;
begin
 result:=0;
 if IExposure<>nil then begin
    result:=round(IExposure.value);
 end;
end;

function T_indicamera.GetVideoGain:integer;
begin
 result:=NullInt;
 if IGain<>nil then begin
    result:=round(IGain.value);
 end;
end;

function T_indicamera.GetVideoGamma:integer;
begin
 result:=NullInt;
 if IGamma<>nil then begin
    result:=round(IGamma.value);
 end;
end;

function T_indicamera.GetVideoBrightness:integer;
begin
 result:=NullInt;
 if IBrightness<>nil then begin
    result:=round(IBrightness.value);
 end;
end;

procedure T_indicamera.SetVideoExposure(value:integer);
begin
 if IExposure<>nil then begin;
   IExposure.value:=value;
   indiclient.sendNewNumber(ImageAdjustments);
 end;
end;

procedure T_indicamera.SetVideoGain(value:integer);
begin
 if IGain<>nil then begin;
   IGain.value:=value;
   indiclient.sendNewNumber(ImageAdjustments);
 end;
end;

procedure T_indicamera.SetVideoGamma(value:integer);
begin
 if IGamma<>nil then begin;
   IGamma.value:=value;
   indiclient.sendNewNumber(ImageAdjustments);
 end;
end;

procedure T_indicamera.SetVideoBrightness(value:integer);
begin
 if IBrightness<>nil then begin;
   IBrightness.value:=value;
   indiclient.sendNewNumber(ImageAdjustments);
 end;
end;

function T_indicamera.GetVideoExposureRange:TNumRange;
begin
 result:=NullRange;
 if IExposure<>nil then begin
    result.min:=IExposure.min;
    result.max:=IExposure.max;
    result.step:=IExposure.step;
 end
end;

function T_indicamera.GetVideoGainRange:TNumRange;
begin
 result:=NullRange;
 if (IGain<>nil)and(not FhasGainISO) then begin
    result.min:=IGain.min;
    result.max:=IGain.max;
    result.step:=IGain.step;
 end
end;

function T_indicamera.GetVideoGammaRange:TNumRange;
begin
 result:=NullRange;
 if IGamma<>nil then begin
    result.min:=IGamma.min;
    result.max:=IGamma.max;
    result.step:=IGamma.step;
 end
end;

function T_indicamera.GetVideoBrightnessRange:TNumRange;
begin
 result:=NullRange;
 if IBrightness<>nil then begin
    result.min:=IBrightness.min;
    result.max:=IBrightness.max;
    result.step:=IBrightness.step;
 end
end;

function T_indicamera.GetVideoPreviewDivisor:integer;
begin
  result:=0;
  if StreamOptions<>nil then begin
     result:=round(StreamRate.value);
  end;
end;

procedure T_indicamera.SetVideoPreviewDivisor(value:integer);
begin
 if StreamOptions<>nil then begin;
   StreamRate.value:=value;
   indiclient.sendNewNumber(StreamOptions);
 end;
end;

end.

