import 'dart:io';

import 'package:path/path.dart';

mixin ImageMixin {
  static Directory docsDir;

  File imageTempFile() {
    return File(imageTempFilename());
  }

  String imageTempFilename() {
    return join(docsDir.path, "image_temp");
  }

  String imageFilenameFromID(int id) {
    return join(docsDir.path, id.toString());
  }

  String imageFilenameFromString(String name) {
    return join(docsDir.path, name);
  }
}