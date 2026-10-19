import 'package:image_picker/image_picker.dart';

class PlantImagePicker {
  final ImagePicker _picker;

  PlantImagePicker({
    ImagePicker? picker,
  }) : _picker =
            picker ??
                ImagePicker();

  Future<String?> gallery() async {
    final XFile? image =
        await _picker.pickImage(
      source:
          ImageSource.gallery,

      imageQuality:
          75,

      maxWidth:
          1440,

      maxHeight:
          1440,
    );

    return image?.path;
  }

  Future<String?> camera() async {
    final XFile? image =
        await _picker.pickImage(
      source:
          ImageSource.camera,

      imageQuality:
          75,

      maxWidth:
          1440,

      maxHeight:
          1440,
    );

    return image?.path;
  }
}