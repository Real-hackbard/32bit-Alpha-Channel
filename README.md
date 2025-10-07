# 32bit-Alpha-Channel:

</br>

```ruby
Compiler    : Delphi10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney, 11 Alexandria, 12 Athens
Components  : PNGImage.pas, GIFImg.pas, crBitmap32.pas, BmpGrD12.pas, Bmp2tiff.pas
Discription : Create 32bit Bitmaps with Alpha-Channels
Last Update : 10/2025
License     : Freeware
```

</br>


The BMP file format, or bitmap, is a [raster graphics](https://en.wikipedia.org/wiki/Raster_graphics) image file format used to store bitmap [digital images](https://en.wikipedia.org/wiki/Digital_image), independently of the display device (such as a graphics adapter), especially on Microsoft Windows and OS/2 operating systems.

The BMP file format is capable of storing [two-dimensional](https://en.wikipedia.org/wiki/2D_computer_graphics) digital images in various color depths, and optionally with data compression, alpha channels, and [color profiles](https://en.wikipedia.org/wiki/Color_management). The [Windows Metafile](https://en.wikipedia.org/wiki/Windows_Metafile) (WMF) specification covers the BMP file format.

A color spectrum image with an alpha channel that falls off to zero at its base, where it is blended with the background color..

<img width="250" height="125" alt="alpha" src="https://github.com/user-attachments/assets/7fb47937-a30c-44e1-a89b-ee1872ea09d4" />

</br>

In computer graphics, alpha compositing or alpha blending is the process of combining one image with a background to create the appearance of partial or full [transparency](https://en.wikipedia.org/wiki/Transparency_(graphic)). It is often useful to render [picture elements](https://en.wikipedia.org/wiki/Pixel) (pixels) in separate passes or layers and then combine the resulting 2D images into a single, final image called the composite. Compositing is used extensively in film when combining computer-rendered image elements with live footage. Alpha blending is also used in 2D computer graphics to put [rasterized](https://en.wikipedia.org/wiki/Rasterisation) foreground elements over a background.

TBitmap32 : https://documentation.help/Graphics32/_Body4.htm

### Features
* Adjust Alpha Channels
* Selct Pixel Format
* Export Format : *.BMP, *.JPG/JPEG, *.PNG, *.GIF, *.TIFF ```pascal(This can cause compatibility problems, then use a different compiler)```
* Compress
* Tranzparent
* Infrared
* Negativ

![32 Bit Alpha](https://github.com/user-attachments/assets/e33ebdae-8476-4bbf-bd8d-ebf7131a449c)

</br>

### File structure:
The bitmap image file consists of fixed-size structures (headers) as well as variable-sized structures appearing in a predetermined sequence. Many different versions of some of these structures can appear in the file, due to the long evolution of this file format.

Referring to the diagram 1, the bitmap file is composed of structures in the following order:

| Structure     | Optional      | Size (bytes)  | Purpose       | Comment       |
| :-----------: | :-----------: | :-----------: | :-----------: | :-----------: |
| [Bitmap file header](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader)     | No     | 14          | General information | Not needed after the file is loaded in memory|
| [DIB header](https://d3s.mff.cuni.cz/legacy/teaching/principles_of_computers//Zkouska%20Principy%20pocitacu%202017-18%20-%20varianta%2002%20-%20priloha%20-%20format%20BMP%20z%20Wiki.pdf) | No | Fixed-size (7 different versions exist) | Detailed information and pixel format | Immediately follows the Bitmap file header |
| [Extra bit masks](https://docs.oracle.com/en/database/oracle/oracle-database/23/geors/bitmap-masks.html) | Yes | 12 or 16 | Pixel format | Present only in case the DIB header is the BITMAPINFOHEADER and the Compression Method member is set to either BI_BITFIELDS or BI_ALPHABITFIELDS |
| [Color table](https://learn.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-types-of-bitmaps-about) | Depends | Varies | Colors (Pixel array) | Mandatory for color depths ≤ 8 bits |
| Gap1 | Yes | Varies | Structure alignment | An artifact of the File offset to Pixel array in the Bitmap file header |
| [Pixel array](https://en.wikipedia.org/wiki/Color_filter_array) | No | Varies | Pixel values | The pixel format is defined by the DIB header or Extra bit masks. Each row in the Pixel array is padded to a multiple of 4 bytes in size |
| Gap2 | Yes | Varies	 | Structure alignment | An artifact of the ICC profile data offset field in the DIB header |
| [ICC color profile](https://en.wikipedia.org/wiki/ICC_profile) | Yes | Varies | Color profile (for color management) | Can also contain a path to an external file containing the color profile. When loaded in memory as "non-packed DIB", it is located between the color table and Gap1. |

</br>

### Bitmap32:
TBitmap32 is the central class in the Graphics32 library. It manages a single 32-bit device-independent bitmap (DIB) and provides methods for drawing on it and combining it with other DIBs or other objects with device context (DC).

TBitmap32 overrides Assign and AssignTo methods (inherited from TPersistent) to provide compatibility with standard objects: TBitmap, TPicture and TClipboard in both directions. The design-time streaming to and from *.dfm files, inherited from TPersistent, is supported, but its realization is different from streaming with other stream types (See the source code for details).

TBitmap32 does not implement its own low-level streaming or low-level file loading/saving. Instead, it uses streaming methods of temporal TBitmap or TPicture objects. This is an obvious performance penalty, however such approach allows using third-party libraries, which extend TGraphic class for various image formats support (JPEG, TGA, TIFF, GIF, PNG, etc.). When you install them, TBitmap32 will automatically obtain support for new image file formats in design time and in run time.

Since TBitmap32 is a descendant of TThreadPersistent, it inherits its locking mechanism and it may be used in multi-threaded applications.

TBitmap32 : https://documentation.help/Graphics32/_Body4.htm

```pascal
// Convert all Picture Pixel
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
```

</br>

```pascal
// Concert RGB Pixel Colors 
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
```
</br>


### Alpha Compositing:
In a 2D image a color combination is stored for each picture element (pixel), often a combination of red, green and blue ([RGB](https://en.wikipedia.org/wiki/RGB_color_model)). When alpha compositing is in use, each pixel has an additional numeric value stored in its alpha channel, with a value ranging from 0 to 1. A value of 0 means that the pixel is fully transparent and the color in the pixel beneath will show through. A value of 1 means that the pixel is fully opaque.

With the existence of an alpha channel, it is possible to express compositing image operations using a compositing algebra. For example, given two images A and B, the most common compositing operation is to combine the images so that A appears in the foreground and B appears in the background. This can be expressed as A over B. In addition to over, Porter and Duff defined the compositing operators in, held out by (the phrase refers to [holdout matting](https://en.wikipedia.org/wiki/Matte_(filmmaking)#Garbage_and_holdout_mattes) and is usually abbreviated out), atop, and xor (and the reverse operators rover, rin, rout, and ratop) from a consideration of choices in blending the colors of two pixels when their coverage is, conceptually, overlaid orthogonally:

</br>

<img width="642" height="308" alt="Alpha_compositing" src="https://github.com/user-attachments/assets/fe3611e4-4507-48cb-9a8d-4897e14e4d8f" />

</br>

### Image formats supporting alpha channels:
The most popular image formats that support the alpha channel are [PNG](https://en.wikipedia.org/wiki/PNG) and [TIFF](https://en.wikipedia.org/wiki/Tagged_Image_File_Format). [GIF](https://en.wikipedia.org/wiki/Graphics_Interchange_Format) supports alpha channels, but is considered to be inefficient when it comes to file size. Support for alpha channels is present in some video codecs, such as Animation and Apple ProRes 4444 of the QuickTime format, or in the Techsmith multi-format codec.

The file format BMP generally does not support this channel; however, in different formats such as 32-bit (888–8) or 16-bit (444–4) it is possible to save the alpha channel, although not all systems or programs are able to read it: it is exploited mainly in some video games or particular applications; specific programs have also been created for the creation of these BMPs.

| File Codec Format | Maximum Depth | Type | Browser Support | Media Types | Notes |
| :-----------: | :-----------: | :-----------: | :-----------: | :-----------: | :-----------: |
| [Apple ProRes 4444](https://en.wikipedia.org/wiki/Apple_ProRes) | 16-bit | None | None | Video (.mov) | ProRes is the successor of the Apple Intermediate Codec |
| [HEVC / h.265](https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding) | 10-bit | None | Limited To Safari | Video (.hevc) | Intended successor to H.264 |
| [WebM](https://en.wikipedia.org/wiki/WebM) (codec video VP8, VP9, or AV1) | 12-Bit | None | All modern browsers | Video (.webm) | While VP8/VP9 is widely supported with modern browsers, AV1 still has limited support. Only Chromium-based browsers will display alpha layers. |
| [OpenEXR](https://en.wikipedia.org/wiki/OpenEXR) | 32-bit | None | None |Image (.exr) | Has largest HDR spread. | 
| [PNG](https://en.wikipedia.org/wiki/PNG) | 16-bit | straight | All modern browsers | Image (.png) | None |
| [APNG](https://en.wikipedia.org/wiki/APNG) | 24-bit | straight | Moderate support | Image (.apng) | Supports animation. |
| [TIFF](https://en.wikipedia.org/wiki/TIFF) | 32-bit | both | None | Image (.tiff) | None |
| [GIF](https://en.wikipedia.org/wiki/GIF) | 8.bit | None | All modern browsers | Image (.gif) | Browsers generally do not support GIF alpha layers. |
| [SVG](https://en.wikipedia.org/wiki/SVG) | 32-bit | straight	 | All modern browsers | Image (.svg) | Based on CSS color. |
| [JPEG](https://en.wikipedia.org/wiki/JPEG_XL) | 32-bit | both | Moderate support | Image (.jxl) | Allows lossy and HDR. |

</br>




