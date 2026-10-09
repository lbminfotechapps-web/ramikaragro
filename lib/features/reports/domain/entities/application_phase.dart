class ApplicationPhase {
  final int result;

  const ApplicationPhase({
    required this.result,
  });

  bool get isVisitOnly => result == 1;
}