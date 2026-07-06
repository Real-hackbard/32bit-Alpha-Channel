unit BmpGrD12;

interface
uses
  WinProcs, WinTypes, SysUtils, Classes, Graphics, Controls, Forms;

type
  PFullPalette = ^TFullPalette;
  TFullPalette = array[0..255] of TRGBQuad;

{ Konvertiert eine 8, 24 oder 32 Bit-Bitmap in eine 8 Bit-Graustufen-Bitmap }
function ConvertToGrayBitmap(ASrcBmp,ADstBmp:TBitmap):Boolean;

{ Ändert die Palette einer Bitmap (1,4,8 Bit) }
function ChangePalette(ABmp:TBitmap; var APal:TFullPalette):Boolean;

{ gibt eine 8-Bit-Bitmap mit 256 x AHeight Pixeln zurück,
  die die Palette anzeigt }
function DrawPalette(ABmp:TBitmap; var APal:TFullPalette; AHeight:Integer):Boolean;

implementation

{$ifdef Ver80}

{ *****************  speziell für Delphi 1  ************************* }

type
  PRGBQuad = ^TRGBQuad;

procedure __AHSHIFT; far; external 'KERNEL' index 113;
procedure __AHINCR; far; external 'KERNEL' index 114;

{ Erhöht einen 16-Bit Pointer um Ofs (mittels Erhöhung des Segmentes) }
function OffsetPointer(P: Pointer; Ofs: Longint): Pointer; assembler;
asm
        MOV     AX,Ofs.Word[0]
        MOV     DX,Ofs.Word[2]
        ADD     AX,P.Word[0]
        ADC     DX,0
        MOV     CX,OFFSET __AHSHIFT
        SHL     DX,CL
        ADD     DX,P.Word[2]
end;

{$else}

{ *****************  speziell für Delphi 2 (3,4)  ******************* }

function OffsetPointer(APointer:Pointer; AOffset:Integer):PByte;
begin
  Result:=APointer;
  Inc(Result,AOffset);
end;

procedure hmemcpy(Dst,Src:Pointer; Len:LongInt);
begin
  Move(Src^,Dst^,Len);
end;

{$endif}


{ Richtet die Größe einer Scanzeile an 4Byte aus (I in Bits) }
function WidthBytes(I:LongInt):LongInt;
begin
  Result:=((I+31) div 32)*4;
end;

{ Ermittelt Anzahl der Farben (für palettenorientierte Bitmaps) }
function GetDInColors(BitCount: Word): Integer;
begin
  case BitCount of
    1, 4, 8: Result := 1 shl BitCount;
  else
    Result := 0;
  end;
end;

type
  PbmiColors = ^TbmiColors;
  TbmiColors = array[0..0] of TRGBQuad;
  PRGBTriple = ^TRGBTriple;

function ConvertToGrayBitmap(ASrcBmp,ADstBmp:TBitmap):Boolean;
var
  { Quellbitmap }
  SrcWidth     : LongInt;           { Breite }
  SrcHeight    : LongInt;           { Höhe }
  SrcStream    : TMemoryStream;     { Stream }
  SrcP0        : Pointer;           { linke untere Ecke }
  SrcLineSize  : LongInt;           { Größe einer Scanzeile in Byte }
  SrcPixelSize : LongInt;           { Größe eines Pixels in Byte }
  SrcBfh       : PBitmapFileHeader;
  SrcBih       : PBitmapInfoHeader;
  SrcPalette   : PbmiColors;
  SrcPalCount  : LongInt;           { Anzahl Paletteneinträge }

  { Zielbitmap }
  DstStream    : TMemoryStream;     { Stream }
  DstP0        : Pointer;           { linke untere Ecke }
  DstLineSize  : LongInt;           { Größe einer Scanzeile in Byte }
  DstPixelSize : LongInt;           { Größe eines Pixels in Byte }
  DstBfh       : PBitmapFileHeader;
  DstBih       : PBitmapInfoHeader;
  DstPalette   : PbmiColors;
  DstPalCount  : LongInt;           { Anzahl Paletteneinträge }

