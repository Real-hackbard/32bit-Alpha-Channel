unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, jpeg, ExtCtrls, ComCtrls, crBitmap32,
  XPMan, PNGImage, GIFImg, BmpGrD12, Bmp2tiff, ShellApi;

type
  TForm1 = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    btnChangeImg: TButton;
    ckb_NoAlpha: TCheckBox;
    TrackBar2: TTrackBar;
    ckb_Center: TCheckBox;
    ckb_Proportional: TCheckBox;
    ckb_Stretched: TCheckBox;
    ckb_Transparent: TCheckBox;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Button1: TButton;
    CheckBox5: TCheckBox;
    TrackBar1: TTrackBar;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Panel2: TPanel;
    ScrollBar1: TScrollBar;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Image2: TImage;
    ScrollBar2: TScrollBar;
    StatusBar1: TStatusBar;
    GroupBox3: TGroupBox;
    Button2: TButton;
    SaveDialog1: TSaveDialog;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    RadioGroup1: TRadioGroup;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    Image3: TImage;
    CheckBox10: TCheckBox;
    Image4: TImage;
    Bevel1: TBevel;
    procedure btnChangeImgClick(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ckb_NoAlphaClick(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
  private
    { Déclarations privées }
    FIsPicture     : Boolean;
    FIsGrayPicture : Boolean;

  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
function DeleteFile(const AFile: string): boolean;
var
 sh: SHFileOpStruct;
begin
 ZeroMemory(@sh, sizeof(sh));
 with sh do
   begin
   Wnd := Application.Handle;
   wFunc := fo_Delete;
   pFrom := PChar(AFile +#0);
   fFlags := fof_Silent or fof_NoConfirmation;
   end;
 result := SHFileOperation(sh) = 0;
end;

function InvertBitmap(MyBitmap: TBitmap): TBitmap;
var
  x, y: Integer;
  ByteArray: PByteArray;
begin
  MyBitmap.PixelFormat := pf24Bit;
  for y := 0 to MyBitmap.Height - 1 do
  begin
    ByteArray := MyBitmap.ScanLine[y];
    for x := 0 to MyBitmap.Width * 3 - 1 do
    begin
      ByteArray[x] := 255 - ByteArray[x];
    end;
  end;
  Result := MyBitmap;
end;

procedure ImageGrayScale(var AnImage: TImage);
var
  JPGImage: TJPEGImage;
  BMPImage: TBitmap;
  MemStream: TMemoryStream;
begin
  BMPImage := TBitmap.Create;
  try
    BMPImage.Width  := AnImage.Picture.Bitmap.Width;
    BMPImage.Height := AnImage.Picture.Bitmap.Height;

    JPGImage := TJPEGImage.Create;
    try
      JPGImage.Assign(AnImage.Picture.Bitmap);
      JPGImage.CompressionQuality := 100;
      JPGImage.Compress;
      JPGImage.Grayscale := True;

      BMPImage.Canvas.Draw(0, 0, JPGImage);

      MemStream := TMemoryStream.Create;
      try
        BMPImage.SaveToStream(MemStream);
        //you need to reset the position of the MemoryStream to 0
        MemStream.Position := 0;

        AnImage.Picture.Bitmap.LoadFromStream(MemStream);
        AnImage.Refresh;
      finally
        MemStream.Free;
      end;
    finally
      JPGImage.Free;
    end;
  finally
    BMPImage.Free;
  end;
end;

procedure BitmapFileToPNG(const Source, Dest: String);
var
  Bitmap: TBitmap;
  PNG: TPNGObject;
begin
  Bitmap := TBitmap.Create;
  PNG := TPNGObject.Create;
  {In case something goes wrong, free booth Bitmap and PNG}
  try
    Bitmap.LoadFromFile(Source);
    //Convert data into png
    PNG.Assign(Bitmap);

    if Form1.CheckBox6.Checked = true then begin
      PNG.TransparentColor := clBlack;
      PNG.Transparent := true;
    end;

    if Form1.CheckBox7.Checked = true then begin
      PNG.CompressionLevel := 9;
    end;

    PNG.SaveToFile(Dest);
  finally
    Bitmap.Free;
    PNG.Free;
  end
end;

procedure Bmp2Jpeg(const BmpFileName, JpgFileName: string);
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
begin
  Bmp := TBitmap.Create;
  Jpg := TJPEGImage.Create;
  try
    Bmp.LoadFromFile(BmpFileName);
    Jpg.Assign(Bmp);

    if Form1.CheckBox6.Checked = true then begin
      JPG.Transparent := true;
    end;

    if Form1.CheckBox7.Checked = true then begin
      JPG.CompressionQuality := 50;
      JPG.Compress;
    end;

    Jpg.SaveToFile(JpgFileName);
  finally
    Jpg.Free;
    Bmp.Free;
  end;
end;

procedure TForm1.btnChangeImgClick(Sender: TObject);
var MemFilter: string;
    aImg: TImage;
begin
  MemFilter := OpenPictureDialog1.Filter;
  aImg := Image2;

  if TComponent(Sender).Tag > 4 then
    aImg := Image1
  else
    OpenPictureDialog1.Filter := 'Bitmap (*.bmp)|*.bmp';

  if OpenPictureDialog1.Execute then
  begin
    aImg.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    ckb_NoAlphaClick(Sender);
    TrackBar2.OnChange(sender);
    //Image2.ClientHeight := aImg.ClientHeight;
    //Image2.ClientWidth := aImg.ClientWidth;
    Image4.Picture.Bitmap.Assign(Image2.Picture.Bitmap);
  end;

  if TComponent(Sender).Tag = 5 then begin
  StatusBar1.Panels[1].Text := ExtractFileName(OpenPictureDialog1.FileName);
  end;

  if TComponent(Sender).Tag = 0 then begin
  StatusBar1.Panels[3].Text := ExtractFileName(OpenPictureDialog1.FileName);
  end;

  ScrollBar1.Max := Image1.Width;
  ScrollBar2.Max := Image1.Height;

  OpenPictureDialog1.Filter := MemFilter;


end;

procedure TForm1.TrackBar2Change(Sender: TObject);
var aImg: TImage;
    aTkb: TTrackBar;
begin
  aImg := Image2;
  aTkb := TrackBar2;
  if TComponent(Sender).Tag > 4 then
  begin
    aImg := Image1;
    aTkb := TrackBar1;
  end;
  if (aImg.Picture.Graphic is TBitmap) then
    (aImg.Picture.Graphic as TBitmap).Opacity := aTkb.Position;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;

  OpenPictureDialog1.FileName := ExtractFilePath(Application.ExeName) +
                            'Img\Saturn.bmp';

  Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  Image4.Picture.Bitmap.Assign(Image2.Picture.Bitmap);

  ScrollBar1.Max := Image1.Width;
  ScrollBar2.Max := Image1.Height;

  ScrollBar1.Position := 100;
  ScrollBar2.Position := 100;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CheckBox2.Checked := false;
  TrackBar2.Position := 100;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  Image2.Left := ScrollBar1.Position;
  StatusBar1.Panels[5].Text := IntToStr(ScrollBar1.Position) + 'x' +
                               IntToStr(ScrollBar2.Position) + ' px';
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  Image2.Top := ScrollBar2.Position;
  StatusBar1.Panels[5].Text := IntToStr(ScrollBar1.Position) + 'x' +
                               IntToStr(ScrollBar2.Position) + ' px';
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  bmp1, bmp2: TBitmap;
  Jpg: TJPEGImage;
  GIF : TGifImage;
  Image : TImage;
  Ext: TGIFGraphicControlExtension;
begin
    bmp1 := TBitmap.Create;
    bmp2 := TBitmap.Create;

    bmp1.Assign(Image1.Picture.Bitmap);
    bmp2.Assign(Image2.Picture.Bitmap);

    bmp2.Width := Image2.Picture.Bitmap.Width;
    bmp2.Height := Image2.Picture.Bitmap.Height;

    bmp2.Opacity := TrackBar2.Position;
    bmp1.Opacity := TrackBar1.Position;

    // draw bmp2 over bmp1
    bmp1.Canvas.Draw(ScrollBar1.Position, ScrollBar2.Position, bmp2);
    bmp1.Opacity := TrackBar1.Position;

    // Pixel Bit only for Bitmap
    case RadioGroup1.ItemIndex of
    0 : bmp1.PixelFormat := pf8bit;
    1 : bmp1.PixelFormat := pf16bit;
    2 : bmp1.PixelFormat := pf24bit;
    3 : Bmp24To32(bmp1);
    end;

  if SaveDialog1.Execute then begin
  try
    if SaveDialog1.FilterIndex = 1 then begin
      bmp1.SaveToFile(SaveDialog1.FileName + '.bmp');
    end;

    if SaveDialog1.FilterIndex = 2 then begin
      bmp1.SaveToFile(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp');
      Bmp2Jpeg(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp',
               SaveDialog1.FileName + '.jpg');
    end;

    if SaveDialog1.FilterIndex = 3 then begin
      bmp1.SaveToFile(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp');
      BitmapFileToPNG(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp',
                      SaveDialog1.FileName + '.png');
    end;

    if SaveDialog1.FilterIndex = 4 then begin
        Image := TImage.Create(self);
        Image.Picture.Bitmap.Assign(bmp1);
        GIF := TGIFImage.Create;
        try
          // Copy Bitmap Pixel to GIF Data
          GIF.Assign(bmp1);
          // Create GIF File Image

          if CheckBox6.Checked = true then begin
            // Create an extension to set the transparency flag
            Ext := TGIFGraphicControlExtension.Create(GIF.Images[0]);
            Ext.Transparent := True;

            // Set transparent color to lower left pixel color
            Ext.TransparentColorIndex := GIF.Images[0].Pixels[0, GIF.Height-1];

            // Set transparent color to lower left pixel color
            //Ext.TransparentColorIndex := GIF.Images[0].Pixels[0, GIF.Height-1];
          end;

          GIF.SaveToFile(SaveDialog1.FileName + '.gif')
        finally
          GIF.Free;
          Image.Free;
        end;
    end;

    if SaveDialog1.FilterIndex = 5 then begin
        // Save Image as TIFF in the same path with extension '.TIF'
        try
          bmp1.SaveToFile(SaveDialog1.FileName + '.bmp');
          Sleep(50);
          WriteTiffToFile( ChangeFileExt(SaveDialog1.FileName + '.c', '.tif'),
               bmp1 );
        except
          DeleteFile(SaveDialog1.FileName + '.bmp');
        end;
    end;


  finally
    bmp1.Free;
    bmp2.Free;
  end;

  END;

  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox10Click(Sender: TObject);
var
  bmp : TBitmap;
begin
  try
    bmp := TBitmap.Create;
    bmp.Assign(Image1.Picture.Bitmap);
    Image1.Picture.Bitmap := InvertBitmap(bmp);
    Image1.Invalidate;
  finally
    bmp.Free;
  end;
end;

procedure TForm1.CheckBox8Click(Sender: TObject);
var
  ABitmap : TBitmap;
begin
  if CheckBox9.Checked = true  then CheckBox9.Checked := false;
  if CheckBox10.Checked = true  then CheckBox10.Checked := false;

  if CheckBox8.Checked = true then begin
    ABitmap := TBitmap.Create;

      try
        if ConvertToGrayBitmap(Image1.Picture.Bitmap, ABitmap) then begin
          FIsGrayPicture := True;
          Image1.Picture.Bitmap.Assign(ABitmap);
        end;
      finally
        ABitmap.Free;
      end;

  end else begin
      Image1.Picture.Bitmap.LoadFromFile(OpenPictureDialog1.FileName);
      FIsPicture:=True;
  end;
end;

procedure TForm1.CheckBox9Click(Sender: TObject);
var
  ABitmap : TBitmap;
  APalette : TFullPalette;
  i : Integer;
  x : Double;
begin
  if CheckBox8.Checked = true then CheckBox8.Checked := false;
  if CheckBox10.Checked = true  then CheckBox10.Checked := false;

  if CheckBox9.Checked = true then begin
  //if Not FIsGrayPicture then Exit;
  { Segment 0 }
  x:=256 / 42;
  for i:=0 to 41 do with APalette[i] do begin     {   0 ..  41 }
    rgbBlue :=0;
    rgbGreen:=Trunc(i*x);
    rgbRed  :=255;
  end;
  { Segment 1 }
  x:=256 / 43;
  for i:=0 to 42 do with APalette[i+42] do begin  {  42 ..  84 }
    rgbBlue :=0;
    rgbGreen:=255;
    rgbRed  :=Trunc((42-i)*x);
  end;
  { Segment 2 }
  x:=256 / 43;
  for i:=0 to 42 do with APalette[i+85] do begin  {  85 .. 127 }
    rgbBlue :=Trunc(i*x);
    rgbGreen:=255;
    rgbRed  :=0;
  end;
  { Segment 3 }
  x:=256 / 42;
  for i:=0 to 41 do with APalette[i+128] do begin { 128 .. 169 }
    rgbBlue :=255;
    rgbGreen:=Trunc((41-i)*x);
    rgbRed  :=0;
  end;
  { Segment 4 }
  x:=256 / 43;
  for i:=0 to 42 do with APalette[i+170] do begin { 170 .. 212 }
    rgbBlue :=255;
    rgbGreen:=0;
    rgbRed  :=Trunc(i*x);
  end;
  { Segment 5 }
  x:=256 / 43;
  for i:=0 to 42 do with APalette[i+213] do begin { 213 .. 255 }
    rgbBlue :=Trunc((42-i)*x);
    rgbGreen:=0;
    rgbRed  :=255;
  end;

    try
    ABitmap:=TBitmap.Create;
        if ConvertToGrayBitmap(Image1.Picture.Bitmap, ABitmap) then begin
          FIsGrayPicture := True;
          Image1.Picture.Bitmap.Assign(ABitmap);
        end;
      finally
    //    ABitmap.Free;
      end;

  try
    if DrawPalette(ABitmap, APalette, Image3.Height) then begin
      Image3.Picture.Bitmap.Assign(ABitmap);
    end;
    ABitmap.Assign(Image1.Picture.Bitmap);
    if ChangePalette(ABitmap,APalette) then begin
      Image1.Picture.Bitmap.Assign(ABitmap);
    end;
  finally
    ABitmap.Free;
  end;

  end else begin
  Image1.Picture.Bitmap.LoadFromFile(OpenPictureDialog1.FileName);
  FIsPicture:=True;
  end;

end;

procedure TForm1.ckb_NoAlphaClick(Sender: TObject);
var aImg: TImage;
begin    
  aImg := Image2;
  if TComponent(Sender).Tag > 4 then
    aImg := Image1;
  with aImg do
  begin
    case TComponent(Sender).Tag of
      0: begin
           if (Picture.Graphic is TBitmap) then
             (Picture.Graphic as TBitmap).NoAlpha := ckb_NoAlpha.Checked;
         end;
      5: begin
           if (Picture.Graphic is TBitmap) then
             (Picture.Graphic as TBitmap).NoAlpha := CheckBox5.Checked;
         end;
      1, 6: Center := TCheckBox(Sender).Checked;
      2, 7: Proportional := TCheckBox(Sender).Checked;
      3, 8: Stretch := TCheckBox(Sender).Checked;
      4, 9: Transparent := TCheckBox(Sender).Checked;
    end;
    Invalidate;
  end;
end;

end.
