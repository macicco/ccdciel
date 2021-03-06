unit pu_sequenceoptions;

{$mode objfpc}{$H+}

interface

uses  u_translation,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, EditBtn;

const optnone=0; optstoptracking=1; optpark=2; optwarm=3; optscript=4;

type

  { Tf_sequenceoptions }

  Tf_sequenceoptions = class(TForm)
    BtnClose: TButton;
    Panel2: TPanel;
    UnattendedErrorScript: TCheckBox;
    MainOptions: TCheckGroup;
    Label1: TLabel;
    Panel1: TPanel;
    PanelScript: TPanel;
    ScriptList: TComboBox;
    ScriptListError: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure MainOptionsItemClick(Sender: TObject; Index: integer);
  private

  public
    procedure SetLang;
    procedure SetScript(sl:string);
    procedure SetErrorScript(sl:string);

  end;

var
  f_sequenceoptions: Tf_sequenceoptions;

implementation

{$R *.lfm}

{ Tf_sequenceoptions }

procedure Tf_sequenceoptions.FormCreate(Sender: TObject);
begin
  SetLang;
  MainOptions.Checked[optpark]:=true;
end;

procedure Tf_sequenceoptions.SetLang;
begin
  Caption:=rsTerminationO;
  MainOptions.Caption:=rsActionsToTak;
  MainOptions.Items[0]:=rsDoNothing;
  MainOptions.Items[1]:=rsStopTelescop2;
  MainOptions.Items[2]:=rsParkTheTeles2;
  MainOptions.Items[3]:=rsWarmTheCamer;
  MainOptions.Items[4]:=rsRunAScript;
  label1.Caption:=rsScript;
  UnattendedErrorScript.Caption:=rsRunAdditiona;
  BtnClose.Caption:=rsClose;
end;

procedure Tf_sequenceoptions.MainOptionsItemClick(Sender: TObject; Index: integer);
begin
  if (Index=optnone) then begin
     MainOptions.Checked[optnone]:=true;
     MainOptions.Checked[optstoptracking]:=false;
     MainOptions.Checked[optpark]:=false;
     MainOptions.Checked[optwarm]:=false;
     MainOptions.Checked[optscript]:=false;
  end;
  if (Index<>optnone) and MainOptions.Checked[Index] then begin
     MainOptions.Checked[optnone]:=false;
  end;
  if (Index=optstoptracking) and MainOptions.Checked[optstoptracking] then begin
     MainOptions.Checked[optpark]:=false;
  end;
  if (Index=optpark) and MainOptions.Checked[optpark] then begin
     MainOptions.Checked[optstoptracking]:=false;
  end;
  PanelScript.Visible:=MainOptions.Checked[optscript];
end;

procedure Tf_sequenceoptions.SetScript(sl:string);
var i:integer;
begin
  i:=ScriptList.Items.IndexOf(sl);
  if i>=0 then ScriptList.ItemIndex:=i;
end;

procedure Tf_sequenceoptions.SetErrorScript(sl:string);
var i:integer;
begin
  i:=ScriptListError.Items.IndexOf(sl);
  if i>=0 then ScriptListError.ItemIndex:=i;
end;


end.

