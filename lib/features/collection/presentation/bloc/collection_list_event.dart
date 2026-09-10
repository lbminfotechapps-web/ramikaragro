abstract class CollectionListEvent {
  const CollectionListEvent();
}

class GetCollectionListEvent
    extends CollectionListEvent {
  final String userId;
  final String strMonth;
  final String strStatus;

  final int startLimit;
  final int pageSize;

  const GetCollectionListEvent({
    required this.userId,
    required this.strMonth,
    required this.strStatus,
    required this.startLimit,
    required this.pageSize,
  });
}