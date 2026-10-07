class ExpensePerformance {
  final List<ExpensePerformanceItem> expenses;

  final double totalExpense;
  final int totalEntryCount;
  final double totalShare;

  final double dailyExpense;
  final double totalKilometer;
  final double approvedAmount;
  final double travelingExpenses;
  final double daExpenses;

  final List<String> selectedMonths;
  final String financialYearLabel;

  const ExpensePerformance({
    required this.expenses,
    required this.totalExpense,
    required this.totalEntryCount,
    required this.totalShare,
    required this.dailyExpense,
    required this.totalKilometer,
    required this.approvedAmount,
    required this.travelingExpenses,
    required this.daExpenses,
    required this.selectedMonths,
    required this.financialYearLabel,
  });
}

class ExpensePerformanceItem {
  final String parameterId;
  final String parameterName;

  final double amount;
  final int entryCount;
  final double sharePercent;

  const ExpensePerformanceItem({
    required this.parameterId,
    required this.parameterName,
    required this.amount,
    required this.entryCount,
    required this.sharePercent,
  });
}