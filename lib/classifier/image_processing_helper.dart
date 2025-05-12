import 'dart:io';
import 'package:image/image.dart' as img;

img.Image? processImage(String path) {
  final bytes = File(path).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  final minLength = image.width < image.height ? image.width : image.height;
  final xOffset = ((image.width - minLength) / 2).round();
  final yOffset = ((image.height - minLength) / 2).round();

  final cropped = img.copyCrop(image,
      x: xOffset, y: yOffset, width: minLength, height: minLength);
  final resized = img.copyResize(cropped, width: 224, height: 224);

  return resized;
}
