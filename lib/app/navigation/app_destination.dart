/// Every screen that can be selected by the application shell.
enum AppDestination {
  home,
  program,
  instant,
  balance,
  topUp,
  profile,
  wellEdit,
  requests,
  pastIrrigations,
  pastIrrigationDetail;

  /// The primary navigation destination represented by this screen.
  AppDestination get primaryDestination => switch (this) {
    AppDestination.home ||
    AppDestination.program ||
    AppDestination.instant ||
    AppDestination.wellEdit ||
    AppDestination.requests ||
    AppDestination.pastIrrigations ||
    AppDestination.pastIrrigationDetail => AppDestination.home,
    AppDestination.balance || AppDestination.topUp => AppDestination.balance,
    AppDestination.profile => AppDestination.profile,
  };

  bool get isPrimary => switch (this) {
    AppDestination.home ||
    AppDestination.balance ||
    AppDestination.profile => true,
    AppDestination.program ||
    AppDestination.instant ||
    AppDestination.topUp ||
    AppDestination.wellEdit ||
    AppDestination.requests ||
    AppDestination.pastIrrigations ||
    AppDestination.pastIrrigationDetail => false,
  };
}
