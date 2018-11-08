program bmpTool;

uses
  Vcl.Forms,
  mainFrm in 'mainFrm.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TmainFrom, mainFrom);
  Application.Run;
end.
