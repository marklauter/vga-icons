using Icons.CLI;

var filenames = IO.ReadFileNames();
foreach (var filename in filenames)
{
    var (data, width, height) = await IO.ReadIconAsync(filename);

    var imageOut = VGA.ReadImage(
        width,
        height,
        data);

    IO.SaveBitmap(
        filename,
        width,
        height,
        imageOut);
}

{
    var filename = "intlane";

    var (data, width, height) = await IO.ReadLogoAsync(filename);

    var imageOut = VGA.ReadImage(
        width,
        height,
        data);

    IO.SaveBitmap(
        filename,
        width,
        height,
        imageOut);
}