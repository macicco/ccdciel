unit fu_rotator;

{$mode objfpc}{$H+}

{
Copyright (C) 2017 Patrick Chevalley

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

uses  UScaleDPI, u_global, Graphics,
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls;

type

  { Tf_rotator }

  Tf_rotator = class(TFrame)
    BtnRotate: TButton;
    Angle: TEdit;
    BtnHalt: TButton;
    Reverse: TCheckBox;
    Label6: TLabel;
    led: TShape;
    Panel1: TPanel;
    StaticText1: TStaticText;
    procedure BtnHaltClick(Sender: TObject);
    procedure BtnRotateClick(Sender: TObject);
    procedure ReverseChange(Sender: TObject);
  private
    { private declarations }
    FonRotate: TNotifyEvent;
    FonReverse: TNotifyEvent;
    FonHalt: TNotifyEvent;
  public
    { public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;
    procedure SetCalibrated(onoff:boolean);
    property onRotate: TNotifyEvent read FonRotate write FonRotate;
    property onReverse: TNotifyEvent read FonReverse write FonReverse;
    property onHalt: TNotifyEvent read FonHalt write FonHalt;
  end;

implementation

{$R *.lfm}

{ Tf_rotator }

constructor Tf_rotator.Create(aOwner: TComponent);
begin
 inherited Create(aOwner);
 ScaleDPI(Self);
end;

destructor  Tf_rotator.Destroy;
begin
 inherited Destroy;
end;

procedure Tf_rotator.SetCalibrated(onoff:boolean);
begin
 if onoff then begin
   led.Brush.Color:=clLime;
   led.Hint:='Calibrated';
   Angle.Hint:='Calibrated';
 end
 else begin
   led.Brush.Color:=clRed;
   led.Hint:='Uncalibrated';
   Angle.Hint:='Uncalibrated';
 end;
end;

procedure Tf_rotator.BtnRotateClick(Sender: TObject);
begin
   if Assigned(FonRotate) then FonRotate(self);
end;

procedure Tf_rotator.BtnHaltClick(Sender: TObject);
begin
   if Assigned(FonHalt) then FonHalt(self);
end;

procedure Tf_rotator.ReverseChange(Sender: TObject);
begin
   if Assigned(FonReverse) then FonReverse(self);
end;

end.
