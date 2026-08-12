import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/home/presentation/screens/home_screen.dart';
import 'package:parosis_sulama/features/irrigation/presentation/screens/past_irrigations_screen.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/profile_screen.dart';
import 'package:parosis_sulama/features/wallet/presentation/screens/balance_screens.dart';
import 'package:parosis_sulama/features/well_requests/presentation/screens/requests_screen.dart';
import 'package:parosis_sulama/features/wells/presentation/screens/well_screens.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/widgets/app_header.dart';
import 'package:parosis_sulama/widgets/bottom_nav.dart';
import 'package:parosis_sulama/widgets/screen_in.dart';

import 'app_dependencies.dart';
import 'navigation/app_destination.dart';

/// Web prototipindeki tek ekran state machine'inin Flutter karşılığı.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.dependencies, required this.onLogout});

  final AppDependencies dependencies;
  final VoidCallback onLogout;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppDestination _screen = AppDestination.home;
  int? _lastTopUp;
  String? _selectedWellId;
  AppDestination _wellEditBackTarget = AppDestination.home;
  String? _selectedHistoryWellId;
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

  void _openPastIrrigationDetail(String wellId) {
    setState(() => _selectedHistoryWellId = wellId);
    _go(AppDestination.pastIrrigationDetail);
  }

  Future<bool> _confirmTopUp(int amount) async {
    final success = await widget.dependencies.walletController.topUp(amount);
    if (success) {
      setState(() {
        _lastTopUp = amount;
        _screen = AppDestination.balance;
      });
    }
    return success;
  }

  bool get _hasOverlay => _menuOpen;
  bool get _isSubScreen => !_screen.isPrimary;
  AppDestination get _backTarget => switch (_screen) {
    AppDestination.program ||
    AppDestination.instant ||
    AppDestination.requests ||
    AppDestination.pastIrrigations => AppDestination.home,
    AppDestination.wellEdit => _wellEditBackTarget,
    AppDestination.pastIrrigationDetail => AppDestination.pastIrrigations,
    AppDestination.topUp => AppDestination.balance,
    AppDestination.home ||
    AppDestination.balance ||
    AppDestination.profile => _screen,
  };

  void _handleBack() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    } else if (_isSubScreen) {
      _go(_backTarget);
    }
  }

  Widget _buildScreen() {
    final deps = widget.dependencies;
    return switch (_screen) {
      AppDestination.home => HomeScreen(
        wellsController: deps.wellsController,
        irrigationController: deps.irrigationController,
        onProgramTap: () => _go(AppDestination.program),
        onInstantTap: () => _go(AppDestination.instant),
      ),
      AppDestination.program => ProgramScreen(
        wellsController: deps.wellsController,
        onWellEdit: (well) => _openWellEdit(well.id),
      ),
      AppDestination.instant => InstantScreen(
        wellsController: deps.wellsController,
        irrigationController: deps.irrigationController,
        onNavigateHome: () => _go(AppDestination.home),
      ),
      AppDestination.balance => BalanceScreen(
        walletController: deps.walletController,
        lastTopUp: _lastTopUp,
        onTopUp: () => _go(AppDestination.topUp),
      ),
      AppDestination.topUp => TopUpScreen(onConfirm: _confirmTopUp),
      AppDestination.profile => ProfileScreen(
        profileController: deps.profileController,
        paymentCardsController: deps.paymentCardsController,
      ),
      AppDestination.wellEdit => WellEditScreen(
        wellsController: deps.wellsController,
        wellBookingsController: deps.wellBookingsController,
        wellId: _selectedWellId,
        onSubmitted: () => _go(_wellEditBackTarget),
      ),
      AppDestination.requests => RequestsScreen(
        wellRequestsController: deps.wellRequestsController,
        wellBookingsController: deps.wellBookingsController,
      ),
      AppDestination.pastIrrigations => PastIrrigationsScreen(
        wellsController: deps.wellsController,
        irrigationController: deps.irrigationController,
        onSelectWell: (well) => _openPastIrrigationDetail(well.id),
      ),
      AppDestination.pastIrrigationDetail => PastIrrigationDetailScreen(
        wellsController: deps.wellsController,
        irrigationController: deps.irrigationController,
        wellId: _selectedHistoryWellId,
      ),
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      // Alt kenar burada korunmuyor — BottomNav'ın arkaplanı ekranın en
      // altına kadar kesintisiz uzansın diye (TikTok tarzı, ev tuşu
      // çizgisinin altında boşluk/renk uyuşmazlığı kalmasın). BottomNav
      // kendi içeriğini (dokunma alanı) kendi SafeArea'sıyla koruyor —
      // bkz. bottom_nav.dart. Ekran listelerinin zaten 104px alt boşluğu
      // olduğu için içerik bu değişiklikten etkilenmiyor.
      bottom: false,
      child: PopScope(
        canPop: !_hasOverlay && !_isSubScreen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: Stack(
          children: [
            Column(
              children: [
                ListenableBuilder(
                  listenable: widget.dependencies.walletController,
                  builder: (context, _) => AppHeader(
                    balance: widget.dependencies.walletController.balance,
                    onBalanceTap: () => _go(AppDestination.balance),
                    onMenuTap: () => setState(() => _menuOpen = true),
                    onBackTap: _handleBack,
                    showBackButton: _isSubScreen,
                  ),
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
              left: 0,
              right: 0,
              bottom: 0,
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
                        onOpenRequests: () {
                          setState(() => _menuOpen = false);
                          _go(AppDestination.requests);
                        },
                        onOpenHistory: () {
                          setState(() => _menuOpen = false);
                          _go(AppDestination.pastIrrigations);
                        },
                        onLogout: () {
                          setState(() => _menuOpen = false);
                          widget.onLogout();
                        },
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('quick-access-drawer-closed'),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