{ Daten aus der Quellbitmap (Stream) holen }
function GetSrcHeader:Boolean;
var
  p         : PByte;
  BitsIndex : LongInt;
begin
  Result:=False;
  p:=SrcStream.Memory;
  { FileHeader auslesen }
  SrcBfh:=PBitmapFileHeader(p);
  { Prüfen, ob Bitmap }
  if SrcBfh^.bfType<>$4D42 then Exit;
  Inc(p,SizeOf(TBitmapFileHeader));
  { BitmapInfoHeader einlesen }
  SrcBih:=PBitmapInfoHeader(p);
  Inc(p,SizeOf(TBitmapInfoHeader));
  with SrcBih^ do begin
    { Prüfen, ob BitmapInfoHeader, könnte auch BitmapCoreHeader sein }
    if biSize<>SizeOf(TBitmapInfoHeader) then Exit;
    { Prüfen, ob Bitmap unkomprimiert, sonst nicht implementiert }
    if biCompression<>BI_RGB then Exit;
    { Palettengröße und Position berechnen }
    SrcPalette:=PbmiColors(p);
    SrcPalCount:=GetDInColors(biBitCount);
    { Position des Images berechnen }
    BitsIndex:=SrcBfh^.bfOffBits;
    { bei von 8 Bit auf 24 Bit hochgerechneten DIB's ist zusätzlich
      eine Palette vorhanden }
    if biBitCount>8 then Inc(BitsIndex,biClrUsed*SizeOf(TRGBQuad));
    { Pointer auf Quell-DIB berechnen }
    SrcP0:=OffsetPointer(SrcStream.Memory,BitsIndex);
    SrcWidth :=biWidth ;
    SrcHeight:=biHeight;
    { Größen der Scanzeilen berechnen }
    SrcLineSize:=WidthBytes(biWidth*biBitCount);
    case biBitCount of
      8,24,32 : SrcPixelSize:=biBitCount shr 3;
    else
      Exit;  { keine 1,4,15,16-Bit - Bitmaps }
    end;
    { Prüfen, ob die berechneten Daten innerhalb des Streams liegen }
    if BitsIndex+biHeight*SrcLineSize>SrcStream.Size then Exit;
  end;
  Result:=True;
end;

{ Daten aus der Zielbitmap (Stream) erzeugen }
function CreateDstHeader:Boolean;
var
  p       : PByte;
  NewSize : LongInt;
  i       : LongInt;
begin
  Result:=False;
  NewSize:=SizeOf(TBitmapFileHeader)+SizeOf(TBitmapInfoHeader)+
           256*SizeOf(TRGBQuad)+WidthBytes(SrcWidth*8)*SrcHeight;
  DstStream.SetSize(NewSize);
  p:=DstStream.Memory;
  FillChar(p^,NewSize,0);
  { FileHeader erzeugen }
  DstBfh:=PBitmapFileHeader(p);
  with DstBfh^ do begin
    bfType   :=$4D42;
    bfSize   :=NewSize;
    bfOffBits:=SizeOf(TBitmapFileHeader)+SizeOf(TBitmapInfoHeader)+
               256*SizeOf(TRGBQuad);
  end;
  Inc(p,SizeOf(TBitmapFileHeader));
  { BitmapInfoHeader erzeugen }
  DstBih:=PBitmapInfoHeader(p);
  with DstBih^ do begin
    biSize:=SizeOf(TBitmapInfoHeader);
    biWidth :=SrcWidth;
    biHeight:=SrcHeight;
    biPlanes:=1;
    biBitCount:=8;
    biCompression:=BI_RGB;
    biSizeImage:=0;
    biXPelsPerMeter:=96;
    biYPelsPerMeter:=96;
    biClrUsed:=0;
    biClrImportant:=0;
    DstLineSize :=WidthBytes(biWidth*biBitCount);
    DstPixelSize:=1;         { 1 Byte / Pixel }
  end;
  Inc(p,SizeOf(TBitmapInfoHeader));
  { Palette setzen }
  DstPalette :=PbmiColors(p);
  DstPalCount:=256;
  Inc(p,256*SizeOf(TRGBQuad));
  { Pointer auf Bitmapdaten setzen }
  DstP0:=p;
  { Palette einrichten }
  {$R-}
  for i:=0 to 255 do begin
    with DstPalette^[i] do begin
      rgbBlue :=i;
      rgbGreen:=i;
      rgbRed  :=i;
    end;
  end;
  Result:=True;
