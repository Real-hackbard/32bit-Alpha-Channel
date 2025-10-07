# 32bit-Alpha-Channel:

</br>

```ruby
Compiler    : Delphi10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney, 11 Alexandria, 12 Athens
Components  : PNGImage.pas, GIFImg.pas, crBitmap32.pas, BmpGrD12.pas
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

### Features
* Adjust Alpha Channels
* Selct Pixel Format
* Export Format : *.BMP, *.JPG/JPEG, *.PNG, *.GIF
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
| DIB header | No | Fixed-size (7 different versions exist) | Detailed information and pixel format | Immediately follows the Bitmap file header |
| Extra bit masks | Yes | 12 or 16 | Pixel format | Present only in case the DIB header is the BITMAPINFOHEADER and the Compression Method member is set to either BI_BITFIELDS or BI_ALPHABITFIELDS |
| Color table | Depends | Varies | Colors (Pixel array) | Mandatory for color depths ≤ 8 bits |
| Gap1 | Yes | Varies | Structure alignment | An artifact of the File offset to Pixel array in the Bitmap file header |
| Pixel array | No | Varies | Pixel values | The pixel format is defined by the DIB header or Extra bit masks. Each row in the Pixel array is padded to a multiple of 4 bytes in size |
| Gap2 | Yes | Varies	 | Structure alignment | An artifact of the ICC profile data offset field in the DIB header |
| ICC color profile | Yes | Varies | Color profile (for color management) | Can also contain a path to an external file containing the color profile. When loaded in memory as "non-packed DIB", it is located between the color table and Gap1. |












