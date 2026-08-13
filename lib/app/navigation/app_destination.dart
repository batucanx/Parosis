enum AppDestination {
  home,
  program,
  instant,
  balance,
  topUp,
  profile,
  wellEdit,
  wellRequests,
  bookingRequests,
  pastIrrigations,
  pastIrrigationDetail,
  addressInfo;

  AppDestination get primaryDestination => switch (this) {
    AppDestination.home ||
    AppDestination.program ||
    AppDestination.instant ||
    AppDestination.wellEdit ||
    AppDestination.wellRequests ||
    AppDestination.bookingRequests ||
    AppDestination.pastIrrigations ||
    AppDestination.pastIrrigationDetail => AppDestination.home,
    AppDestination.balance || AppDestination.topUp => AppDestination.balance,
    AppDestination.profile ||
    AppDestination.addressInfo => AppDestination.profile,
  };

  bool get isPrimary => switch (this) {
    AppDestination.home ||
    AppDestination.balance ||
    AppDestination.profile => true,
    AppDestination.program ||
    AppDestination.instant ||
    AppDestination.topUp ||
    AppDestination.wellEdit ||
    AppDestination.wellRequests ||
    AppDestination.bookingRequests ||
    AppDestination.pastIrrigations ||
    AppDestination.pastIrrigationDetail ||
    AppDestination.addressInfo => false,
  };
}