end;

var
  OldCursor : TCursor;   { Rettet den Zustand des alten Mauszeigers }
  x, y      : LongInt;   { Koordinaten beim Umkopieren }
  SrcPLine  : PByte;
  SrcP      : PByte;
  DstPLine  : PByte;
  DstP      : PByte;
  PalTab    : array[Byte] of Byte;

begin
  Result:=False;
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourglass;
  try
    SrcStream:=TMemoryStream.Create;
    try
      DstStream:=TMemoryStream.Create;
      try
        ASrcBmp.SaveToStream(SrcStream);
        if Not GetSrcHeader then Exit;
        if Not CreateDstHeader then Exit;
        { wandeln von 8 Bit-Bitmaps }
        if SrcPixelSize=1 then begin
          { Palette konvertieren }
          for x:=0 to 255 do with SrcPalette^[x] do
            PalTab[x]:=Byte((rgbRed*77{30%}+rgbGreen*151{59%}+rgbBlue*28{11%}) shr 8);
          SrcPLine:=SrcP0;
          DstPLine:=DstP0;
          for y:=0 to SrcHeight-1 do begin    { für alle Zeilen }
            SrcP:=SrcPLine;
            DstP:=DstPLine;
            for x:=0 to SrcWidth-1 do begin   { für alle Spalten }
              DstP^:=PalTab[SrcP^];
              Inc(SrcP);
              Inc(DstP);
            end;
            Inc(SrcPLine,SrcLineSize);
            Inc(DstPLine,DstLineSize);
          end;
        end
        { wandeln von 24 oder 32 Bit-Bitmaps }
        else begin
          SrcPLine:=SrcP0;
          DstPLine:=DstP0;
          for y:=0 to SrcHeight-1 do begin    { für alle Zeilen }
            SrcP:=SrcPLine;
            DstP:=DstPLine;
            for x:=0 to SrcWidth-1 do begin   { für alle Spalten }
              with PRGBQuad(SrcP)^ do
                DstP^:=Byte((rgbRed*77{30%}+rgbGreen*151{59%}+rgbBlue*28{11%}) shr 8);
              Inc(SrcP,SrcPixelSize);
              Inc(DstP);
            end;
            Inc(SrcPLine,SrcLineSize);
            Inc(DstPLine,DstLineSize);
          end;
        end;
        DstStream.Seek(0,soFromBeginning);
        ADstBmp.LoadFromStream(DstStream);
        Result:=True;
      finally
        DstStream.Free;
      end;
    finally
      SrcStream.Free;
    end;
  finally
    Screen.Cursor:=OldCursor;
  end;
  {$R+}
end;

function ChangePalette(ABmp:TBitmap; var APal:TFullPalette):Boolean;
var
  Stream    : TMemoryStream;     { Stream }
  Bfh       : PBitmapFileHeader;
  Bih       : PBitmapInfoHeader;
  Palette   : PbmiColors;
  PalCount  : LongInt;           { Anzahl Paletteneinträge }
  OldCursor : TCursor;   { Rettet den Zustand des alten Mauszeigers }
  p         : PByte;

