unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.Shell.ShellCtrls, jpeg, Vcl.ExtCtrls, crBitmap32,
  PNGImage, GIFImg, BmpGrD12, Bmp2tiff, ShellApi, Vcl.Menus,
  Vcl.Samples.Spin, Vcl.ExtDlgs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Button3: TButton;
    CheckBox15: TCheckBox;
    TrackBar2: TTrackBar;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
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
    Bevel1: TBevel;
    PopupMenu1: TPopupMenu;
    Open1: TMenuItem;
    Mask1: TMenuItem;
    N1: TMenuItem;
    Panel3: TMenuItem;
    Export1: TMenuItem;
    N2: TMenuItem;
    TrackBar3: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    Button4: TButton;
    SpinEdit1: TSpinEdit;
    Label5: TLabel;
    Button5: TButton;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    Image4: TImage;
    Stretched1: TMenuItem;
    N3: TMenuItem;
    Center1: TMenuItem;
    Proportional1: TMenuItem;
    ransparent1: TMenuItem;
    Grayscale1: TMenuItem;
    Negativ1: TMenuItem;
    Infrared1: TMenuItem;
    procedure Button3Click(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox15Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Mask1Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Stretched1Click(Sender: TObject);
    procedure Center1Click(Sender: TObject);
    procedure Proportional1Click(Sender: TObject);
    procedure ransparent1Click(Sender: TObject);
    procedure Grayscale1Click(Sender: TObject);
    procedure Negativ1Click(Sender: TObject);
    procedure Infrared1Click(Sender: TObject);
  private
    { Declarations privates }
    FIsPicture     : Boolean;
    FIsGrayPicture : Boolean;

  public
    { Declarations public }
  end;

var
  Form1: TForm1;
  bgImg : TBitmap;  // main bitmap to restore the original pixels

implementation

{$R *.dfm}
// Changing the mask size
procedure StretchMask(const src, dest: TGraphic;
  DestWidth, DestHeight: integer; Smooth: Boolean = true);
var
  temp, aCopy: TBitmap;
  faktor: double;
begin
  // check whether the dimensions match
  Assert(Assigned(src) and Assigned(dest));
  if (src.Width = 0) or (src.Height = 0) then
    raise Exception.CreateFmt('Invalid source dimensions: %d x %d',[src.Width, src.Height]);

  // Calculate if the width matches.
  if src.Width > DestWidth then
    begin
      faktor := DestWidth / src.Width;
      if (src.Height * faktor) > DestHeight then
        faktor := DestHeight / src.Height;
    end
  else
    begin
      // equalize the amount as a percentage.
      faktor := DestHeight / src.Height;
      if (src.Width * faktor) > DestWidth then
        faktor := DestWidth / src.Width;
    end;
  try
    // create bitmap
    aCopy := TBitmap.Create;
    try
      //bitmap pixel format
      aCopy.PixelFormat := pf24Bit;
      // copy source pixel
      aCopy.Assign(src);
      temp := TBitmap.Create;
      try
        // Copy the x/y factors as a percentage and round them down.
        temp.Width := round(src.Width * faktor);
        temp.Height := round(src.Height * faktor);

        { Bitmap smooth scaling refers to resizing a raster image while
          applying resampling algorithms to blend pixel colors, which
          prevents jagged edges ("aliasing") and blocky artifacts. }
        if Smooth then
          SetStretchBltMode(temp.Canvas.Handle, HALFTONE);
        StretchBlt(temp.Canvas.Handle, 0, 0, temp.Width, temp.Height,
          aCopy.Canvas.Handle, 0, 0, aCopy.Width, aCopy.Height, SRCCOPY);
        dest.Assign(temp);
      finally
        temp.Free;
      end;
    finally
      aCopy.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), nil, MB_OK or MB_ICONERROR);
  end;
end;

// deleting generated files
function DeleteFile(const AFile: string): boolean;
var
  { to perform complex file operations such as copying, moving, renaming,
    or deleting via the Windows shell}
  sh: SHFileOpStruct;
