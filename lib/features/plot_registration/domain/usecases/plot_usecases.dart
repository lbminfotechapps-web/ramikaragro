
// import '../entities/plot_entities.dart';
// import '../repositories/plot_repository.dart';

// class SearchPlotFarmers {
//   final PlotRepository repository;

//   const SearchPlotFarmers(this.repository);

//   Future<List<FarmerOption>> call(String search) {
//     return repository.searchFarmers(search);
//   }
// }

// class GetPlotCrops {
//   final PlotRepository repository;

//   const GetPlotCrops(this.repository);

//   Future<List<CropOption>> call() {
//     return repository.getCrops();
//   }
// }

// class SubmitPlotRegistration {
//   final PlotRepository repository;

//   const SubmitPlotRegistration(this.repository);

//   Future<PlotSubmitResult> call(
//     PlotSubmission submission,
//   ) {
//     if (submission.empId.isEmpty ||
//         submission.empId == '0') {
//       throw Exception('Please login again');
//     }

//     if (submission.plots.isEmpty) {
//       throw Exception('Add at least one plot');
//     }

//     for (var i = 0; i < submission.plots.length; i++) {
//       final plot = submission.plots[i];
//       final no = i + 1;

//       if (plot.plotName.trim().isEmpty) {
//         throw Exception('Enter Plot $no name');
//       }

//       if (plot.farmer == null ||
//           plot.farmer!.id.isEmpty) {
//         throw Exception('Select farmer for Plot $no');
//       }

//       if (plot.crop == null ||
//           plot.crop!.id.isEmpty) {
//         throw Exception(
//           'Valid Crop ID required for Plot $no. '
//           'Please ask backend to return fld_crop_id.',
//         );
//       }

//       if (plot.sowingDate == null) {
//         throw Exception(
//           'Select sowing date for Plot $no',
//         );
//       }
//     }

//     return repository.submitPlots(submission);
//   }
// }


import '../entities/plot_entities.dart';
import '../repositories/plot_repository.dart';

class SearchPlotFarmers {
  final PlotRepository repository;

  const SearchPlotFarmers(this.repository);

  Future<List<FarmerOption>> call(String search) {
    return repository.searchFarmers(search);
  }
}

class GetPlotCrops {
  final PlotRepository repository;

  const GetPlotCrops(this.repository);

  Future<List<CropOption>> call() {
    return repository.getCrops();
  }
}

class SubmitPlotRegistration {
  final PlotRepository repository;

  const SubmitPlotRegistration(this.repository);

  Future<PlotSubmitResult> call(
    PlotSubmission submission,
  ) {
    if (submission.empId.trim().isEmpty ||
        submission.empId == '0') {
      throw Exception('Please login again');
    }

    if (submission.plots.isEmpty) {
      throw Exception('Add at least one plot');
    }

    for (var i = 0; i < submission.plots.length; i++) {
      final plot = submission.plots[i];

      if (!plot.isComplete) {
        throw Exception(
          'Complete all required fields for Plot ${i + 1}',
        );
      }
    }

    return repository.submitPlots(submission);
  }
}

