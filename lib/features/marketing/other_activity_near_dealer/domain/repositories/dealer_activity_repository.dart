import '../entities/dealer_activity.dart';

abstract class DealerActivityRepository {
  Future<String> submitActivity(
    DealerActivity activity,
  );
}