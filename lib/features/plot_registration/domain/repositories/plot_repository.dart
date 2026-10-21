
// import '../entities/plot_entities.dart';

// abstract class PlotRepository {
//   Future<List<FarmerOption>> searchFarmers(
//     String farmerName,
//   );

//   Future<List<CropOption>> getCrops();

//   Future<PlotSubmitResult> submitPlots(
//     PlotSubmission submission,
//   );
// }


import '../entities/plot_entities.dart';

abstract class PlotRepository {
  Future<List<FarmerOption>> searchFarmers(
    String farmerName,
  );

  Future<List<CropOption>> getCrops();

  Future<PlotSubmitResult> submitPlots(
    PlotSubmission submission,
  );
}

