import '../../domain/entities/dealer_activity.dart';

class DealerActivityModel {
  final DealerActivity activity;

  const DealerActivityModel(this.activity);

  Map<String, String> toFields() {
    return {
      'strShopId': activity.shopId,
      'workDetails': activity.workDetails.trim(),
      'discussionAbout': activity.discussionAbout.trim(),
      'workDone': activity.workDone.trim(),
      'output': activity.output.trim(),
      'kmReading': activity.kmReading.trim(),
      'manualDistance': activity.manualDistance.trim(),
      'userId': activity.loginUserId,
      'activityId': '15',
    };
  }
}