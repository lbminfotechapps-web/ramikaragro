// import '../../domain/entities/plot_entities.dart';

// class PlotModel {
//   static String _read(Map<String, dynamic> json, String key) {
//     return json[key]?.toString().trim() ?? '';
//   }

//   static FarmerOption farmerFromJson(Map<String, dynamic> json) {
//     return FarmerOption(
//       id: _read(json, 'fld_farmer_id'),
//       name: _read(json, 'fld_farmer_name'),
//       talukaName: _read(json, 'fld_taluka_name'),
//       plotStatus: int.tryParse(_read(json, 'farmer_plot_status')) ?? 0,
//     );
//   }

//   static CropOption cropFromJson(Map<String, dynamic> json) {
//     return CropOption(
//       // Do not invent an ID if backend omits it.
//       id: _read(json, 'fld_crop_id'),
//       name: _read(json, 'fld_crop_name'),
//     );
//   }

//   static String formatDate(DateTime date) {
//     final d = date.day.toString().padLeft(2, '0');
//     final m = date.month.toString().padLeft(2, '0');

//     return '$d-$m-${date.year}';
//   }

//   // Display drafts safely; submission still uses validated, complete entries.
//   static Map<String, dynamic> previewJson(PlotEntry plot) {
//     final date = plot.sowingDate;
//     return {
//       'plotName': plot.plotName.trim(),
//       'scheduleDate': date == null ? null : formatDate(date),
//       'cropId': plot.crop?.id,
//       'farmerId': plot.farmer?.id,
//     };
//   }

//   static Map<String, dynamic> toJson(PlotSubmission submission) {
//     return {
//       'empId': submission.empId,
//       'plots': submission.plots.map((plot) {
//         return {
//           'plotName': plot.plotName.trim(),
//           'scheduleDate': formatDate(plot.sowingDate!),
//           'cropId': plot.crop!.id,
//           'farmerId': plot.farmer!.id,
//         };
//       }).toList(),
//     };
//   }

//   static PlotSubmitResult parseSubmitResponse(Map<String, dynamic> json) {
//     final value = json['status'];

//     final success =
//         value == true ||
//         value == 1 ||
//         value.toString().toLowerCase() == 'true' ||
//         value.toString() == '1';

//     return PlotSubmitResult(
//       status: success,
//       message:
//           json['message']?.toString() ??
//           (success ? 'Plots submitted successfully' : 'Submission failed'),
//       result: json['result'],
//       plotId: json['plotId'],
//       rawResponse: json,
//     );
//   }
// }



import '../../domain/entities/plot_entities.dart';

class PlotModel {
  static String _read(
    Map<String, dynamic> json,
    String key,
  ) {
    return json[key]?.toString().trim() ?? '';
  }

  static FarmerOption farmerFromJson(
    Map<String, dynamic> json,
  ) {
    return FarmerOption(
      id: _read(json, 'fld_farmer_id'),
      name: _read(json, 'fld_farmer_name'),
      talukaName: _read(json, 'fld_taluka_name'),
      plotStatus:
          int.tryParse(_read(json, 'farmer_plot_status')) ?? 0,
    );
  }

  static CropOption cropFromJson(
    Map<String, dynamic> json,
  ) {
    return CropOption(
      id: _read(json, 'fld_crop_id'),
      name: _read(json, 'fld_crop_name'),
    );
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  static Map<String, dynamic> previewJson(
    PlotEntry plot,
  ) {
    return {
      'plotName': plot.plotName.trim(),
      'scheduleDate': plot.sowingDate == null
          ? null
          : formatDate(plot.sowingDate!),
      'cropId': plot.crop?.id,
      'farmerId': plot.farmer?.id,
    };
  }

  // Creates the logical request data.
  // Datasource will JSON-encode only the plots array.
  static Map<String, dynamic> toJson(
    PlotSubmission submission,
  ) {
    return {
      'empId': submission.empId,
      'plots': submission.plots.map((plot) {
        return {
          'plotName': plot.plotName.trim(),
          'scheduleDate': formatDate(plot.sowingDate!),
          'cropId': plot.crop!.id,
          'farmerId': plot.farmer!.id,
        };
      }).toList(),
    };
  }

  static PlotSubmitResult parseSubmitResponse(
    Map<String, dynamic> json,
  ) {
    final value = json['status'];

    final success =
        value == true ||
        value == 1 ||
        value.toString().toLowerCase() == 'true';

    final ids = <int>[];
    final rawIds = json['plotIds'];

    if (rawIds is List) {
      for (final value in rawIds) {
        final parsed = int.tryParse(value.toString());

        if (parsed == null) {
          throw const FormatException(
            'Invalid plot ID received from server',
          );
        }

        ids.add(parsed);
      }
    } else if (success) {
      throw const FormatException(
        'Successful response missing plotIds array',
      );
    }

    return PlotSubmitResult(
      status: success,
      result: json['result']?.toString() ?? '',
      message: json['message']?.toString() ??
          (success ? 'Plots added successfully' : 'Failed to add plots'),
      plotIds: ids,
      rawResponse: json,
    );
  }
}

