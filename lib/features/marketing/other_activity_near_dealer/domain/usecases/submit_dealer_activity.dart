import 'dart:io';

import '../entities/dealer_activity.dart';
import '../repositories/dealer_activity_repository.dart';

class SubmitDealerActivity {
  final DealerActivityRepository repository;

  const SubmitDealerActivity(this.repository);

  Future<String> call(DealerActivity activity) async {
    if (activity.loginUserId.trim().isEmpty ||
        activity.loginUserId == '0') {
      throw StateError('Please log in again.');
    }

    if (activity.shopId.trim().isEmpty ||
        activity.shopId == '0') {
      throw StateError(
        'Please select a dealer or distributor.',
      );
    }

    if (activity.workDetails.trim().isEmpty) {
      throw StateError('Please enter work details.');
    }

    if (activity.discussionAbout.trim().isEmpty) {
      throw StateError('Please enter discussion details.');
    }

    if (activity.workDone.trim().isEmpty) {
      throw StateError('Please enter work done.');
    }

    if (activity.output.trim().isEmpty) {
      throw StateError('Please enter output.');
    }

    if (activity.kmReading.trim().isNotEmpty &&
        double.tryParse(activity.kmReading.trim()) == null) {
      throw StateError('Enter a valid KM reading.');
    }

    if (activity.manualDistance.trim().isNotEmpty &&
        double.tryParse(activity.manualDistance.trim()) == null) {
      throw StateError('Enter a valid manual distance.');
    }

    // These photos are mandatory for this Flutter form.
    // The supplied Java method itself does not prove
    // whether the server makes them mandatory.
    if (activity.dealerImagePath.trim().isEmpty ||
        !await File(activity.dealerImagePath).exists()) {
      throw StateError(
        'Please capture dealer/distributor proof image.',
      );
    }

    if (activity.shopBoardImagePath.trim().isEmpty ||
        !await File(activity.shopBoardImagePath).exists()) {
      throw StateError(
        'Please capture shop board image.',
      );
    }

    return repository.submitActivity(activity);
  }
}