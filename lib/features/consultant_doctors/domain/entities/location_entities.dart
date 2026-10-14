
class StateEntity {
  final String id;
  final String name;

  const StateEntity({
    required this.id,
    required this.name,
  });
}

class TalukaEntity {
  final String id;
  final String districtId;
  final String name;

  const TalukaEntity({
    required this.id,
    required this.districtId,
    required this.name,
  });
}

class DistrictEntity {
  final String id;
  final String name;
  final List<TalukaEntity> talukas;

  const DistrictEntity({
    required this.id,
    required this.name,
    required this.talukas,
  });
}
