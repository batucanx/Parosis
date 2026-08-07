import 'package:flutter/material.dart';

import '../screens/balance_screens.dart';
import '../screens/cards_modal.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/well_screens.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/screen_in.dart';
import 'app_dependencies.dart';
import 'navigation/app_destination.dart';

/// Web prototipindeki tek ekran state machine'inin Flutter karşılığı.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppDestination _screen = AppDestination.home;
  int _balance = 450;
  int? _lastTopUp;
  bool _showCardsModal = false;
  String? _selectedWellId;
  AppDestination _wellEditBackTarget = AppDestination.home;
  ProfileInfoSection? _openProfileInfoSection;
  bool _menuOpen = false;

  void _go(AppDestination next) => setState(() {
    _lastTopUp = null;
    _screen = next;
  });

  void _openWellEdit(String wellId) {
    setState(() {
      _selectedWellId = wellId;
      _wellEditBackTarget = _screen;
    });
    _go(AppDestination.wellEdit);
  }

  void _confirmTopUp(int amount) => setState(() {
    _balance += amount;
    _lastTopUp = amount;
    _screen = AppDestination.balance;
  });

  void _openCards() => setState(() => _showCardsModal = true);

  bool get _hasOverlay =>
      _menuOpen || _showCardsModal || _openProfileInfoSection != null;
  bool get _isSubScreen => !_screen.isPrimary;
  AppDestination get _backTarget => switch (_screen) {
    AppDestination.program || AppDestination.instant => AppDestination.home,
    AppDestination.wellEdit => _wellEditBackTarget,
    AppDestination.topUp => AppDestination.balance,
    AppDestination.home ||
    AppDestination.balance ||
    AppDestination.profile => _screen,
  };

  void _handleBack() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    } else if (_showCardsModal) {
      setState(() => _showCardsModal = false);
    } else if (_openProfileInfoSection != null) {
      setState(() => _openProfileInfoSection = null);
    } else if (_isSubScreen) {
      _go(_backTarget);
    }
  }

  Widget _buildScreen() => switch (_screen) {
    AppDestination.home => HomeScreen(
      onProgramTap: () => _go(AppDestination.program),
      onInstantTap: () => _go(AppDestination.instant),
    ),
    AppDestination.program => ProgramScreen(
      onWellEdit: (well) => _openWellEdit(well.id),
    ),
    AppDestination.instant => InstantScreen(
      onWellEdit: (well) => _openWellEdit(well.id),
      onIrrigationStopped: () => _go(AppDestination.home),
    ),
    AppDestination.balance => BalanceScreen(
      balance: _balance,
      lastTopUp: _lastTopUp,
      onTopUp: () => _go(AppDestination.topUp),
    ),
    AppDestination.topUp => TopUpScreen(onConfirm: _confirmTopUp),
    AppDestination.profile => ProfileScreen(
      onOpenCards: _openCards,
      onOpenSheet: (section) =>
          setState(() => _openProfileInfoSection = section),
    ),
    AppDestination.wellEdit => WellEditScreen(wellId: _selectedWellId),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: PopScope(
        canPop: !_hasOverlay && !_isSubScreen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  balance: _balance,
                  onBalanceTap: () => _go(AppDestination.balance),
                  onMenuTap: () => setState(() => _menuOpen = true),
                  onBackTap: _handleBack,
                  showBackButton: _isSubScreen,
                ),
                Expanded(
                  child: ScreenIn(
                    key: ValueKey(_screen),
                    child: _buildScreen(),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: BottomNav(
                activeDestination: _screen.primaryDestination,
                onChange: _go,
              ),
            ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                reverseDuration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  if (child.key != const ValueKey('quick-access-drawer')) {
                    return child;
                  }

                  final slide = Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  final fade = Tween<double>(
                    begin: 0.72,
                    end: 1,
                  ).animate(animation);

                  return SlideTransition(
                    position: slide,
                    child: FadeTransition(opacity: fade, child: child),
                  );
                },
                child: _menuOpen
                    ? AppDrawerOverlay(
                        key: const ValueKey('quick-access-drawer'),
                        onClose: () => setState(() => _menuOpen = false),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('quick-access-drawer-closed'),
                      ),
              ),
            ),
            if (_showCardsModal)
              CardsModal(
                onClose: () => setState(() => _showCardsModal = false),
              ),
            if (_openProfileInfoSection case final section?)
              ProfileInfoSheet(
                section: section,
                onClose: () => setState(() => _openProfileInfoSection = null),
              ),
          ],
        ),
      ),
    ),
  );
}
