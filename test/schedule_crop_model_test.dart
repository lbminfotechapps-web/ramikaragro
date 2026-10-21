import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/data/models/crop_model.dart';

void main() {
  test('crop search retains API IDs for schedule selection', () {
    for (final id in [
      '1',
      '2',
      '3',
      '5',
      '7',
      '8',
      '9',
      '141',
      '142',
      '143',
      '145',
      '146',
      '147',
      '148',
      '149',
    ]) {
      final crop = CropModel.fromJson({
        'fld_crop_name': 'Grapes (द्राक्षे)',
        'fld_crop_id': id,
      });
      expect(crop.cropId, id);
      expect(crop.cropName, 'Grapes (द्राक्षे)');
    }
  });
  test(
    'crop IDs accept numbers, trim strings and do not invent missing IDs',
    () {
      expect(CropModel.fromJson({'fld_crop_id': 141}).cropId, '141');
      expect(CropModel.fromJson({'fld_crop_id': ' 2 '}).cropId, '2');
      expect(CropModel.fromJson({'fld_crop_name': 'Crop'}).cropId, isEmpty);
    },
  );
  test('crop equality includes ID', () {
    expect(
      const CropModel(cropName: 'Crop', cropId: '1'),
      isNot(const CropModel(cropName: 'Crop', cropId: '2')),
    );
  });
}
