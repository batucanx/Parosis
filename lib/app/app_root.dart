import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/home/presentation/screens/home_screen.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/screens/cards_modal.dart';
import 'package:parosis_sulama/features/profile/presentation/screens/profile_screen.dart';
import 'package:parosis_sulama/features/wallet/presentation/screens/balance_screens.dart';
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
  bool _showCardsModal = false;
  String? _selectedWellId;
  AppDestination _wellEditBackTarget = AppDestination.home;
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

  void _openCards() => setState(() => _showCardsModal = true);

  bool get _hasOverlay => _menuOpen || _showCardsModal;
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
        onWellEdit: (well) => _openWellEdit(well.id),
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
        onOpenCards: _openCards,
      ),
      AppDestination.wellEdit => WellEditScreen(
        wellsController: deps.wellsController,
        wellId: _selectedWellId,
      ),
    };
  }

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
            if (_showCardsModal)
              CardsModal(
                controller: widget.dependencies.paymentCardsController,
                onClose: () => setState(() => _showCardsModal = false),
              ),
          ],
        ),
      ),
    ),
  );
}
