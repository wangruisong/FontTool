unit mainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  RectPoint = record
    row1, row2, row3, col1, col2: Integer;
  end;

type
  TmainFrom = class(TForm)
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    ButtonLoadFile: TButton;
    ButtonCut: TButton;
    Image1: TImage;
    Button360x40: TButton;
    Image2: TImage;
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    ButtonSaveAsTxt: TButton;
    procedure ButtonLoadFileClick(Sender: TObject);
    procedure ButtonCutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button360x40Click(Sender: TObject);
    procedure ButtonSaveAsTxtClick(Sender: TObject);
  private
    procedure MemoAddLine(ss: string);
    function FindRect(bmp: TBitmap): RectPoint;
    procedure ColorToBlackWhite(bmp: TBitmap);
    procedure BmpTrim(bmp: TBitmap);
    procedure SaveBmp8bitRowToTxt(bmp: TBitmap; fileName: string);
    procedure SaveBmp8BitColToTxt(bmp: TBitmap; fileName: string);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  mainFrom: TmainFrom;
  DefaultFileDir: string;
  RPoint: RectPoint;

implementation

{$R *.dfm}
procedure TmainFrom.ButtonSaveAsTxtClick(Sender: TObject);
var
  saveDlg: TSaveDialog;
  fPath: string;
begin

  saveDlg := TSaveDialog.Create(Self);
  saveDlg.Filter := '(*.txt)|*.txt|';
  saveDlg.DefaultExt := '.txt';
  saveDlg.InitialDir := ExtractFileDir(Application.ExeName) + '\sucai\';
  if saveDlg.Execute then
  begin
    MemoAddLine(saveDlg.FileName);
    if FileExists(saveDlg.FileName) then
      case MessageDlg('文件已存在，是否覆盖?', mtConfirmation, [mbYes, mbCancel], 0) of
        mrCancel:
          Exit;
      end;
    MemoAddLine(saveDlg.FileName);
    SaveBmp8bitRowToTxt(Image2.Picture.Bitmap, saveDlg.FileName);
    MemoAddLine('save finish');
  end;
  saveDlg.Free;

end;

procedure TmainFrom.BmpTrim(bmp: TBitmap);
var
  rp: RectPoint;
  rectSrc, rectDst: TRect;
begin
  rp := FindRect(bmp);

  rectSrc := Rect(rp.col1, rp.row2, rp.col2 + 1, rp.row3 + 1);
  rectDst := Rect(0, 0, rp.col2 - rp.col1 + 1, rp.row3 - rp.row2 + 1);
  bmp.Canvas.CopyRect(rectDst, bmp.Canvas, rectSrc);

  bmp.Width := rp.col2 - rp.col1 + 1;
  bmp.Height := rp.row3 - rp.row2 + 1;
end;

procedure TmainFrom.Button360x40Click(Sender: TObject);
var
  iWidth, iHeight: Integer;
  i, j, k: Integer;
  ii, jj: Integer;
  iStart, iEnd: Integer;
  rowEmpty, isEmpty: Boolean;
  tbmp: TBitmap;
  nk: integer;
begin
  tbmp := TBitmap.Create;
  tbmp.Width := 360;

  iWidth := Image1.Width;
  iHeight := Image1.Height;
  nk := 5;
  iStart := 0;
  iEnd := 0;
  rowEmpty := True;

  for j := 1 to iHeight - 2 do   //行，忽略边框
  begin
    k := 0;
    for i := 1 to iWidth - 2 do   //列，忽略边框
    begin
      if Image1.Canvas.Pixels[i, j] = clBlack then
      begin
        Inc(k);
        if rowEmpty then
        begin
          iStart := j;        // in
          rowEmpty := False;
        end;
        Break;
      end
      else    //white
      begin
        if (i > (iWidth - 5)) and (k = 0) then     //全白
        begin
          if (iStart <> 0) then  //起始点已存在
          begin
