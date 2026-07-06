unit crBitmap32;

interface
uses Windows, Classes, Graphics, Dialogs;

type
  TBitmap = class(Graphics.TBitmap)
  Private
    FOpacity: Byte;
    FNoAlpha: Boolean;
    FPreMultiplied: Boolean;
    procedure SetOpacity(Value: Byte);
  Protected
    { Protected declarations }
    procedure DoPreMultiply;
    procedure DoUnPreMultiply;
  Public
    constructor Create; override;
    Procedure Draw(ACanvas:TCanvas;const aRect: TRect); Override;
    procedure SaveToFile(const FileName: string); Override;
    procedure SaveToStream(Stream: TStream); Override;
    property Opacity: Byte read FOpacity write SetOpacity;
    Property NoAlpha : Boolean Read FNoAlpha Write FNoAlpha;
  end;



function Bmp24To32(const aBitmap: TBitmap): Boolean;overload; forward;
function Bmp24To32(const aBitmap: TBitmap; const TrsColor: TColor): Boolean;overload; forward;

procedure PreMultiply(aBmp: TBitmap);

function StretchDraw32(DestDc: hdc; dLeft, dTop, dWidth, dHeight: Integer;
           SourceBmp: TBitmap; Alpha: Byte): Boolean;

function Draw32(DestDc: hdc; dLeft, dTop: Integer; SourceBmp: TBitmap; Alpha: Byte): Boolean;
implementation
Const
  sBMPImageFile = '[Cirec] Bitmap32';


function Bmp24To32(const aBitmap: TBitmap): Boolean;
var PData       : PRGBQuad;
  I, BytesTotal : Integer;
  TrsColor: Integer;
begin
  Result := False;
  if not Assigned(aBitmap) then
    Exit;
  aBitmap.PixelFormat := pf32Bit;
  BytesTotal := aBitmap.Width * aBitmap.Height;
  TrsColor := aBitmap.Canvas.Pixels[0, 0];
  try
    Result := True;
    PData := aBitmap.ScanLine[aBitmap.Height-1];
    for I := 0 to BytesTotal - 1 do
    begin
      if Integer(PData^) <> TrsColor then
        PData^.rgbReserved := 255;
      Inc(PData);
    end;
  except
    Result := False;
  end;
end;

function Bmp24To32(const aBitmap: TBitmap; const TrsColor: TColor): Boolean;
var PData       : PRGBQuad;
  I, BytesTotal : Integer;
begin
  Result := False;
  if not Assigned(aBitmap) then
    Exit;
  aBitmap.PixelFormat := pf32Bit;
  BytesTotal := aBitmap.Width * aBitmap.Height;
  try
    Result := True;
    PData := aBitmap.ScanLine[aBitmap.Height-1];
    for I := 0 to BytesTotal - 1 do
    begin
      if Integer(PData^) <> TrsColor then
        PData^.rgbReserved := 255;
      Inc(PData);
    end;
  except
    Result := False;
  end;
end;



procedure PreMultiply(aBmp: TBitmap);
var PData       : PRGBQuad;
  I, BytesTotal : Integer;
begin
  BytesTotal := aBMP.Width * aBMP.Height;
  If aBmp.PixelFormat = pf32Bit then
  begin
    PData := aBMP.ScanLine[aBMP.Height-1];
    for I := 0 to BytesTotal - 1 do
    begin
      with PData^ do
      begin
        if rgbReserved = 0 then
          rgbReserved := 1;
        RGBRed := (RGBRed * rgbReserved) div 255;
        RGBGreen := (RGBGreen * rgbReserved) div 255;
        RGBBlue := (RGBBlue * rgbReserved) div 255;
      end;
      Inc(PData);
    end;
  end;
end;

procedure UnPreMultiply(aBmp: TBitmap);
var PData       : PRGBQuad;
  I, BytesTotal : Integer;
