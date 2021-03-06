unit cu_ascommount;

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

interface

uses  cu_mount, u_global,  indiapi,
  {$ifdef mswindows}
    u_translation, Variants, comobj, u_utils,
  {$endif}
  Forms, ExtCtrls, Classes, SysUtils;

type
T_ascommount = class(T_mount)
 private
   {$ifdef mswindows}
   V: variant;
   stRA,stDE: double;
   stPark:boolean;
   stPierside: TPierSide;
   CanPark,CanSlew,CanSlewAsync,CanSetPierSide,CanSync,CanSetTracking: boolean;
   {$endif}
   StatusTimer: TTimer;
   function Connected: boolean;
   procedure StatusTimerTimer(sender: TObject);
   procedure CheckEqmod;
   function WaitMountSlewing(maxtime:integer):boolean;
 protected
   procedure SetPark(value:Boolean); override;
   function  GetPark:Boolean; override;
   function  GetRA:double; override;
   function  GetDec:double; override;
   function  GetPierSide: TPierSide; override;
   function  GetEquinox: double; override;
   function  GetAperture:double; override;
   function  GetFocaleLength:double; override;
   procedure SetTimeout(num:integer); override;
   function  GetSyncMode:TEqmodAlign; override;
   procedure SetSyncMode(value:TEqmodAlign); override;
   function GetMountSlewing:boolean; override;
public
   constructor Create(AOwner: TComponent);override;
   destructor  Destroy; override;
   procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''); override;
   procedure Disconnect; override;
   function Slew(sra,sde: double):boolean; override;
   function SlewAsync(sra,sde: double):boolean; override;
   function FlipMeridian: boolean; override;
   function Sync(sra,sde: double):boolean; override;
   function Track:boolean; override;
   procedure AbortMotion; override;
   function ClearAlignment:boolean; override;
   function ClearDelta:boolean; override;
   function GetSite(var long,lat,elev: double): boolean; override;
   function SetSite(long,lat,elev: double): boolean; override;
   function GetDate(var utc,offset: double): boolean; override;
   function SetDate(utc,offset: double): boolean; override;
end;


implementation

constructor T_ascommount.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FMountInterface:=ASCOM;
 StatusTimer:=TTimer.Create(nil);
 StatusTimer.Enabled:=false;
 StatusTimer.Interval:=1000;
 StatusTimer.OnTimer:=@StatusTimerTimer;
end;

destructor  T_ascommount.Destroy;
begin
 StatusTimer.Free;
 inherited Destroy;
end;

procedure T_ascommount.Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string='');
{$ifdef mswindows}
var buf: string;
{$endif}
begin
 {$ifdef mswindows}
  try
  FStatus := devConnecting;
  FDevice:=cp1;
  V:=Unassigned;
  V:=CreateOleObject(Fdevice);
  V.connected:=true;
  if V.connected then begin
     FStatus := devConnected;
     CheckEqmod;
     CanPark:=V.CanPark;
     CanSlew:=V.CanSlew;
     CanSlewAsync:=V.CanSlewAsync;
     CanSetPierSide:=V.CanSetPierSide;
     CanSync:=V.CanSync;
     CanSetTracking:=V.CanSetTracking;
     buf:='';
     if IsEqmod then buf:=buf+'EQmod ';
     if CanPark then buf:=buf+'CanPark ';
     if CanSlew then buf:=buf+'CanSlew ';
     if CanSlewAsync then buf:=buf+'CanSlewAsync ';
     if CanSetPierSide then buf:=buf+'CanSetPierSide ';
     if CanSync then buf:=buf+'CanSync ';
     if CanSetTracking then buf:=buf+'CanSetTracking ';
     msg(rsConnected3);
     msg(Format(rsMountCapabil, [buf]));
     if Assigned(FonStatusChange) then FonStatusChange(self);
     if Assigned(FonParkChange) then FonParkChange(self);
     if Assigned(FonPiersideChange) then FonPiersideChange(self);
     StatusTimer.Enabled:=true;
  end
  else
     Disconnect;
  except
    on E: Exception do msg('Connection error: ' + E.Message,0);
  end;
 {$endif}
end;