begin
  Result:=False;
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourglass;
  try
    Stream:=TMemoryStream.Create;
    try
      ABmp.SaveToStream(Stream);
      p:=Stream.Memory;
      { FileHeader auslesen }
      Bfh:=PBitmapFileHeader(p);
      { Prüfen, ob Bitmap }
      if Bfh^.bfType<>$4D42 then Exit;
      Inc(p,SizeOf(TBitmapFileHeader));
      { BitmapInfoHeader einlesen }
      Bih:=PBitmapInfoHeader(p);
      Inc(p,SizeOf(TBitmapInfoHeader));
      with Bih^ do begin
        { Prüfen, ob BitmapInfoHeader, könnte auch BitmapCoreHeader sein }
        if biSize<>SizeOf(TBitmapInfoHeader) then Exit;
        { Palettengröße und Position berechnen }
        Palette:=PbmiColors(p);
        PalCount:=GetDInColors(biBitCount);
      end;
      Move(APal,Palette^,PalCount*SizeOf(TRGBQuad));
      Stream.Seek(0,soFromBeginning);
      ABmp.LoadFromStream(Stream);
      Result:=True;
    finally
      Stream.Free;
    end;
  finally
    Screen.Cursor:=OldCursor;
  end;
end;

function DrawPalette(ABmp:TBitmap; var APal:TFullPalette; AHeight:Integer):Boolean;
const
  AWidth = 256;

var
  Stream    : TMemoryStream;     { Stream }
  Bfh       : PBitmapFileHeader;
  Bih       : PBitmapInfoHeader;
  P0        : Pointer;
  LineSize  : LongInt;
  PixelSize : LongInt;
  Palette   : PbmiColors;
  PalCount  : LongInt;           { Anzahl Paletteneinträge }
  OldCursor : TCursor;   { Rettet den Zustand des alten Mauszeigers }
  NewSize   : Integer;
  p         : PByte;
  pLine     : PByte;
  x,y       : Integer;

begin
  Result:=False;
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourglass;
  try
    Stream:=TMemoryStream.Create;
    try
      NewSize:=SizeOf(TBitmapFileHeader)+SizeOf(TBitmapInfoHeader)+
               256*SizeOf(TRGBQuad)+WidthBytes(AWidth*8)*AHeight;
      Stream.SetSize(NewSize);
      p:=Stream.Memory;
      FillChar(p^,NewSize,0);
      { FileHeader erzeugen }
      Bfh:=PBitmapFileHeader(p);
      with Bfh^ do begin
        bfType   :=$4D42;
        bfSize   :=NewSize;
        bfOffBits:=SizeOf(TBitmapFileHeader)+SizeOf(TBitmapInfoHeader)+
                   256*SizeOf(TRGBQuad);
      end;
      Inc(p,SizeOf(TBitmapFileHeader));
      { BitmapInfoHeader erzeugen }
      Bih:=PBitmapInfoHeader(p);
      with Bih^ do begin
        biSize:=SizeOf(TBitmapInfoHeader);
        biWidth :=AWidth;
        biHeight:=AHeight;
        biPlanes:=1;
        biBitCount:=8;
        biCompression:=BI_RGB;
        biSizeImage:=0;
        biXPelsPerMeter:=96;
        biYPelsPerMeter:=96;
        biClrUsed:=0;
        biClrImportant:=0;
        LineSize :=WidthBytes(biWidth*biBitCount);
        PixelSize:=1;         { 1 Byte / Pixel }
      end;
      Inc(p,SizeOf(TBitmapInfoHeader));
      { Palette setzen }
      Palette :=PbmiColors(p);
      PalCount:=256;
      Inc(p,256*SizeOf(TRGBQuad));
      { Pointer auf Bitmapdaten setzen }
      P0:=p;
      { Palette kopieren }
      Move(APal,Palette^,PalCount*SizeOf(TRGBQuad));
      { Bitmap erzeugen }
      pLine:=p0;
      for y:=0 to AHeight-1 do begin
        p:=pLine;
        for x:=0 to AWidth-1 do begin
          p^:=x;
          Inc(p);
        end;
        Inc(pLine,LineSize);
      end;
      Stream.Seek(0,soFromBeginning);
      ABmp.LoadFromStream(Stream);
      Result:=True;
    finally
      Stream.Free;
    end;
  finally
    Screen.Cursor:=OldCursor;
  end;
end;

end.
