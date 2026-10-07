import '../../domain/entities/expense_performance.dart';

class ExpensePerformanceModel
    extends ExpensePerformance {
  const ExpensePerformanceModel({
    required super.expenses,
    required super.totalExpense,
    required super.totalEntryCount,
    required super.totalShare,
    required super.dailyExpense,
    required super.totalKilometer,
    required super.approvedAmount,
    required super.travelingExpenses,
    required super.daExpenses,
    required super.selectedMonths,
    required super.financialYearLabel,
  });

  factory ExpensePerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawResult =
        json['result'] is List
            ? json['result'] as List<dynamic>
            : <dynamic>[];

    ExpensePerformanceItemModel? total;

    final List<ExpensePerformanceItem>
        expenses = [];

    for (final dynamic raw in rawResult) {
      if (raw is! Map) {
        continue;
      }

      final item =
          ExpensePerformanceItemModel.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (item.parameterId ==
              'total_selected' ||
          item.parameterName
                  .trim()
                  .toLowerCase() ==
              'total') {
        total = item;
      } else {
        expenses.add(item);
      }
    }

    final Map<String, dynamic> summary =
        json['summary'] is Map
            ? Map<String, dynamic>.from(
                json['summary'] as Map,
              )
            : <String, dynamic>{};

    return ExpensePerformanceModel(
      expenses: expenses,

      totalExpense:
          total?.amount ?? 0,

      totalEntryCount:
          total?.entryCount ?? 0,

      totalShare:
          total?.sharePercent ?? 0,

      dailyExpense:
          _toDouble(
        summary['daily_expense'],
      ),

      totalKilometer:
          _toDouble(
        summary['total_kilometer'],
      ),

      approvedAmount:
          _toDouble(
        summary['approved_amount'],
      ),

      travelingExpenses:
          _toDouble(
        summary['traveling_expenses'],
      ),

      daExpenses:
          _toDouble(
        summary['da_expenses'],
      ),

      selectedMonths:
          json['selected_months'] is List
              ? (json['selected_months']
                      as List)
                  .map(
                    (e) =>
                        e.toString(),
                  )
                  .toList()
              : <String>[],

      financialYearLabel:
          json['fy_label']
                  ?.toString() ??
              '',
    );
  }

  static double _toDouble(
    dynamic value,
  ) {
    return double.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }
}

class ExpensePerformanceItemModel
    extends ExpensePerformanceItem {
  const ExpensePerformanceItemModel({
    required super.parameterId,
    required super.parameterName,
    required super.amount,
    required super.entryCount,
    required super.sharePercent,
  });

  factory ExpensePerformanceItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExpensePerformanceItemModel(
      parameterId:
          json['parameter_id']
                  ?.toString() ??
              '',

      parameterName:
          json['parameter_name']
                  ?.toString() ??
              '',

      amount:
          _toDouble(
        json['amount'],
      ),

      entryCount:
          _toInt(
        json['entry_count'],
      ),

      sharePercent:
          _toDouble(
        json['share_percent'],
      ),
    );
  }

  static int _toInt(
    dynamic value,
  ) {
    return int.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }

  static double _toDouble(
    dynamic value,
  ) {
    return double.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }
}