procedure T_ascommount.Disconnect;
begin
 {$ifdef mswindows}
   StatusTimer.Enabled:=false;
   FStatus := devDisconnected;
   if Assigned(FonStatusChange) then FonStatusChange(self);
   try
   if not VarIsEmpty(V) then begin
     msg(rsDisconnected3,0);
     V.connected:=false;
     V:=Unassigned;
   end;
   except
     on E: Exception do msg('Disconnection error: ' + E.Message,0);
   end;
 {$endif}
end;

function T_ascommount.Connected: boolean;
begin
result:=false;
{$ifdef mswindows}
if not VarIsEmpty(V) then begin
  try
  result:=V.connected;
  except
   result:=false;
  end;
end;
{$endif}
end;

procedure T_ascommount.StatusTimerTimer(sender: TObject);
{$ifdef mswindows}
var x,y: double;
    pk: boolean;
    ps: TPierSide;
  {$endif}
begin
 {$ifdef mswindows}
  if not Connected then begin
     FStatus := devDisconnected;
     if Assigned(FonStatusChange) then FonStatusChange(self);
  end
  else begin
    try
    x:=GetRA;
    y:=GetDec;
    pk:=GetPark;
    ps:=GetPierSide;
    if (x<>stRA)or(y<>stDE) then begin
       stRA:=x;
       stDE:=y;
       if Assigned(FonCoordChange) then FonCoordChange(self);
    end;
    if pk<>stPark then begin
       stPark:=pk;
       if Assigned(FonParkChange) then FonParkChange(self);
    end;
    if ps<>stPierside then begin
       stPierside:=ps;
       if Assigned(FonPiersideChange) then FonPiersideChange(self);
    end;
    except
     on E: Exception do msg('Status error: ' + E.Message,0);
    end;
  end;
 {$endif}
end;

