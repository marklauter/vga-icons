using System.Drawing;
using System.Drawing.Imaging;

namespace Icons.CLI;

internal static class IO
{
    // skip 10 bytes of meta data
    private const int bitmapOffset = 10;

    public static IEnumerable<string> ReadFileNames()
    {
        var path = "icons";
        var names = Directory.GetFiles(path, "*.ico");
        return names
            .Select(names => Path.GetFileNameWithoutExtension(names));
    }

    public static async Task<(byte[] data, int width, int height)> ReadIconAsync(string filename)
    {
        var inputFileName = Path.Combine("icons", $"{filename}.ico");
        var bytes = await File.ReadAllBytesAsync(inputFileName);
        var image = new byte[bytes.Length - bitmapOffset];
        Array.ConstrainedCopy(
            bytes,
            bitmapOffset,
            image,
            0,
            image.Length);

        // todo: read width and height from image file (it's in the first 10 bytes)
        return (image, 24, 24);
    }

    public static async Task<(byte[] data, int width, int height)> ReadLogoAsync(string filename)
    {
        var inputFileName = Path.Combine("icons", $"{filename}.lgo");
        var bytes = await File.ReadAllBytesAsync(inputFileName);
        var image = new byte[bytes.Length - bitmapOffset];
        Array.ConstrainedCopy(
            bytes,
            bitmapOffset,
            image,
            0,
            image.Length);

        // todo: read width and height from image file (it's in the first 10 bytes)
        return (image, 496, 226);
    }

    [System.Diagnostics.CodeAnalysis.SuppressMessage("Interoperability", "CA1416:Validate platform compatibility", Justification = "<Pending>")]
    public static void SaveBitmap(
        string filename,
        int width,
        int height,
        byte[,] image)
    {
        var bmp = new Bitmap(
            width,
            height,
            PixelFormat.Format24bppRgb);

        for (var x = 0; x < width; x++)
        {
            for (var y = 0; y < height; y++)
            {
                var c = image[x, y];
                var color = Colors.GetColor(c);
                bmp.SetPixel(x, y, color);
            }
        }

        var output = Path.Combine("icons", $"{filename}.bmp");
        bmp.Save(output, ImageFormat.Bmp);
    }
}

