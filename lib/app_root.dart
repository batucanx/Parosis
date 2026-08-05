import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/screen_in.dart';
import 'screens/home_screen.dart';
import 'screens/well_screens.dart';
import 'screens/balance_screens.dart';
import 'screens/profile_screen.dart';
import 'screens/cards_modal.dart';
import 'theme/colors.dart';

/// Web prototipindeki tek ekran state machine'inin Flutter karşılığı.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String _screen = 'home';
  int _balance = 450;
  int? _lastTopUp;
  bool _showCardsModal = false;
  Well? _selectedWell;
  String _wellEditBackTarget = 'home';
  String? _openSheet;
  bool _menuOpen = false;

  static const _tabOfScreen = <String, String>{
    'home': 'home',
    'program': 'home',
    'instant': 'home',
    'balance': 'balance',
    'topup': 'balance',
    'profile': 'profile',
  };

  void _go(String next) => setState(() {
    _lastTopUp = null;
    _screen = next;
  });
  void _openWellEdit(Well well) {
    setState(() {
      _selectedWell = well;
      _wellEditBackTarget = _screen;
    });
    _go('welledit');
  }

  void _confirmTopUp(int amount) => setState(() {
    _balance += amount;
    _lastTopUp = amount;
    _screen = 'balance';
  });
  void _openCards() => setState(() => _showCardsModal = true);

  bool get _hasOverlay => _menuOpen || _showCardsModal || _openSheet != null;
  bool get _isSubScreen =>
      !const ['home', 'balance', 'profile'].contains(_screen);
  String get _backTarget => switch (_screen) {
    'program' || 'instant' => 'home',
    'welledit' => _wellEditBackTarget,
    'topup' => 'balance',
    _ => _screen,
  };

  void _handleBack() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    } else if (_showCardsModal) {
      setState(() => _showCardsModal = false);
    } else if (_openSheet != null) {
      setState(() => _openSheet = null);
    } else if (_isSubScreen) {
      _go(_backTarget);
    }
  }

  Widget _buildScreen() => switch (_screen) {
    'home' => HomeScreen(onNavigate: _go),
    'program' => ProgramScreen(onWellEdit: _openWellEdit),
    'instant' => InstantScreen(onWellEdit: _openWellEdit, onNavigate: _go),
    'balance' => BalanceScreen(
      balance: _balance,
      lastTopUp: _lastTopUp,
      onTopUp: () => _go('topup'),
    ),
    'topup' => TopUpScreen(onConfirm: _confirmTopUp),
    'profile' => ProfileScreen(
      onOpenCards: _openCards,
      onOpenSheet: (type) => setState(() => _openSheet = type),
    ),
    'welledit' => WellEditScreen(well: _selectedWell),
    _ => const SizedBox.shrink(),
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
                  onBalanceTap: () => _go('balance'),
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
                activeTab: _tabOfScreen[_screen] ?? 'home',
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
            if (_openSheet != null)
              ProfileInfoSheet(
                type: _openSheet!,
                onClose: () => setState(() => _openSheet = null),
              ),
          ],
        ),
      ),
    ),
  );
}
