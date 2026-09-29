abstract class SelfTargetEvent {
  const SelfTargetEvent();
}

// ============================================================
// LOAD PRODUCT GROUPS
// ============================================================

class GetSelfTargetEvent extends SelfTargetEvent {
  const GetSelfTargetEvent();
}

// ============================================================
// MONTH CHANGE
// ============================================================

class ChangeSelfTargetMonthEvent extends SelfTargetEvent {
  final String month;

  const ChangeSelfTargetMonthEvent({
    required this.month,
  });
}

// ============================================================
// SUBMIT SELF TARGET
// ============================================================

class SubmitSelfTargetEvent extends SelfTargetEvent {
  final String userId;
  final String month;
  final String groupId;
  final String points;

  const SubmitSelfTargetEvent({
    required this.userId,
    required this.month,
    required this.groupId,
    required this.points,
  });
}