namespace Icons.CLI;

// https://wiki.osdev.org/VGA_Hardware

/* 
  http://www.techhelpmanual.com/89-video_memory_layouts.html
  EGA 320x200, 16-color (video mode 0dH)
  Segment: a000
  Layout: 4-plane planar.  Each pixel color is determined by the combined
          value of bits in the four color planes.  Each color plane begins
          at a000:0.  To select a plane, use:

            OUT 3ceH, 0005H         ;set up for plane masking
            OUT 3c4H, n             ;n is: 0102H=plane 0; 0202H=plane 1
                                    ;      0402H=plane 2; 0802H=plane 3
            ...(write video data)...
            OUT 3c4H, 0f02H         ;restore normal plane mask

          Each scan line is 40 bytes long and there are 200 scan lines
          (regen size=16,000 bytes * 4 planes).  Each byte contains
          8 pixels (64,000 total pixels):
          ╓7┬6┬5┬4┬3┬2┬1┬0╖
          ║ │ │ │ │ │ │ │ ║
          ╙╥┴╥┴╥┴╥┴╥┴╥┴╥┴╥╜  bits mask
           ║ ║ ║ ║ ║ ║ ║ ╚══► 0:  01H  eighth pixel in byte
           ║ ║ ║ ║ ║ ║ ╚════► 1:  02H  seventh pixel in byte
           ║ ║ ║ ║ ║ ╚══════► 2:  04H  sixth pixel in byte
           ║ ║ ║ ║ ╚════════► 3:  08H  fifth pixel in byte
           ║ ║ ║ ╚══════════► 4:  10H  fourth pixel in byte
           ║ ║ ╚════════════► 5:  20H  third pixel in byte
           ║ ╚══════════════► 6:  40H  second pixel in byte
           ╚════════════════► 7:  80H  first pixel in byte
                                       0=color OFF; 1=color ON

          The pixel color depends on the 4-bit value (0-15) obtained by
          combining the same bit position in each plane.  Default settings
          are:   0H black     8H gray
                 1H blue      9H bright blue
                 2H green     aH bright green
                 3H cyan      bH bright cyan
                 4H red       cH bright red
                 5H magenta   dH bright magenta
                 6H brown     eH yellow
                 7H white     fH bright white
          For instance, to make a pixel blue, the combined planes must
          equal 01H; that is the bit in plane 0 is set and the bits in
          planes 1,2, and 3 are clear.

          The actual colors depend on the palette (see INT 10H 1000H).
*/

internal static class VGA
{
    public const int Planes = 4; // 16 colors = 4 bits, 1 bit per plane

    /// <summary>
    /// reads a single plane from the image by calulating the plane offset from the plane index, image height and width in bytes
    /// </summary>
    private static byte[] ReadPlane(
        int planeIndex,
        int scanLines,
        int widthInBytes,
        byte[] image)
    {
        var offset = planeIndex * widthInBytes * scanLines;
        var plane = new byte[widthInBytes * scanLines];
        Array.ConstrainedCopy(
            image,
            offset,
            plane,
            0,
            plane.Length);

        return plane;
    }

    /// <summary>
    /// separates 16 color VGA planar format into 4 planes
    /// </summary>
    private static byte[][] ReadPlanes(
        int scanLines,
        int widthInBytes,
        byte[] image)
    {
        var planes = new byte[Planes][];
        for (var i = 0; i < Planes; ++i)
        {
            planes[i] = ReadPlane(
                i,
                scanLines,
                widthInBytes,
                image);
        }

        return planes;
    }

    /// <summary>
    /// combines 4 planes into single pixel based on the bit offset
    /// </summary>
    private static byte ReadPixel(
        int pixelBit,
        byte[] planeBytes)
    {
        var pixel = 0x00;
        var pixelMask = 0x80 >> pixelBit;
        for (var i = 0; i < planeBytes.Length; ++i)
        {
            if ((planeBytes[i] & pixelMask) != 0)
            {
                pixel |= 0x01 << i;
            }
        }

        return (byte)pixel;
    }

    /// <summary>
    /// returns an array of plane bytes for a given offset
    /// </summary>
    private static byte[] ReadPlaneBytes(int offset, byte[][] planes)
    {
        var planeBytes = new byte[Planes];
        for (var i = 0; i < Planes; ++i)
        {
            planeBytes[i] = planes[i][offset];
        }

        return planeBytes;
    }

    /// <summary>
    /// converts 16 color VGA planar format to a single byte per pixel
    /// </summary>
    public static byte[,] ReadImage(
        int width,
        int height,
        byte[] imageIn)
    {
        // bit layout
        // plane 3 = 0, plane 2 = 1, plane 1 = 0, plane 0 = 1
        // 0101
        // plane 0 is the least significant bit
        var widthInBytes = width / 8;

        var planes = VGA.ReadPlanes(
            height,
            widthInBytes,
            imageIn);

        var imageOut = new byte[widthInBytes * 8, height];
        for (var row = 0; row < height; ++row)
        {
            for (var byteIndex = 0; byteIndex < widthInBytes; ++byteIndex)
            {
                var offset = row * widthInBytes + byteIndex;
                var planeBytes = ReadPlaneBytes(
                    offset,
                    planes);

                for (var bit = 0; bit < 8; ++bit)
                {
                    var col = byteIndex * 8 + bit;
                    imageOut[col, row] = ReadPixel(
                        bit,
                        planeBytes);
                }
            }
        }

        return imageOut;
    }
}

