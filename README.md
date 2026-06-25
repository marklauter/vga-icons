# vga-icons

A small .NET command-line tool that decodes VGA 16-color planar icon (`.ico`) and logo (`.lgo`) files into `.bmp` bitmaps. It unpacks the four-bitplane layout that EGA and VGA hardware used — each pixel's color is the same bit position read across four color planes — and remaps the 16-color palette to `System.Drawing` colors.

The art is from [LaneView](https://github.com/marklauter/LaneView), TeCom Inc.'s mid-1990s DOS residential energy-management system. The `.ico` files and the `intlane.lgo` logo bundled here are LaneView's own VGA assets (`intlane` for Interlane, the product's internal name); the palette in `Colors.cs` comes from `VGACON.ASM`, one of the VGA libraries LaneView depended on. This tool exists to view that art again.

## Layout

- `Program.cs` — enumerates the bundled files, decodes each, and saves a `.bmp`.
- `IO.cs` — reads the planar files past their 10-byte header and saves bitmaps through `System.Drawing.Common`.
- `VGA.cs` — separates the four bitplanes and extracts per-pixel color.
- `Colors.cs` — maps the 16 VGA color codes to `System.Drawing` colors.

## Run

```
dotnet run --project Icons.CLI
```

Targets net8.0 and depends on `System.Drawing.Common`, so it runs on Windows. Image dimensions are currently hardcoded (24×24 for icons, 496×226 for the logo) pending reading them from the file header.

See the [wiki](https://github.com/marklauter/vga-icons/wiki) for more.
