# 32bit-Alpha-Channel:

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c) ![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) ![GIFImg pas](https://github.com/user-attachments/assets/624b2b36-361c-4d29-99f6-2abd236f1f0d) ![PNGImage pas](https://github.com/user-attachments/assets/a03f3d1a-ce7c-413b-a18d-6ed80f5b82ca) ![BmpGrD12 pas](https://github.com/user-attachments/assets/4f375940-fb1e-40e8-a255-3c381fd889ee) ![crBitmap32 pas](https://github.com/user-attachments/assets/77edaa1e-64a6-4828-a6bd-86bb2ce626d6) ![Bmp2tiff pas](https://github.com/user-attachments/assets/dccfb837-0412-4988-a1b9-cbe9d4a793fc)  
![Discription](https://github.com/user-attachments/assets/4a778202-1072-463a-bfa3-842226e300af) ![32bit-Alpha Channel](https://github.com/user-attachments/assets/c7d92335-5f5e-4491-9d55-c77872ff7b02)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) <img src="https://github.com/user-attachments/assets/51b641d1-6efd-43fb-95e9-0be9576c481b" />  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)

</br>

The BMP file format, or bitmap, is a [raster graphics](https://en.wikipedia.org/wiki/Raster_graphics) image file format used to store bitmap [digital images](https://en.wikipedia.org/wiki/Digital_image), independently of the display device (such as a graphics adapter), especially on Microsoft Windows and OS/2 operating systems.

The BMP file format is capable of storing [two-dimensional](https://en.wikipedia.org/wiki/2D_computer_graphics) digital images in various color depths, and optionally with data compression, alpha channels, and [color profiles](https://en.wikipedia.org/wiki/Color_management). The [Windows Metafile](https://en.wikipedia.org/wiki/Windows_Metafile) (WMF) specification covers the BMP file format.

A color spectrum image with an alpha channel that falls off to zero at its base, where it is blended with the background color..

</br>

<img src="https://github.com/user-attachments/assets/689310a9-d4c9-4b79-b6b5-897bda52e982" />

</br>
</br>

In computer graphics, alpha compositing or alpha blending is the process of combining one image with a background to create the appearance of partial or full [transparency](https://en.wikipedia.org/wiki/Transparency_(graphic)). It is often useful to render [picture elements](https://en.wikipedia.org/wiki/Pixel) (pixels) in separate passes or layers and then combine the resulting 2D images into a single, final image called the composite. Compositing is used extensively in film when combining computer-rendered image elements with live footage. Alpha blending is also used in 2D computer graphics to put [rasterized](https://en.wikipedia.org/wiki/Rasterisation) foreground elements over a background.

TBitmap32 : https://documentation.help/Graphics32/_Body4.htm

### Features
* Adjust Alpha Channels
* Selct Pixel Format
* Export Format : *.BMP, *.JPG/JPEG, *.PNG, *.GIF,  *.TIFF =>  ```(This can cause compatibility problems, then use a different compiler)```
* Compress
* Transparent
* Infrared
* Negativ
* Generate Multi Mask Pictures
* Scale Mask Picture Prozentual
* Smooth Scaling
* Disable Mask Picture

</br>

<img src="https://github.com/user-attachments/assets/b5049c5c-7e03-4fbb-b8eb-1f068904286a" />

</br>

# Multi Mask Generator
Any number of images can be generated over the background using masks. The quantity is adjustable, and the painting process occurs randomly across the background. By modifying the code, X/Y coordinates can also be specified directly.

Once the masks have been painted, the background is not painted over; instead, the masks can be removed again at the touch of a button.

### Example: a negative image with five generated spheres.

</br>

<img src="https://github.com/user-attachments/assets/204909a4-ef2a-495c-a408-f0cc5e47cca1" />

</br>

### Mask Generator Code Sample
```pascal
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
```

</br>

# Image scaling
When scaling a image, the graphic primitives that make up the image can be rendered using geometric transformations at any resolution with no loss of [image quality](https://en.wikipedia.org/wiki/Image_quality). When scaling a raster graphics image, a new image with a higher or lower number of pixels must be generated.

</br>

# File structure:
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

# Bitmap32:
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


# Alpha Compositing:
In a 2D image a color combination is stored for each picture element (pixel), often a combination of red, green and blue ([RGB](https://en.wikipedia.org/wiki/RGB_color_model)). When alpha compositing is in use, each pixel has an additional numeric value stored in its alpha channel, with a value ranging from 0 to 1. A value of 0 means that the pixel is fully transparent and the color in the pixel beneath will show through. A value of 1 means that the pixel is fully opaque.

With the existence of an alpha channel, it is possible to express compositing image operations using a compositing algebra. For example, given two images A and B, the most common compositing operation is to combine the images so that A appears in the foreground and B appears in the background. This can be expressed as A over B. In addition to over, Porter and Duff defined the compositing operators in, held out by (the phrase refers to [holdout matting](https://en.wikipedia.org/wiki/Matte_(filmmaking)#Garbage_and_holdout_mattes) and is usually abbreviated out), atop, and xor (and the reverse operators rover, rin, rout, and ratop) from a consideration of choices in blending the colors of two pixels when their coverage is, conceptually, overlaid orthogonally:

</br>

<img width="642" height="308" alt="Alpha_compositing" src="https://github.com/user-attachments/assets/fe3611e4-4507-48cb-9a8d-4897e14e4d8f" />

</br>

# Image formats supporting alpha channels:
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




