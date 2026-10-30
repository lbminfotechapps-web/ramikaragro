// class FarmerOption {
//   final String id;
//   final String name;
//   final String talukaName;
//   final int plotStatus;

//   const FarmerOption({
//     required this.id,
//     required this.name,
//     this.talukaName = '',
//     this.plotStatus = 0,
//   });
// }

// class CropOption {
//   final String id;
//   final String name;

//   const CropOption({
//     required this.id,
//     required this.name,
//   });
// }

// class PlotEntry {
//   final String localId;
//   final String plotName;
//   final String acres;
//   final FarmerOption? farmer;
//   final CropOption? crop;
//   final DateTime? sowingDate;

//   const PlotEntry({
//     required this.localId,
//     this.plotName = '',
//     this.acres = '',
//     this.farmer,
//     this.crop,
//     this.sowingDate,
//   });

//   PlotEntry copyWith({
//     String? plotName,
//     String? acres,
//     FarmerOption? farmer,
//     CropOption? crop,
//     DateTime? sowingDate,
//   }) {
//     return PlotEntry(
//       localId: localId,
//       plotName: plotName ?? this.plotName,
//       acres: acres ?? this.acres,
//       farmer: farmer ?? this.farmer,
//       crop: crop ?? this.crop,
//       sowingDate: sowingDate ?? this.sowingDate,
//     );
//   }
// }

// class PlotSubmission {
//   final String empId;
//   final List<PlotEntry> plots;

//   const PlotSubmission({
//     required this.empId,
//     required this.plots,
//   });
// }

// class PlotSubmitResult {
//   final bool status;
//   final String message;
//   final dynamic result;
//   final dynamic plotId;
//   final Map<String, dynamic> rawResponse;

//   const PlotSubmitResult({
//     required this.status,
//     required this.message,
//     required this.result,
//     required this.plotId,
//     required this.rawResponse,
//   });
// }

class FarmerOption {
  final String id;
  final String name;
  final String talukaName;
  final int plotStatus;

  const FarmerOption({
    required this.id,
    required this.name,
    this.talukaName = '',
    this.plotStatus = 0,
  });
}

class CropOption {
  final String id;
  final String name;

  const CropOption({required this.id, required this.name});
}

class PlotEntry {
  final String localId;
  final String plotName;
  final String acres;
  final FarmerOption? farmer;
  final CropOption? crop;
  final DateTime? sowingDate;

  const PlotEntry({
    required this.localId,
    this.plotName = '',
    this.acres = '',
    this.farmer,
    this.crop,
    this.sowingDate,
  });

  PlotEntry copyWith({
    String? plotName,
    String? acres,
    FarmerOption? farmer,
    CropOption? crop,
    DateTime? sowingDate,
  }) {
    return PlotEntry(
      localId: localId,
      plotName: plotName ?? this.plotName,
      acres: acres ?? this.acres,
      farmer: farmer ?? this.farmer,
      crop: crop ?? this.crop,
      sowingDate: sowingDate ?? this.sowingDate,
    );
  }

  bool get isBlank =>
      plotName.trim().isEmpty &&
      acres.trim().isEmpty &&
      crop == null &&
      sowingDate == null;

  bool get hasValidAcres {
    final value = double.tryParse(acres.trim());
    return value != null && value.isFinite && value > 0;
  }

  bool get isComplete =>
      hasValidAcres &&
      plotName.trim().isNotEmpty &&
      farmer?.id.trim().isNotEmpty == true &&
      crop?.id.trim().isNotEmpty == true &&
      sowingDate != null;
}

class PlotSubmission {
  final String empId;
  final List<PlotEntry> plots;

  const PlotSubmission({required this.empId, required this.plots});
}

class PlotSubmitResult {
  final bool status;
  final String message;
  final String result;
  final List<int> plotIds;
  final Map<String, dynamic> rawResponse;

  const PlotSubmitResult({
    required this.status,
    required this.message,
    required this.result,
    required this.plotIds,
    required this.rawResponse,
  });

  int get totalPlots => plotIds.length;
}
