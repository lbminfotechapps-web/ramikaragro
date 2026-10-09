import '../entities/application_phase.dart';
import '../repositories/monthly_performance_repository.dart';

class GetApplicationPhaseUseCase {
  final MonthlyPerformanceRepository repository;

  GetApplicationPhaseUseCase(
    this.repository,
  );

  Future<ApplicationPhase> call() {
    return repository.getApplicationPhase();
  }
}