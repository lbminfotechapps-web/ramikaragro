import 'package:demo/features/addexpense/domain/entities/expense_parameter_entity.dart';
import 'package:demo/features/addexpense/domain/entities/vehicle_entity.dart';
import 'package:equatable/equatable.dart';

enum ExpenseStatus { initial, loading, loaded, submitting, success, error }

class ExpenseState extends Equatable {
  final ExpenseStatus status;

  final List<VehicleEntity> vehicles;
  final List<ExpenseParameterEntity> expenses;

  final VehicleEntity? selectedVehicle;

  final String errorMessage;

  final int expStatus;
  final int allowedDays;

  final double localDa;
  final double nightDa;
  final double apiKmLimit;

  final String fldOpeningClosingKm;

  final String? successMessage;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.vehicles = const [],
    this.expenses = const [],
    this.selectedVehicle,
    this.errorMessage = '',
    this.expStatus = -1,
    this.allowedDays = 0,
    this.localDa = 0,
    this.nightDa = 0,
    this.apiKmLimit = 0,
    this.fldOpeningClosingKm = '',
    this.successMessage,
  });

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<VehicleEntity>? vehicles,
    List<ExpenseParameterEntity>? expenses,
    VehicleEntity? selectedVehicle,
    String? errorMessage,
    int? expStatus,
    int? allowedDays,
    double? localDa,
    double? nightDa,
    double? apiKmLimit,
    String? fldOpeningClosingKm,
    String? successMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      expenses: expenses ?? this.expenses,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      errorMessage: errorMessage ?? this.errorMessage,
      expStatus: expStatus ?? this.expStatus,
      allowedDays: allowedDays ?? this.allowedDays,
      localDa: localDa ?? this.localDa,
      nightDa: nightDa ?? this.nightDa,
      apiKmLimit: apiKmLimit ?? this.apiKmLimit,
      fldOpeningClosingKm: fldOpeningClosingKm ?? this.fldOpeningClosingKm,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vehicles,
    expenses,
    selectedVehicle,
    errorMessage,
    expStatus,
    allowedDays,
    localDa,
    nightDa,
    apiKmLimit,
    fldOpeningClosingKm,
    successMessage,
  ];
}