begin
  BytesTotal := aBMP.Width * aBMP.Height;
  If aBmp.PixelFormat = pf32Bit then
  begin
    PData := aBMP.ScanLine[aBMP.Height-1];
    for I := 0 to BytesTotal - 1 do
    begin
      with PData^ do
      begin
        RGBRed := (RGBRed * 255) div rgbReserved;
        RGBGreen := (RGBGreen * 255) div rgbReserved;
        RGBBlue := (RGBBlue * 255) div rgbReserved;
      end;
      Inc(PData);
    end;
  end;
end;


function StretchDraw32(DestDc: hdc; dLeft, dTop, dWidth, dHeight: Integer;
           SourceBmp: TBitmap; Alpha: Byte): Boolean;
Var  BlendF : TBLENDFUNCTION;
begin
  BlendF.BlendOp := AC_SRC_OVER;
  BlendF.BlendFlags := 0;
  BlendF.SourceConstantAlpha := Alpha;
  with SourceBmp do
  begin
    if (PixelFormat < pf32Bit) and Transparent then
    begin
      Bmp24To32(SourceBmp, TransparentColor and $FFFFFF);
    end;
    if (PixelFormat = pf32Bit) and not NoAlpha then
    begin
      if not FPreMultiplied then
        DoPreMultiply;
      BlendF.AlphaFormat := AC_SRC_ALPHA;
    end
    else
    begin
      if FPreMultiplied and NoAlpha then
        DoUnPreMultiply;
      BlendF.AlphaFormat := AC_SRC_OVER;
    end;
  end;

  if dWidth = -1 then
    dWidth := SourceBmp.Width;
  if dHeight = -1 then
    dHeight := SourceBmp.Height;
  Result := Windows.AlphaBlend(DestDc, dLeft, dTop, dWidth, dHeight, SourceBmp.Canvas.Handle, 0, 0, SourceBmp.Width, SourceBmp.Height, BlendF);
end;

function Draw32(DestDc: hdc; dLeft, dTop: Integer; SourceBmp: TBitmap; Alpha: Byte): Boolean;
begin
  Result := StretchDraw32(DestDc,  dLeft, dTop, -1, -1, SourceBmp, Alpha);
end;

{ TBitmap }

procedure TBitmap.Draw(ACanvas: TCanvas; const aRect: TRect);
Var DRect : TRect;
Begin
  if (PixelFormat < pf32Bit) and (FOpacity = 255) then
    Inherited Draw(ACanvas, aRect)
  else
  With DRect Do
  begin
    DRect := Rect(aRect.Left, aRect.Top, aRect.Right-aRect.Left, aRect.Bottom-aRect.Top);
    StretchDraw32(aCanvas.Handle, Left, Top, Right, Bottom, Self, FOpacity);
  end;
End;

procedure TBitmap.DoPreMultiply;
begin
  if not FPreMultiplied then
  begin
    PreMultiply(Self);
    FPreMultiplied := True;
  end;
end;


constructor TBitmap.Create;
begin
  inherited Create;
  FOpacity := 255;
end;

procedure TBitmap.SetOpacity(Value: Byte);
begin
  if Value <> FOpacity then
  begin
    FOpacity := Value;
    Changed(self);
  end;
end;

procedure TBitmap.DoUnPreMultiply;
begin
  if FPreMultiplied then
  begin
    UnPreMultiply(Self);
    FPreMultiplied := False;
  end;
end;

procedure TBitmap.SaveToFile(const FileName: string);
begin
  DoUnPreMultiply;
  inherited SaveToFile(FileName);
end;

procedure TBitmap.SaveToStream(Stream: TStream);
begin             
  DoUnPreMultiply;
  inherited SaveToStream(Stream);
end;

Initialization
  TPicture.RegisterFileFormat('Bmp', sBMPImageFile, TBitmap);
Finalization
  TPicture.UnregisterGraphicClass(TBitmap);
end.
