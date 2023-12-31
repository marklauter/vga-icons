﻿using System.Drawing;

namespace Icons.CLI;

internal static class Colors
{
    // from VGACON.ASM
    //    ; Red,Grn,Blu
    //vga_pallet:

    //  db   00, 00, 00  ; color 0
    //	db   00, 00, 32  ; color 1
    //	db   00, 32, 00  ; color 2
    //	db   00, 32, 32  ; color 3
    //	db   32, 00, 00  ; color 4
    //	db   32, 00, 32  ; color 5
    //	db   32, 32, 00  ; color 6
    //	db   48, 48, 48  ; color 7
    //	db   32, 32, 32  ; color 8
    //	db   00, 00, 63  ; color 9
    //	db   00, 63, 00  ; color A
    //  db   00, 63, 63  ; color B
    //  db   63, 00, 00  ; color C
    //  db   63, 00, 63  ; color D
    //  db   63, 63, 00  ; color E
    //  db   63, 63, 63  ; color F

    /* http://www.techhelpmanual.com/89-video_memory_layouts.html
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

    public static Color GetColor(byte c)
    {
        return c switch
        {
            0x00 => Color.FromKnownColor(KnownColor.Black),
            0x01 => Color.FromKnownColor(KnownColor.DarkBlue),
            0x02 => Color.FromKnownColor(KnownColor.Green),
            0x03 => Color.FromKnownColor(KnownColor.Aqua),
            0x04 => Color.FromKnownColor(KnownColor.Maroon),
            0x05 => Color.FromKnownColor(KnownColor.DarkMagenta),
            0x06 => Color.FromKnownColor(KnownColor.Brown),
            0x07 => Color.FromKnownColor(KnownColor.Silver),
            0x08 => Color.FromKnownColor(KnownColor.Gray),
            0x09 => Color.FromKnownColor(KnownColor.Blue),
            0x0A => Color.FromKnownColor(KnownColor.Lime),
            0x0B => Color.FromKnownColor(KnownColor.Cyan),
            0x0C => Color.FromKnownColor(KnownColor.Red),
            0x0D => Color.FromKnownColor(KnownColor.Magenta),
            0x0E => Color.FromKnownColor(KnownColor.Yellow),
            0x0F => Color.FromKnownColor(KnownColor.White),
            _ => throw new NotSupportedException(),
        };
    }
}

