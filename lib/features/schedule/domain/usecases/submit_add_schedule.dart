
import '../entities/add_schedule_request.dart';
import '../repositories/add_schedule_repository.dart';

class SubmitAddSchedule {
  final AddScheduleRepository repository;

  const SubmitAddSchedule(this.repository);

  Future<AddScheduleResult> call(
    AddScheduleRequest request,
  ) {
    if (request.empId.trim().isEmpty ||
        request.empId.trim() == '0') {
      throw Exception('Please login again');
    }

    if (request.farmerId.trim().isEmpty) {
      throw Exception('Please select a farmer');
    }

    if (request.plotId.trim().isEmpty) {
      throw Exception('Please select a registered plot');
    }

    if (request.details.isEmpty) {
      throw Exception('Add at least one schedule product');
    }

    for (var i = 0; i < request.details.length; i++) {
      final item = request.details[i];
      final number = i + 1;

      if (item.cropId.trim().isEmpty) {
        throw Exception('Crop ID missing for product $number');
      }

      if (item.productName.trim().isEmpty) {
        throw Exception('Enter product name for item $number');
      }

      if (item.productType.trim().isEmpty ||
          item.productType == 'Select Type') {
        throw Exception('Select product type for item $number');
      }

      final qty = double.tryParse(item.productQty.trim());

      if (qty == null || !qty.isFinite || qty <= 0) {
        throw Exception('Enter valid quantity for item $number');
      }

      if (item.unit.trim().isEmpty ||
          item.unit == 'Select Unit') {
        throw Exception('Select quantity unit for item $number');
      }

      final water = double.tryParse(item.waterQty.trim());

      if (water == null || !water.isFinite || water <= 0) {
        throw Exception('Enter valid water quantity for item $number');
      }

      if (item.waterUnit.trim().isEmpty ||
          item.waterUnit == 'Select Unit') {
        throw Exception('Select water unit for item $number');
      }
    }

    return repository.submit(request);
  }
}