//            isEmpty := True;
//            for jj := j + 1 to j + nk do
//            begin
//              for ii := 1 to iWidth - 2 do
//              begin
//                if Image1.Canvas.Pixels[ii, jj] = clBlack then
//                begin
//                  isEmpty := False;
//                  Break;
//                end;
//              end;
//              if isEmpty then
//                Break;
//            end;
//            if not isEmpty then
//              Continue;
            iEnd := j;    //not on target
            rowEmpty := True;
          end;
          Break;
        end;
      end;
    end;

    {find target}
    if (iStart <> 0) and (iEnd <> 0) then
    begin
      MemoAddLine('height:' + IntToStr(iEnd - iStart));
      k := iEnd - iStart;
      k := (k div 2) * 2;
      k := (40 - k) div 2;
      if iStart - k < 0 then
        k := 0;

      Image1.Canvas.Pen.Color := clRed;
      Image1.Canvas.Pen.Style := psSolid;
      Image1.Canvas.Pen.Width := 1;
      Image1.Canvas.MoveTo(0, iStart - 1 - k);
      Image1.Canvas.LineTo(360, iStart - 1 - k);
      Image1.Canvas.Pen.Color := clGreen;
      Image1.Canvas.MoveTo(0, iEnd + k);
      Image1.Canvas.LineTo(360, iEnd + k);

      tbmp.Height := tbmp.Height + 40;
      for ii := 0 to 40 - 1 do
        for jj := 1 to 360 do
          tbmp.Canvas.Pixels[jj, tbmp.Height - 40 + ii] := Image1.Canvas.Pixels[jj, iStart - k + ii];

      iStart := 0;
      iEnd := 0;
    end;
  end;

  Image2.Height := tbmp.Height;
  Image2.Width := tbmp.Width;
  Image2.Left := Image1.Left + Image1.Width + 10;
  Image2.Picture.Bitmap.Assign(tbmp);
  tbmp.Free;
  MemoAddLine(Format('Width:%d,Heigh:%d', [Image2.Width, Image2.Height]));
end;

procedure TmainFrom.ButtonCutClick(Sender: TObject);
begin
  BmpTrim(Image1.Picture.Bitmap);
  Image1.Width := Image1.Picture.Width;
  Image1.Height := Image1.Picture.Height;

  MemoAddLine('image==' + Format('Width:%d,Heigh:%d', [Image1.Width, Image1.Height]));
  MemoAddLine('Picture==' + Format('Width:%d,Heigh:%d', [Image1.Picture.Width, Image1.Picture.Height]));
  MemoAddLine('Bitmap==' + Format('Width:%d,Heigh:%d', [Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height]));

end;

function TmainFrom.FindRect(bmp: TBitmap): RectPoint;
var
  iWidth, iHeight: Integer;
  i, j, k, num: Integer;
begin

  iWidth := bmp.Width;
  iHeight := bmp.Height;

  with Result do
  begin
    row1 := 0;
    row2 := 0;
    row3 := 0;
    col1 := 0;
    col2 := 0;
  end;
  num := 0;

  {find row}
  for j := 0 to iHeight - 1 do
  begin
    k := 0;
    for i := 0 to iWidth - 1 do
    begin
      if Image1.Canvas.Pixels[i, j] = clBlack then
        Inc(k)
      else
        Break;
      if k > iWidth div 2 then // row line  ,on line
      begin
        if num = 0 then
          Result.row1 := j;
        if num = 1 then
          Result.row2 := j;
        if num = 2 then
          Result.row3 := j;
        inc(num);
        Break;
      end;
    end;
    if Result.row3 <> 0 then
      Break;
  end;

  {find colum}
  num := 0;
  for i := 0 to iWidth - 1 do
  begin
    k := 0;
    for j := Result.row2 to Result.row2 + 50 do
    begin
      if Image1.Canvas.Pixels[i, j] = clBlack then
        inc(k);
      if k > 40 then
      begin
        if num = 0 then
          Result.col1 := i;      //col line on line
        if num = 1 then
          Result.col2 := i;
        Inc(num);
        Break;
      end;
    end;
    if Result.col2 <> 0 then
      Break;
  end;

  {用画刷绘制边框}
  bmp.Canvas.Brush.Color := clRed;
  bmp.Canvas.Brush.Style := bsSolid;
  bmp.Canvas.FrameRect(Rect(Result.col1, Result.row2, Result.col2 + 1, Result.row3 + 1));