procedure T_ascommount.SetPark(value:Boolean);
begin
 {$ifdef mswindows}
 if Connected then begin
   try
   if CanPark then begin
      if value then begin
         msg(rsPark);
         V.Park;
      end else begin
         msg(rsUnpark);
         V.UnPark;
      end;
   end;
   except
    on E: Exception do msg('Park error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function  T_ascommount.GetPark:Boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected then begin
   try
   result:=V.AtPark;
   except
    result:=false;
   end;
 end
 else result:=false;
 {$endif}
end;

function  T_ascommount.GetRA:double;
begin
 result:=NullCoord;
 {$ifdef mswindows}
 if Connected then begin
   try
   result:=V.RightAscension;
   except
    result:=NullCoord;
   end;
 end
 else result:=NullCoord;
 {$endif}
end;

function  T_ascommount.GetDec:double;
begin
 result:=NullCoord;
 {$ifdef mswindows}
 if Connected then begin
   try
   result:=V.Declination;
   except
    result:=NullCoord;
   end;
 end
 else result:=NullCoord;
 {$endif}
end;

function  T_ascommount.GetPierSide:TPierSide;
{$ifdef mswindows}
var i: integer;
{$endif}
begin
 result:=pierUnknown;
 {$ifdef mswindows}
 if Connected then begin
   try
   i:=V.SideOfPier;  // pascal enum may have different size
   case i of
     -1: result:=pierUnknown;
      0: result:=pierEast;
      1: result:=pierWest;
   end;
   except
    result:=pierUnknown;
   end;
 end
 else result:=pierUnknown;
 {$endif}
end;

function  T_ascommount.GetEquinox: double;
{$ifdef mswindows}
var i: Integer;
{$endif}
begin
 result:=0;
{$ifdef mswindows}
if Connected then begin
  try
  i:=V.EquatorialSystem;
  case i of
  0 : result:=0;
  1 : result:=0;
  2 : result:=2000;
  3 : result:=2050;
  4 : result:=1950;
  end;
  except
   result:=0;
  end;
end
else result:=0;
{$endif}
end;

function  T_ascommount.GetAperture:double;
begin
 result:=-1;
 {$ifdef mswindows}
 if Connected then begin
   try
   result:=V.ApertureDiameter*1000;
   except
    result:=-1;
   end;
 end
 else result:=-1;
 {$endif}
end;

function  T_ascommount.GetFocaleLength:double;
begin
 result:=-1;
 {$ifdef mswindows}
 if Connected then begin
   try
   result:=V.FocalLength*1000;
   except
    result:=-1;
   end;
 end
 else result:=-1;
 {$endif}
end;

function T_ascommount.SlewAsync(sra,sde: double):boolean;
begin
 result:=false;
 {$ifdef mswindows}
 result:=false;
 if Connected and CanSlew then begin
   try
   if CanSetTracking and (not V.tracking) then begin
     try
      V.tracking:=true;
     except
       on E: Exception do msg('Set tracking error: ' + E.Message,0);
     end;
   end;
   msg(Format(rsSlewTo, [ARToStr3(sra), DEToStr(sde)]));
   if CanSlewAsync then begin
     V.SlewToCoordinatesAsync(sra,sde);
   end
   else
     V.SlewToCoordinates(sra,sde);
   result:=true;
   except
     on E: Exception do msg('Slew error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.Slew(sra,sde: double):boolean;
begin
 result:=false;
 {$ifdef mswindows}
 result:=false;
 if Connected and CanSlew then begin
   try
   if CanSetTracking and (not V.tracking) then begin
     try
      V.tracking:=true;
     except
       on E: Exception do msg('Set tracking error: ' + E.Message,0);
     end;
   end;
   FMountSlewing:=true;
   msg(Format(rsSlewTo, [ARToStr3(sra), DEToStr(sde)]));
   if CanSlewAsync then begin
     V.SlewToCoordinatesAsync(sra,sde);
     WaitMountSlewing(120000);
   end
   else
     V.SlewToCoordinates(sra,sde);
   wait(2);
   msg(rsSlewComplete);
   FMountSlewing:=false;
   result:=true;
   except
     on E: Exception do msg('Slew error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.GetMountSlewing:boolean;
{$ifdef mswindows}
var islewing: boolean;
{$endif}
begin
 result:=false;
 {$ifdef mswindows}
 try
 islewing:=false;
  if CanSlewAsync then
    islewing:=V.Slewing
  else
    islewing:=false;
  result:=(islewing or FMountSlewing);
  except
    on E: Exception do msg('Get slewing error: ' + E.Message,0);
  end;
 {$endif}
end;

function T_ascommount.WaitMountSlewing(maxtime:integer):boolean;
{$ifdef mswindows}
var count,maxcount:integer;
{$endif}
begin
 result:=true;
 {$ifdef mswindows}
 try
 if Connected and CanSlewAsync then begin
   maxcount:=maxtime div 100;
   count:=0;
   while (V.Slewing)and(count<maxcount) do begin
      sleep(100);
      if GetCurrentThreadId=MainThreadID then Application.ProcessMessages;
      inc(count);
   end;
   result:=(count<maxcount);
 end;
 except
   result:=false;
 end;
 {$endif}
end;

function T_ascommount.FlipMeridian:boolean;
{$ifdef mswindows}
var sra,sde,ra1,ra2: double;
    pierside1,pierside2:TPierSide;
{$endif}
begin
  result:=false;
  {$ifdef mswindows}
  if Connected then begin
    sra:=GetRA;
    sde:=GetDec;
    pierside1:=GetPierSide;
    if pierside1=pierEast then exit; // already right side
    if (sra=NullCoord)or(sde=NullCoord) then exit;
    msg(rsMeridianFlip5);
    {TODO: someone with a mount that support this feature can test it}
{    if CanSetPierSide then begin
       // do the flip
       V.SideOfPier:=0; // pierEast
       WaitMountSlewing(240000);
       // return to position
       slew(sra,sde);
       WaitMountSlewing(240000);
       // check result
       pierside2:=GetPierSide;
       result:=(pierside2<>pierside1);
    end
    else} begin
      // point one hour to the east
      ra1:=sra+1;
      if ra1>=24 then ra1:=ra1-24;
      slew(ra1,sde);
      // point one hour to the west to force the flip
      ra2:=sra-1;
      if ra2<0 then ra2:=ra2+24;
      slew(ra2,sde);
      // return to position
      slew(sra,sde);
      // check result
      pierside2:=GetPierSide;
      result:=(pierside2<>pierside1);
    end;
  end;
  {$endif}
end;

function T_ascommount.Sync(sra,sde: double):boolean;
begin
 result:=false;
 {$ifdef mswindows}
 result:=false;
 if Connected and CanSync then begin
   try
   if CanSetTracking and (not V.tracking) then begin
     msg(rsCannotSyncWh,0);
     exit;
   end;
   msg(Format(rsSyncTo, [ARToStr3(sra), DEToStr(sde)]));
   V.SyncToCoordinates(sra,sde);
   result:=true;
   except
     on E: Exception do msg('Sync error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.Track:boolean;
begin
 result:=false;
 {$ifdef mswindows}
 result:=false;
 if Connected then begin
   try
   if CanSetTracking and (not V.tracking) then begin
     try
      msg(rsStartTraking);
      V.tracking:=true;
     except
       on E: Exception do msg('Set tracking error: ' + E.Message,0);
     end;
   end;
   result:=true;
   except
     on E: Exception do msg('Track error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

procedure T_ascommount.AbortMotion;
begin
 {$ifdef mswindows}
 if Connected and CanSlew then begin
   try
   msg(rsStopTelescop);
   V.AbortSlew;
   if CanSetTracking  then V.tracking:=false;
   except
     on E: Exception do msg('Abort motion error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

procedure T_ascommount.SetTimeout(num:integer);
begin
 FTimeOut:=num;
end;

// Eqmod specific

procedure T_ascommount.CheckEqmod;
{$ifdef mswindows}
var buf:string;
{$endif}
begin
  FIsEqmod:=false;
  {$ifdef mswindows}
  if Connected then begin
    try
    buf:=V.CommandString(':MOUNTVER#');
    if length(buf)=8 then FIsEqmod:=true;
    except
     FIsEqmod:=false;
    end;
  end
  {$endif}
end;

function  T_ascommount.GetSyncMode:TEqmodAlign;
{$ifdef mswindows}
var buf:string;
{$endif}
begin
 result:=alUNSUPPORTED;
 {$ifdef mswindows}
 if Connected and IsEqmod then begin
   try
   buf:=V.CommandString(':ALIGN_MODE#');
   if buf='1#' then result:=alADDPOINT
   else if buf='0#' then result:=alSTDSYNC;
   except
    result:=alUNSUPPORTED;
   end;
 end
 else result:=alUNSUPPORTED;
 {$endif}
end;

procedure T_ascommount.SetSyncMode(value:TEqmodAlign);
begin
 {$ifdef mswindows}
 if Connected and IsEqmod and (value<>alUNSUPPORTED) then begin
   try
   if value=alSTDSYNC then begin
     msg('align mode Std Sync');
     V.CommandString(':ALIGN_MODE,0#');
   end
   else if value=alADDPOINT then begin
     msg('align mode Add Point');
     V.CommandString(':ALIGN_MODE,1#');
   end;
   except
     on E: Exception do msg('Eqmod set sync mode error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.ClearAlignment:boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected and IsEqmod then begin
   try
   msg('clear alignment');
   V.CommandString(':ALIGN_CLEAR_POINTS#');
   result:=true;
   except
     on E: Exception do msg('Eqmod clear alignment error: ' + E.Message,0);
   end;
 end;
 {$endif}

end;

function T_ascommount.ClearDelta:boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected and IsEqmod then begin
   try
   msg('clear delta sync');
   V.CommandString(':ALIGN_CLEAR_SYNC#');
   result:=true;
   except
     on E: Exception do msg('Eqmod clear delta error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.GetSite(var long,lat,elev: double): boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected then begin
   try
   long:=V.SiteLongitude;
   lat:=V.SiteLatitude;
   elev:=V.SiteElevation;
   result:=true;
   except
     on E: Exception do msg('Cannot get site information: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.SetSite(long,lat,elev: double): boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected then begin
   try
   V.SiteLongitude := long;
   V.SiteLatitude  := lat;
   V.SiteElevation := elev;
   result:=true;
   except
     on E: Exception do msg('Cannot set site information: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.GetDate(var utc,offset: double): boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected then begin
   try
   utc:=VarToDateTime(V.UTCDate);
   offset:=ObsTimeZone; // No offset in ASCOM telescope interface
   result:=true;
   except
     on E: Exception do msg('Cannot get date: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function T_ascommount.SetDate(utc,offset: double): boolean;
begin
 result:=false;
 {$ifdef mswindows}
 if Connected then begin
   try
   V.UTCDate:=VarFromDateTime(utc);
   result:=true;
   except
     on E: Exception do msg('Cannot set date: ' + E.Message,0);
   end;
 end;
 {$endif}
end;
end.

