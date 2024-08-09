import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

const quality = 30;

class ImageCompressor {
  static Future<String> compressImageFromFile(String filePath) async {
    try {
      File file = File(filePath);
      Uint8List imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception("Could not decode image");
      }

      List<int> compressedBytes = img.encodeJpg(image, quality: quality);
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File compressedFile = File('$tempPath/compressed_image.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile.path;
    } catch (e) {
      return filePath;
    }
  }

  static Future<Uint8List> compressImageFromBytes(Uint8List imageBytes) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception("Could not decode image");
      }

      List<int> compressedBytes = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      return imageBytes;
    }
  }
}
