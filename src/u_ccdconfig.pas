unit u_ccdconfig;

{$mode objfpc}{$H+}

{
Copyright (C) 2015 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

interface

uses XMLConf, DOM,
  Classes, SysUtils;

type
  TCCDconfig = class(TXMLConfig)
     function  GetValue(const APath: String; const ADefault: String): String; overload;
     function  GetValue(const APath: String; const ADefault: Double): Double; overload;
     procedure SetValue(const APath: String; const AValue: String); overload;
     procedure SetValue(const APath: String; const AValue: Double); overload;
  end;

implementation

/////////////////////  TCCDconfig  /////////////////////////////////

function  TCCDconfig.GetValue(const APath: String; const ADefault: String): String;
begin
   Result:=string(GetValue(DOMString(APath),DOMString(ADefault)));
end;

procedure TCCDconfig.SetValue(const APath: String; const AValue: String);
begin
  SetValue(DOMString(APath),DOMString(AValue))
end;

function  TCCDconfig.GetValue(const APath: String; const ADefault: Double): Double; overload;
begin
  Result:=StrToFloatDef(String(GetValue(DOMString(APath),DOMString(FloatToStr(ADefault)))),ADefault);
end;

procedure TCCDconfig.SetValue(const APath: String; const AValue: Double); overload;
begin
  SetValue(DOMString(APath),DOMString(FloatToStr(AValue)))
end;

end.

