/// Every screen that can be selected by the application shell.
enum AppDestination {
  home,
  program,
  instant,
  balance,
  topUp,
  profile,
  wellEdit;

  /// The primary navigation destination represented by this screen.
  AppDestination get primaryDestination => switch (this) {
    AppDestination.home ||
    AppDestination.program ||
    AppDestination.instant ||
    AppDestination.wellEdit => AppDestination.home,
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
    AppDestination.wellEdit => false,
  };
}