end;

procedure TmainFrom.FormCreate(Sender: TObject);
begin
  DefaultFileDir := ExtractFilePath(Application.ExeName) + 'sucai\';
end;

procedure TmainFrom.MemoAddLine(ss: string);
begin
  Memo1.Lines.Add(ss);
  Memo1.SelStart := Length(Memo1.Text) - 1;
  Memo1.SelLength := 0;
end;

procedure TmainFrom.SaveBmp8BitColToTxt(bmp: TBitmap; fileName: string);
var
  iWidth, iHeight: Integer;
  i, j, k: Integer;
  bNum: Byte;
  ss: string;
  tf: TextFile;
begin

end;

procedure TmainFrom.SaveBmp8bitRowToTxt(bmp: TBitmap; fileName: string);
var
  iWidth, iHeight: Integer;
  i, j, k, k1, mm: Integer;
  bNum: Byte;
  ss: string;
  tf: TextFile;
begin
  iWidth := bmp.Width;
  iHeight := bmp.Height;
  AssignFile(tf, fileName);
  Rewrite(tf);

  if (iWidth mod 8) <> 0 then
  begin
    showMessage('Image [WIDTH] MUST be 8x.....');
    Exit;
  end;

  for j := 0 to iHeight - 1 do
  begin
    for i := 0 to (iWidth - 8) div 8 do
    begin
      k := 1;
      k1 := 0;
      for mm := 0 to 7 do
      begin
        if bmp.Canvas.Pixels[i * 8 + mm, j] <> clWhite then
          k1 := k1 + k;
        k := k + k;
      end;
      ss := ss + '0x' + IntToHex(k1, 2) + ',';
    end;
    Writeln(tf, ss);
    ss := '';
  end;
end;

procedure TmainFrom.ButtonLoadFileClick(Sender: TObject);
var
  openDlg: TOpenDialog;
begin
  openDlg := TOpenDialog.Create(Self);
  openDlg.InitialDir := ExtractFilePath(Application.ExeName);
  if DirectoryExists(openDlg.InitialDir) then
  begin
    openDlg.Filter := 'Bitmap|*.bmp|jpg|*.jpg|';
    if openDlg.Execute then
    begin
      MemoAddLine(openDlg.FileName);

      Image1.Picture.Bitmap.LoadFromFile(openDlg.FileName);

      MemoAddLine('image==' + Format('Width:%d,Heigh:%d', [Image1.Width, Image1.Height]));
      MemoAddLine('Picture==' + Format('Width:%d,Heigh:%d', [Image1.Picture.Width, Image1.Picture.Height]));
      MemoAddLine('Bitmap==' + Format('Width:%d,Heigh:%d', [Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height]));

      ColorToBlackWhite(Image1.Picture.Bitmap);

      Image1.Width := Image1.Picture.Width;
      Image1.Height := Image1.Picture.Height;
    end;
  end;

  openDlg.Free;
end;

procedure TmainFrom.ColorToBlackWhite(bmp: TBitmap);
var
  iWidth, iHeight: Integer;
  i, j, k, num: Integer;
begin
  iWidth := bmp.Width;
  iHeight := bmp.Height;
  MemoAddLine('ColorToBlackWhite==' + Format('Width:%d,Heigh:%d', [bmp.Width, bmp.Height]));
  for j := 0 to iHeight - 1 do
    for i := 0 to iWidth - 1 do
      if bmp.Canvas.Pixels[i, j] = $ffffff then
        bmp.Canvas.Pixels[i, j] := clWhite
      else
        bmp.Canvas.Pixels[i, j] := clBlack;
end;

end.

