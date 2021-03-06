unit cu_ascomwheel;

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

uses  cu_wheel, u_global, indiapi,
  {$ifdef mswindows}
     u_translation, Variants, comobj,
  {$endif}
   ExtCtrls, Forms, Classes, SysUtils;

type
T_ascomwheel = class(T_wheel)
 private
   {$ifdef mswindows}
   V: variant;
   FFilterNum: integer;
   stFilter: integer;
   {$endif}
   StatusTimer: TTimer;
   function Connected: boolean;
   procedure StatusTimerTimer(sender: TObject);
   procedure GetAscomFilterNames(var value:TStringList; var n: integer);
   function WaitFilter(maxtime:integer):boolean;
 protected
   procedure SetFilter(num:integer); override;
   function  GetFilter:integer; override;
   procedure SetFilterNames(value:TStringList); override;
   function  GetFilterNames:TStringList; override;
   procedure SetTimeout(num:integer); override;
   procedure SetCamera(value: TObject); override;
   function  GetStatus: TDeviceStatus; override;
 public
   constructor Create(AOwner: TComponent);override;
   destructor  Destroy; override;
   Procedure Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string=''); override;
   procedure Disconnect; override;
end;


implementation

constructor T_ascomwheel.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FWheelInterface:=ASCOM;
 StatusTimer:=TTimer.Create(nil);
 StatusTimer.Enabled:=false;
 StatusTimer.Interval:=1000;
 StatusTimer.OnTimer:=@StatusTimerTimer;
end;

destructor  T_ascomwheel.Destroy;
begin
 StatusTimer.Free;
 inherited Destroy;
end;

procedure T_ascomwheel.Connect(cp1: string; cp2:string=''; cp3:string=''; cp4:string='');
begin
 {$ifdef mswindows}
  try
  FStatus := devConnecting;
  Fdevice:=cp1;
  V:=Unassigned;
  V:=CreateOleObject(Fdevice);
  V.connected:=true;
  if V.connected then begin
     msg(rsConnected3);
     GetAscomFilterNames(FFilterNames,FFilterNum);
     FStatus := devConnected;
     if Assigned(FonStatusChange) then FonStatusChange(self);
     StatusTimer.Enabled:=true;
  end
  else
     Disconnect;
  except
    on E: Exception do msg('Connection error: ' + E.Message,0);
  end;
 {$endif}
end;

procedure T_ascomwheel.Disconnect;
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

function T_ascomwheel.Connected: boolean;
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

procedure T_ascomwheel.StatusTimerTimer(sender: TObject);
{$ifdef mswindows}
var fnum: integer;
    fnam:Tstringlist;
    i,n: integer;
    fnchanged:  boolean;
{$endif}
begin
 {$ifdef mswindows}
  if not Connected then begin
     FStatus := devDisconnected;
     if Assigned(FonStatusChange) then FonStatusChange(self);
  end
  else begin
    try
    fnum:=GetFilter;
    if fnum<>stFilter then begin
       stFilter:=fnum;
       if Assigned(FonFilterChange) then FonFilterChange(stFilter);
    end;
    fnam:=Tstringlist.Create;
    n:=0;
    GetAscomFilterNames(fnam,n);
    fnchanged:=n<>FFilterNum;
    if not fnchanged then
      for i:=0 to n-1 do
        if fnam[i]<>FFilterNames[i] then fnchanged:=true;
    if fnchanged then begin
       FFilterNum:=n;
       FFilterNames.Assign(fnam);
       if Assigned(FonFilterNameChange) then FonFilterNameChange(self);
    end;
    fnam.Free;
    except
     on E: Exception do msg('Error: ' + E.Message,0);
    end;
  end;
 {$endif}
end;

function T_ascomwheel.WaitFilter(maxtime:integer):boolean;
{$ifdef mswindows}
var count,maxcount:integer;
{$endif}
begin
 result:=true;
 {$ifdef mswindows}
 try
 if Connected  then begin
   maxcount:=maxtime div 100;
   count:=0;
   while (V.Position<0)and(count<maxcount) do begin
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


procedure T_ascomwheel.SetFilter(num:integer);
begin
 {$ifdef mswindows}
 if Connected and (num>0) then begin
   try
   msg(Format(rsSetFilterPos, [inttostr(num)]));
   V.Position:=num-1;
   WaitFilter(60000);
   except
    on E: Exception do msg('Set filter error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function  T_ascomwheel.GetFilter:integer;
begin
 result:=0;
 {$ifdef mswindows}
 if Connected then begin
   try
   result:=V.Position+1;
   except
    on E: Exception do msg('Get filter error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

procedure T_ascomwheel.SetFilterNames(value:TStringList);
{$ifdef mswindows}
var i:integer;
{$endif}
begin
 {$ifdef mswindows}
  if (value.Count=FFilterNum) then begin
    for i:=0 to value.Count-1 do begin
       FFilterNames[i]:=value[i];
    end;
  end;
 {$endif}
end;

function  T_ascomwheel.GetFilterNames:TStringList;
begin
  result:=FFilterNames;
end;

procedure T_ascomwheel.GetAscomFilterNames(var value:TStringList; var n: integer);
{$ifdef mswindows}
var fnames: array of WideString;
    i: integer;
{$endif}
begin
 {$ifdef mswindows}
 if Connected then begin
   try
   fnames:=V.Names;
   n:=Length(fnames);
   value.Clear;
   value.Add(Filter0);
   for i:=0 to n-1 do begin
     value.Add(string(fnames[i]));
   end;
   except
    on E: Exception do msg('List filter names error: ' + E.Message,0);
   end;
 end;
 {$endif}
end;

function  T_ascomwheel.GetStatus: TDeviceStatus;
begin
  result:=FStatus;
end;

procedure T_ascomwheel.SetTimeout(num:integer);
begin
 FTimeOut:=num;
end;

procedure T_ascomwheel.SetCamera(value: TObject);
begin
 Fcameraobj:=value;
end;

end.

