/// Application-wide dependency container and composition root.
///
/// Repository dependencies will be added here as their contracts are
/// introduced in Phase 2. Keeping construction in this object prevents
/// widgets from resolving dependencies through global state or BuildContext.
final class AppDependencies {
  const AppDependencies();
}