begin
  // clear memory
  ZeroMemory(@sh, sizeof(sh));
  with sh do
   begin
     Wnd := Application.Handle;
     wFunc := fo_Delete;
     pFrom := PChar(AFile +#0);
     // Display of the standard Windows progress bar (copy/delete dialog)
     fFlags := fof_Silent or fof_NoConfirmation;
   end;
  // Pass the commands to the shell.
  result := SHFileOperation(sh) = 0;
end;

// create negativ picture
function InvertBitmap(MyBitmap: TBitmap): TBitmap;
var
  x, y: Integer;
  ByteArray: PByteArray;  // static byte array
begin
  MyBitmap.PixelFormat := pf24Bit;
  for y := 0 to MyBitmap.Height - 1 do
  begin
    // Reading or modifying an image's pixel data directly in memory
    ByteArray := MyBitmap.ScanLine[y];
    for x := 0 to MyBitmap.Width * 3 - 1 do
    begin
      // Copying byte array data as quickly as possible
      ByteArray[x] := 255 - ByteArray[x];
    end;
  end;
  Result := MyBitmap;
end;

// calculate picture to grayscale
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
      // copy bitmap to jpg
      JPGImage.Assign(AnImage.Picture.Bitmap);
      // set the compress quality 0..100 (0 = lowest)
      JPGImage.CompressionQuality := 100;
      // aktivate compress function
      JPGImage.Compress;
      // calculate grayscale pixel
      JPGImage.Grayscale := True;
      // convert jpg to bitmap pixel
      BMPImage.Canvas.Draw(0, 0, JPGImage);

      MemStream := TMemoryStream.Create;
      try
        BMPImage.SaveToStream(MemStream);
        //you need to reset the position of the MemoryStream to 0
        MemStream.Position := 0;
        // copy from memory to image
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

// convert bitmap to png image
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

    if Form1.CheckBox6.Checked = true then
    begin
      // set png transparent
      PNG.TransparentColor := clBlack;
      PNG.Transparent := true;
    end;

    if Form1.CheckBox7.Checked = true then
    begin
      // compress png 1..9 level
      PNG.CompressionLevel := 9;
    end;

    // save png picture
    PNG.SaveToFile(Dest);
  finally
    Bitmap.Free;
    PNG.Free;
  end
end;

// convert jpg/ jpeg to bitmap
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

    // jpg transparent
    if Form1.CheckBox6.Checked = true then
    begin
      JPG.Transparent := true;
    end;

    if Form1.CheckBox7.Checked = true then
    begin
      // set the compress quality 0..100 (0 = lowest)
      JPG.CompressionQuality := 75;
      // aktivate compress mode
      JPG.Compress;
    end;

    Jpg.SaveToFile(JpgFileName);
  finally
    Jpg.Free;
    Bmp.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  MemFilter: string;
  aImg: TImage;
begin
  // Pass filter data to the Windows dialog.
  MemFilter := OpenPictureDialog1.Filter;
  // copy mask picture pixel
  aImg := Image2;

  { Check whether a background or a mask is being loaded;
    the button for the background has tag=0, and the mask has tag=5. }
  if TComponent(Sender).Tag > 4 then
    aImg := Image1
  else
    { Only bitmaps are accepted; alpha channels must be present for the mask. }
    OpenPictureDialog1.Filter := 'Bitmap (*.bmp)|*.bmp';

  if OpenPictureDialog1.Execute then
  begin
    aImg.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    // update alpha status
    CheckBox15Click(Sender);
    // update opacity
    TrackBar2.OnChange(sender);

    // Adjust the image size to the loaded images.
    Image2.ClientHeight := aImg.ClientHeight;
    Image2.ClientWidth := aImg.ClientWidth;

    // Copy the mask into the preview.
    Image4.Picture.Bitmap.Assign(Image2.Picture.Bitmap);

    // Pass the maximum width of the scale TrackBar.
    TrackBar3.Position := Image2.Width;
    CheckBox15.Enabled := true;
  end;

  // loading the mask
  if TComponent(Sender).Tag = 5 then
  begin
    // to return to the original maske
    bgImg.LoadFromFile(OpenPictureDialog1.FileName);
    StatusBar1.Panels[1].Text := ExtractFileName(OpenPictureDialog1.FileName);
  end;

  // background image
  if TComponent(Sender).Tag = 0 then
  begin
    StatusBar1.Panels[3].Text := ExtractFileName(OpenPictureDialog1.FileName);
  end;

  { Pass the maximum background image size to the scrollbars on the side of
    the form so that the mask can be dragged over the entire image. }
  ScrollBar1.Max := Image1.Width;
  ScrollBar2.Max := Image1.Height;
  OpenPictureDialog1.Filter := MemFilter;
end;

{ Here, a specific number of dynamic images are randomly generated as
  masks over the background. }
procedure TForm1.Button4Click(Sender: TObject);
var
  DynamicImage : TImage;
  path : TArray<string>;
  Index : Integer;
  i : integer;
begin
    // List of image files to be selected at random
    path := TArray<string>.Create(
      ExtractFilePath(Application.ExeName) + 'Mask\BubleBlue.bmp',
      ExtractFilePath(Application.ExeName) + 'Mask\BublePink.bmp'
      // Integrate as many images as you want.
    );

  // Number of masks to be generated
  for i := 1 to SpinEdit1.Value do
  begin
    // Initialize the random number generator once.
    Randomize;
    // Determine a random index between 0 and the number of paths minus 1.
    Index := Random(Length(path));
    // Creating the TImage component at runtime
    DynamicImage := TImage.Create(Self);
    try
      // Assign the visual element to a container (e.g., the form or a panel).
      // draw first the graphic on form not on background image
      DynamicImage.Parent := Form1.Parent;
      DynamicImage.Left := 0;
      DynamicImage.Top := 0;
      //DynamicImage.Width := 50;
      //DynamicImage.Height := 50;

      { VCL method primarily used to dynamically scale forms and UI controls
        for different monitor resolutions, known as Pixels Per Inch (PPI). }
      DynamicImage.ScaleForPPI(0);
      // format picture
      DynamicImage.Stretch := True;
      DynamicImage.Proportional := True;
      DynamicImage.Transparent := true;

      // Load the randomly selected image
      DynamicImage.Picture.LoadFromFile(path[Index]);
      // check the background image is bitmap or out.
      if ExtractFileExt(OpenPictureDialog1.FileName) <> '.bmp' then
      begin
        Beep;
        MessageDlg('The background image must be in bitmap format for this function.',
                      mtWarning, [mbOK], 0);
        DynamicImage.Free;  // remove pixel
        Exit;               // go out when not
      end;
      // Paint the mask onto the background at random.
      Image1.Canvas.Draw(Random(Image1.Width), Random(Image1.Height),
                          DynamicImage.Picture.Graphic);
      // remove pixel from memory
      DynamicImage.Picture.Graphic := nil;
    except
      // Ensure that the object is released in the event of errors (e.g., file missing).
      DynamicImage.Free;
    end;
  end;
end;

{ Remove the dynamic images from the background image, regardless of how
  many there are. }
procedure TForm1.Button5Click(Sender: TObject);
begin
  Image1.Picture.Graphic := nil;
  Image1.Picture.Bitmap.Assign(bgImg);
end;

// Set the alpha channel value.
procedure TForm1.TrackBar2Change(Sender: TObject);
var
  aImg: TImage;
  aTkb: TTrackBar;
begin
  // copy mask picture pixel
  aImg := Image2;
  aTkb := TrackBar2;

  // Check whether the mask is being processed—i.e., tag=5.
  if TComponent(Sender).Tag > 4 then
  begin
    aImg := Image1;
    aTkb := TrackBar1;
  end;
  if (aImg.Picture.Graphic is TBitmap) then
    (aImg.Picture.Graphic as TBitmap).Opacity := aTkb.Position;
end;

// Here, the enlargement or reduction is processed either smoothly or sharply.
procedure TForm1.TrackBar3Change(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  if CheckBox17.Checked = true then
  begin
    // with smooth
    StretchMask(Image4.Picture.Bitmap, Image2.Picture.Bitmap,
      TrackBar3.Position, TrackBar3.Position,  true);
  end else begin
    // without smooth
    StretchMask(Image4.Picture.Bitmap, Image2.Picture.Bitmap,
      TrackBar3.Position, TrackBar3.Position,  false);
  end;

  if CheckBox15.Checked = false then CheckBox15.Enabled := false;
  Label4.Caption := IntToStr(Image2.Width) + 'x' + IntToStr(Image2.Height);
  // It's necessary, or else the black pixels will be displayed.
  Image2.Transparent := true;
  Screen.Cursor := crDefault;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Release the main image used to create the original memory.
  bgImg.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Activate the random calculation.
  Randomize;
  // Prevents flickering while editing the graphic.
  DoubleBuffered := True;

  try
    // load background image
    bgImg := TBitmap.Create;
    OpenPictureDialog1.FileName := ExtractFilePath(Application.ExeName) +
                              'Img\Saturn.bmp';
    // load background image to main image in memory to create original pixel
    bgImg.LoadFromFile(ExtractFilePath(Application.ExeName) +
                              'Img\Saturn.bmp');
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;

  // load background in image
  Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  // copy mask image to preview
  Image4.Picture.Bitmap.Assign(Image2.Picture.Bitmap);

  { Pass the size of the loaded background image to the scroller on
    the form page. }
  ScrollBar1.Max := Image1.Width;
  ScrollBar2.Max := Image1.Height;
  ScrollBar1.Position := 100;
  ScrollBar2.Position := 100;

  Label4.Caption := IntToStr(Image2.Width) + 'x' + IntToStr(Image2.Height);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  CheckBox2.Checked := false;
  TrackBar2.Position := 100;
end;

procedure TForm1.Grayscale1Click(Sender: TObject);
begin
  CheckBox8.Checked := not CheckBox8.Checked;
end;

procedure TForm1.Infrared1Click(Sender: TObject);
begin
  CheckBox9.Checked := not CheckBox9.Checked;
end;

procedure TForm1.Mask1Click(Sender: TObject);
begin
  Button3.Click;
end;

procedure TForm1.Negativ1Click(Sender: TObject);
begin
  CheckBox10.OnClick(sender);
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  Button1.Click;
end;

procedure TForm1.Panel3Click(Sender: TObject);
begin
  Panel1.Visible := Panel3.Checked;
end;

procedure TForm1.Proportional1Click(Sender: TObject);
begin
  CheckBox2.Checked := not CheckBox2.Checked;
end;

procedure TForm1.ransparent1Click(Sender: TObject);
begin
  CheckBox4.Checked := not CheckBox4.Checked;
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

procedure TForm1.Stretched1Click(Sender: TObject);
begin
  CheckBox3.Checked := not CheckBox3.Checked;
end;

// export image formats
procedure TForm1.Button2Click(Sender: TObject);
var
  bmp1, bmp2: TBitmap;
  Jpg: TJPEGImage;
  GIF : TGifImage;
  Image : TImage;
  Ext: TGIFGraphicControlExtension;
begin
    bmp1 := TBitmap.Create;
    bmp1.Assign(Image1.Picture.Bitmap);
    bmp1.Opacity := TrackBar1.Position;

    // export witf single mask
    if CheckBox16.Checked = true then
    begin
      bmp2 := TBitmap.Create;
      bmp2.Assign(Image2.Picture.Bitmap);
      bmp2.Width := Image2.Picture.Bitmap.Width;
      bmp2.Height := Image2.Picture.Bitmap.Height;
      bmp2.Opacity := TrackBar2.Position;
    end;

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

  if SaveDialog1.Execute then
  begin
    try
      if SaveDialog1.FilterIndex = 1 then
      begin
        bmp1.SaveToFile(SaveDialog1.FileName + '.bmp');
      end;

      if SaveDialog1.FilterIndex = 2 then
      begin
        bmp1.SaveToFile(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp');
        Bmp2Jpeg(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp',
                 SaveDialog1.FileName + '.jpg');
      end;

      if SaveDialog1.FilterIndex = 3 then
      begin
        bmp1.SaveToFile(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp');
        BitmapFileToPNG(ExtractFilePath(Application.ExeName) + 'Data\temp\_temp',
                        SaveDialog1.FileName + '.png');
      end;

      if SaveDialog1.FilterIndex = 4 then
      begin
          Image := TImage.Create(self);
          Image.Picture.Bitmap.Assign(bmp1);
          GIF := TGIFImage.Create;
          try
            // Copy Bitmap Pixel to GIF Data
            GIF.Assign(bmp1);
            // Create GIF File Image

            if CheckBox6.Checked = true then
            begin
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

      if SaveDialog1.FilterIndex = 5 then
      begin
          // Save Image as TIFF in the same path with extension '.TIF'
          try
            bmp1.SaveToFile(SaveDialog1.FileName + '.bmp');
            Sleep(50);
            { Errors may occur during export; in that case, an older version
              of Delphi must be used to generate a TIFF file. }
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

procedure TForm1.Center1Click(Sender: TObject);
begin
  CheckBox1.Checked := not CheckBox1.Checked;
end;

// create negativ
procedure TForm1.CheckBox10Click(Sender: TObject);
var
  bmp : TBitmap;
begin
  try
    bmp := TBitmap.Create;
    bmp.Assign(Image1.Picture.Bitmap);
    Image1.Picture.Bitmap := InvertBitmap(bmp);
    if Negativ1.Checked = true then
    begin
      Negativ1.Checked := false;
    end else begin
      Negativ1.Checked := true;
    end;
    Image1.Invalidate;
  finally
    bmp.Free;
  end;
end;

// create grayscal
procedure TForm1.CheckBox8Click(Sender: TObject);
var
  ABitmap : TBitmap;
begin
  if CheckBox9.Checked = true  then CheckBox9.Checked := false;
  if CheckBox10.Checked = true  then CheckBox10.Checked := false;

  if CheckBox8.Checked = true then begin
    ABitmap := TBitmap.Create;

      try
        if ConvertToGrayBitmap(Image1.Picture.Bitmap, ABitmap) then
        begin
          FIsGrayPicture := True;
          Image1.Picture.Bitmap.Assign(ABitmap);
        end;

        if FIsGrayPicture = true then
          Grayscale1.Checked := true
        else
          Grayscale1.Checked := false;
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

  if CheckBox9.Checked = true then
  begin
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
          if ConvertToGrayBitmap(Image1.Picture.Bitmap, ABitmap) then
          begin
            FIsGrayPicture := True;
            Image1.Picture.Bitmap.Assign(ABitmap);
            if FIsGrayPicture = true then
            begin
              Infrared1.Checked := true;
            end else begin
              Infrared1.Checked := false;
            end;
          end;
        finally
      //    ABitmap.Free;
        end;

      try
        if DrawPalette(ABitmap, APalette, Image3.Height) then
        begin
          Image3.Picture.Bitmap.Assign(ABitmap);
        end;
        ABitmap.Assign(Image1.Picture.Bitmap);
        if ChangePalette(ABitmap,APalette) then
        begin
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

procedure TForm1.Export1Click(Sender: TObject);
begin
  Button2.Click;
end;

procedure TForm1.CheckBox15Click(Sender: TObject);
var
  aImg: TImage;
begin    
  aImg := Image2;

  // Check which button state is active: 0 = background image, 5 = mask.
  if TComponent(Sender).Tag > 4 then
    aImg := Image1;

  with aImg do
  begin
    case TComponent(Sender).Tag of
      0:    begin
              // alpha channel for background
              if (Picture.Graphic is TBitmap) then
              begin
                (Picture.Graphic as TBitmap).NoAlpha := CheckBox15.Checked;
                Image4.Transparent := false;
                if CheckBox15.Checked = false then Image4.Transparent := true;
              end;
            end;
      5:    begin
              // // alpha channel for mask
              if (Picture.Graphic is TBitmap) then
               (Picture.Graphic as TBitmap).NoAlpha := CheckBox5.Checked;
            end;
      1, 6: begin
              Center := TCheckBox(Sender).Checked;
              if Center = true then
                Center1.Checked := true
              else
                Center1.Checked := false;
            end;
      2, 7: begin
              Proportional := TCheckBox(Sender).Checked;
              if Proportional = true then
                Proportional1.Checked := true
              else
                Proportional1.Checked := false;
            end;
      3, 8: begin
              Stretch := TCheckBox(Sender).Checked;
              if Stretch = true then
                Stretched1.Checked := true
              else
                Stretched1.Checked := false;
            end;
      4, 9: begin
              Transparent := TCheckBox(Sender).Checked;
              if Transparent = true then
                ransparent1.Checked := true
              else
                ransparent1.Checked := false;
            end;
    end;
    Invalidate;
  end;
end;

procedure TForm1.CheckBox16Click(Sender: TObject);
begin
  if CheckBox16.Checked = true then
  begin
    Image2.AutoSize := true;
  end else begin
    Image2.AutoSize := false;
    Image2.Width := 0;
    Image2.Height := 0;
  end;
end;

end.
