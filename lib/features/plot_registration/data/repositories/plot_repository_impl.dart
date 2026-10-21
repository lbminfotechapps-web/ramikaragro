
// import '../../domain/entities/plot_entities.dart';
// import '../../domain/repositories/plot_repository.dart';
// import '../datasources/plot_remote_data_source.dart';
// import '../models/plot_model.dart';

// class PlotRepositoryImpl implements PlotRepository {
//   final PlotRemoteDataSource remote;

//   const PlotRepositoryImpl({
//     required this.remote,
//   });

//   @override
//   Future<List<FarmerOption>> searchFarmers(
//     String farmerName,
//   ) async {
//     final data = await remote.searchFarmers(farmerName);

//     return data
//         .map(PlotModel.farmerFromJson)
//         .where(
//           (f) => f.id.isNotEmpty && f.name.isNotEmpty,
//         )
//         .toList();
//   }

//   @override
//   Future<List<CropOption>> getCrops() async {
//     final data = await remote.getCrops();

//     return data
//         .map(PlotModel.cropFromJson)
//         .where((c) => c.name.isNotEmpty)
//         .toList();
//   }

//   @override
//   Future<PlotSubmitResult> submitPlots(
//     PlotSubmission submission,
//   ) async {
//     final payload = PlotModel.toJson(submission);

//     final response = await remote.submit(payload);

//     final result =
//         PlotModel.parseSubmitResponse(response);

//     if (!result.status) {
//       throw Exception(result.message);
//     }

//     return result;
//   }
// }


import '../../domain/entities/plot_entities.dart';
import '../../domain/repositories/plot_repository.dart';
import '../datasources/plot_remote_data_source.dart';
import '../models/plot_model.dart';

class PlotRepositoryImpl implements PlotRepository {
  final PlotRemoteDataSource remote;

  const PlotRepositoryImpl({
    required this.remote,
  });

  @override
  Future<List<FarmerOption>> searchFarmers(
    String farmerName,
  ) async {
    final data = await remote.searchFarmers(farmerName);

    return data
        .map(PlotModel.farmerFromJson)
        .where((f) => f.id.isNotEmpty && f.name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<CropOption>> getCrops() async {
    final data = await remote.getCrops();

    return data
        .map(PlotModel.cropFromJson)
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  @override
  Future<PlotSubmitResult> submitPlots(
    PlotSubmission submission,
  ) async {
    final payload = PlotModel.toJson(submission);

    // Datasource converts plots to a JSON string
    // and sends empId and plots as two form fields.
    final response = await remote.submit(payload);

    final result = PlotModel.parseSubmitResponse(response);

    if (!result.status ||
        result.result.toLowerCase() != 'success') {
      throw Exception(result.message);
    }

    if (result.plotIds.length != submission.plots.length) {
      throw FormatException(
        'Server returned ${result.plotIds.length} '
        'plot IDs for ${submission.plots.length} plots. '
        'Check server records before retrying.',
      );
    }

    return result;
  }
}

