import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass.dart';
import '../widgets/overlay_sheet.dart';
import '../widgets/pressable_scale.dart';
import 'card_storage_notice_screen.dart';

class SavedCard {
  final String id;
  String label;
  final String last4;
  final String expiry;
  final String holderName;
  final String scheme; // visa | mastercard | troy | other

  SavedCard({
    required this.id,
    required this.label,
    required this.last4,
    required this.expiry,
    required this.holderName,
    required this.scheme,
  });
}

String _detectScheme(String rawNumber) {
  if (rawNumber.startsWith('9792')) return 'troy';
  if (rawNumber.startsWith('4')) return 'visa';
  if (RegExp(r'^5[1-5]').hasMatch(rawNumber) ||
      RegExp(r'^2[2-7]').hasMatch(rawNumber)) {
    return 'mastercard';
  }
  if (rawNumber.isNotEmpty) return 'other';
  return '';
}

String _formatCardNumber(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final trimmed = digits.length > 16 ? digits.substring(0, 16) : digits;
  final groups = <String>[];
  for (var i = 0; i < trimmed.length; i += 4) {
    final end = (i + 4 > trimmed.length) ? trimmed.length : i + 4;
    groups.add(trimmed.substring(i, end));
  }
  return groups.join(' ');
}

String _formatExpiry(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final trimmed = digits.length > 4 ? digits.substring(0, 4) : digits;
  if (trimmed.length >= 3) {
    return '${trimmed.substring(0, 2)}/${trimmed.substring(2)}';
  }
  return trimmed;
}

void _setFormatted(TextEditingController ctrl, String formatted) {
  ctrl.value = TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
  );
}

/// Kayıtlı Kartlar — navbar'dan yukarı kayarak açılan tam ekran sheet.
/// Yeni kart formu (canlı önizleme + kart tipi tespiti + kart adlandırma)
/// ve kayıtlı kart listesi (adıyla birlikte, düzenle/sil).
class CardsModal extends StatefulWidget {
  final VoidCallback onClose;
  const CardsModal({super.key, required this.onClose});

  @override
  State<CardsModal> createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  final List<SavedCard> _cards = [
    SavedCard(
      id: 'c1',
      label: 'Garanti Banka Kartım',
      last4: '4242',
      expiry: '08/27',
      holderName: 'BATUHAN CANARACI',
      scheme: 'visa',
    ),
    SavedCard(
      id: 'c2',
      label: 'Akbank Kredi Kartım',
      last4: '5500',
      expiry: '03/26',
      holderName: 'BATUHAN CANARACI',
      scheme: 'mastercard',
    ),
  ];

  String? _successMessage;
  bool _cardStorageConsent = false;
  Timer? _successTimer;

  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _holderFocus = FocusNode();

  @override
  void dispose() {
    _successTimer?.cancel();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _holderCtrl.dispose();
    _labelCtrl.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _holderFocus.dispose();
    super.dispose();
  }

  String get _rawNumber => _numberCtrl.text.replaceAll(' ', '');
  String get _scheme => _detectScheme(_rawNumber);

  bool get _hasValidCardDetails =>
      _rawNumber.length >= 13 &&
      _expiryCtrl.text.length == 5 &&
      _cvvCtrl.text.length >= 3 &&
      _holderCtrl.text.trim().length >= 2;

  bool get _canSaveCard => _hasValidCardDetails && _cardStorageConsent;

  void _scheduleSuccessReset() {
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }

  void _dismissSuccessMessage() {
    _successTimer?.cancel();
    if (_successMessage != null) {
      setState(() => _successMessage = null);
    }
  }

  void _resetForm() {
    _numberCtrl.clear();
    _expiryCtrl.clear();
    _cvvCtrl.clear();
    _holderCtrl.clear();
    _labelCtrl.clear();
    _cardStorageConsent = false;
  }

  SavedCard? _createNewCard() {
    if (!_canSaveCard) return null;
    final last4 = _rawNumber.substring(_rawNumber.length - 4);
    final customLabel = _labelCtrl.text.trim();
    return SavedCard(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      label: customLabel.isEmpty ? 'Kartım •••• $last4' : customLabel,
      last4: last4,
      expiry: _expiryCtrl.text,
      holderName: _holderCtrl.text.trim().toUpperCase(),
      scheme: _scheme.isEmpty ? 'other' : _scheme,
    );
  }

  Future<void> _openNewCard() async {
    _resetForm();
    final card = await Navigator.of(context).push<SavedCard>(
      PageRouteBuilder<SavedCard>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (routeContext, animation, secondaryAnimation) {
          return StatefulBuilder(
            builder: (pageContext, pageSetState) =>
                _buildNewCardScreen(pageContext, pageSetState),
          );
        },
        transitionsBuilder: (routeContext, animation, secondary, child) {
          if (MediaQuery.disableAnimationsOf(routeContext)) return child;
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.14),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    if (!mounted) return;
    _resetForm();
    if (card == null) return;

    setState(() {
      _cards.add(card);
      _successMessage = 'Kart başarıyla kaydedildi.';
    });
    _scheduleSuccessReset();
  }

  Future<void> _openEdit(SavedCard card) async {
    final result = await Navigator.of(context).push<_CardEditResult>(
      MaterialPageRoute(builder: (_) => _SavedCardEditScreen(card: card)),
    );
    if (!mounted || result == null) return;

    setState(() {
      if (result.deleted) {
        _cards.remove(card);
        _successMessage = 'Kart başarıyla silindi.';
      } else {
        card.label = result.label!;
        _successMessage = 'Kart başarıyla güncellendi.';
      }
    });
    _scheduleSuccessReset();
  }

  Future<void> _openCardStorageNotice() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CardStorageNoticeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySheet(
      title: 'Kayıtlı Kartlar',
      onClose: widget.onClose,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          if (_successMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.brand100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.brand600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: figtree(
                        size: 13,
                        weight: W.bold,
                        color: AppColors.brand700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _dismissSuccessMessage,
                    tooltip: 'Bildirimi kapat',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    icon: AppIcons.x(
                      size: 17,
                      color: AppColors.brand700,
                      strokeWidth: 2.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          Semantics(
            button: true,
            label: 'Yeni kart ekleme ekranını aç',
            child: PressableScale(
              onTap: _openNewCard,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: AppColors.brand700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Yeni Kart Ekle',
                      style: figtree(
                        size: 14,
                        weight: W.bold,
                        color: AppColors.brand700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 14),

          for (final card in _cards) ...[
            _CardRow(card: card, onTap: () => _openEdit(card)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildNewCardScreen(
    BuildContext pageContext,
    StateSetter pageSetState,
  ) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Kayıtlı kartlara geri dön',
                    child: Tooltip(
                      message: 'Geri',
                      child: PressableScale(
                        scale: 0.9,
                        onTap: () => Navigator.of(pageContext).pop(),
                        child: SizedBox(
                          height: 48,
                          width: 48,
                          child: Center(
                            child: AppIcons.arrowLeft(
                              size: 25,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Yeni Kart Ekle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtree(
                        size: 18,
                        weight: W.extrabold,
                        tracking: Tracking.tight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  Text(
                    'Kart bilgilerinizi güvenli şekilde ekleyin',
                    style: figtree(size: 16, weight: W.extrabold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kartınızı sonraki bakiye yüklemelerinde kullanabilmek için aşağıdaki alanları doldurun.',
                    style: figtree(
                      size: 12.5,
                      weight: W.medium,
                      color: AppColors.inkSoft,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildForm(pageContext, pageSetState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext pageContext, StateSetter pageSetState) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Canlı kart önizlemesi
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.brand600, AppColors.brand800],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand800.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 38,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        _SchemeBadge(scheme: _scheme),
                      ],
                    ),
                    Text(
                      _numberCtrl.text.isEmpty
                          ? '•••• •••• •••• ••••'
                          : _numberCtrl.text,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KART SAHİBİ',
                                style: figtree(
                                  size: 8.5,
                                  weight: W.semibold,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  tracking: Tracking.widest,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _holderCtrl.text.isEmpty
                                    ? 'AD SOYAD'
                                    : _holderCtrl.text.toUpperCase(),
                                style: figtree(
                                  size: 11,
                                  weight: W.bold,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  tracking: Tracking.wide,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'SON KUL.',
                              style: figtree(
                                size: 8.5,
                                weight: W.semibold,
                                color: Colors.white.withValues(alpha: 0.55),
                                tracking: Tracking.widest,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _expiryCtrl.text.isEmpty
                                  ? 'AA/YY'
                                  : _expiryCtrl.text,
                              style: figtree(
                                size: 11,
                                weight: W.bold,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _FieldLabel('Kart Numarası'),
          TextField(
            controller: _numberCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: _fieldDecoration('0000 0000 0000 0000'),
            onChanged: (v) {
              final formatted = _formatCardNumber(v);
              _setFormatted(_numberCtrl, formatted);
              if (formatted.replaceAll(' ', '').length == 16) {
                FocusScope.of(pageContext).requestFocus(_expiryFocus);
              }
              pageSetState(() {});
            },
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Son Kullanma'),
                    TextField(
                      controller: _expiryCtrl,
                      focusNode: _expiryFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: _fieldDecoration('AA/YY'),
                      onChanged: (v) {
                        final formatted = _formatExpiry(v);
                        _setFormatted(_expiryCtrl, formatted);
                        if (formatted.length == 5) {
                          FocusScope.of(pageContext).requestFocus(_cvvFocus);
                        }
                        pageSetState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('CVV / CVC'),
                    TextField(
                      controller: _cvvCtrl,
                      focusNode: _cvvFocus,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: _fieldDecoration('•••'),
                      onChanged: (v) {
                        if (v.length >= 3) {
                          FocusScope.of(pageContext).requestFocus(_holderFocus);
                        }
                        pageSetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _FieldLabel('Kart Sahibi Adı'),
          TextField(
            controller: _holderCtrl,
            focusNode: _holderFocus,
            textCapitalization: TextCapitalization.characters,
            decoration: _fieldDecoration('AD SOYAD'),
            onChanged: (_) => pageSetState(() {}),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _FieldLabel('Kart Adı'),
              const SizedBox(width: 4),
              Text(
                '(isteğe bağlı)',
                style: figtree(
                  size: 10.5,
                  weight: W.medium,
                  color: AppColors.inkFaint,
                ),
              ),
            ],
          ),
          TextField(
            controller: _labelCtrl,
            decoration: _fieldDecoration('ör. Yapı Kredi Banka Kartım'),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brand200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                  color: AppColors.brand700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'CVV/CVC kodunuz kaydedilmez. Kart saklama işlemi, ödeme kuruluşunun oluşturduğu güvenli kart belirteci (token) üzerinden yürütülür.',
                    style: figtree(
                      size: 11.5,
                      weight: W.semibold,
                      color: AppColors.brand800,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Semantics(
            container: true,
            checked: _cardStorageConsent,
            label:
                'Kart bilgilerimin sonraki bakiye yüklemelerinde kullanılmak üzere saklanmasına açık rıza veriyorum.',
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => pageSetState(
                () => _cardStorageConsent = !_cardStorageConsent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _cardStorageConsent,
                      onChanged: (value) => pageSetState(
                        () => _cardStorageConsent = value ?? false,
                      ),
                      activeColor: AppColors.brand600,
                      side: const BorderSide(
                        color: AppColors.inkFaint,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kart bilgilerimin sonraki bakiye yüklemelerinde kullanılmak üzere saklanmasına açık rıza veriyorum.',
                            style: figtree(
                              size: 11.8,
                              weight: W.semibold,
                              color: AppColors.ink,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Verilerinizin işlenmesine ilişkin ayrıntılar için ',
                                style: figtree(
                                  size: 11.3,
                                  weight: W.medium,
                                  color: AppColors.inkSoft,
                                  height: 1.4,
                                ),
                              ),
                              InkWell(
                                onTap: _openCardStorageNotice,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    'Kart Saklama Aydınlatma Metni’ni inceleyin.',
                                    style:
                                        figtree(
                                          size: 11.3,
                                          weight: W.bold,
                                          color: AppColors.brand700,
                                          height: 1.4,
                                        ).copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.brand700,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: PressableScale(
              disabled: !_canSaveCard,
              onTap: () {
                final card = _createNewCard();
                if (card != null) Navigator.of(pageContext).pop(card);
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _canSaveCard ? AppColors.nearBlack : AppColors.mist200,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _canSaveCard
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 18,
                            spreadRadius: -8,
                            offset: const Offset(0, 9),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: _canSaveCard ? Colors.white : AppColors.mist600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kartı Kaydet',
                      style: figtree(
                        size: 14,
                        weight: W.bold,
                        color: _canSaveCard ? Colors.white : AppColors.mist600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardEditResult {
  final String? label;
  final bool deleted;

  const _CardEditResult.updated(this.label) : deleted = false;
  const _CardEditResult.deleted() : label = null, deleted = true;
}

class _SavedCardEditScreen extends StatefulWidget {
  final SavedCard card;

  const _SavedCardEditScreen({required this.card});

  @override
  State<_SavedCardEditScreen> createState() => _SavedCardEditScreenState();
}

class _SavedCardEditScreenState extends State<_SavedCardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.card.label);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _updateCard() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop(_CardEditResult.updated(_labelController.text.trim()));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kartı silmek istiyor musunuz?',
          style: figtree(size: 18, weight: W.extrabold),
        ),
        content: Text(
          '${widget.card.label} kayıtlı kartlarınızdan kaldırılacak. Bu işlem geri alınamaz.',
          style: figtree(size: 14, weight: W.medium, color: AppColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Vazgeç',
              style: figtree(
                size: 14,
                weight: W.bold,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Kartı Sil',
              style: figtree(
                size: 14,
                weight: W.extrabold,
                color: AppColors.red600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const _CardEditResult.deleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Kayıtlı kartlara geri dön',
                    child: Tooltip(
                      message: 'Geri',
                      child: PressableScale(
                        scale: 0.9,
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          height: 48,
                          width: 48,
                          child: Center(
                            child: AppIcons.arrowLeft(
                              size: 25,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Kart Adını Düzenle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtree(
                        size: 18,
                        weight: W.extrabold,
                        tracking: Tracking.tight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  GlassPanel(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Kart Adı'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelController,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _updateCard(),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              final label = value?.trim() ?? '';
                              if (label.isEmpty) {
                                return 'Kart adı boş bırakılamaz.';
                              }
                              if (label.length < 2) {
                                return 'En az 2 karakter giriniz.';
                              }
                              return null;
                            },
                            style: figtree(size: 16, weight: W.bold),
                            decoration: _fieldDecoration(
                              'ör. Garanti Banka Kartım',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(height: 1, color: AppColors.surfaceBorder),
                          const SizedBox(height: 20),
                          const _FieldLabel('Kart Bilgileri'),
                          const SizedBox(height: 8),
                          Semantics(
                            readOnly: true,
                            label:
                                'Kart bilgileri. Son dört hanesi ${widget.card.last4}, son kullanma tarihi ${widget.card.expiry}. Salt okunur.',
                            excludeSemantics: true,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.slate100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: AppIcons.creditCard(
                                        size: 21,
                                        color: AppColors.inkSoft,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '•••• •••• •••• ${widget.card.last4}  ·  ${widget.card.expiry}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: figtree(
                                        size: 13,
                                        weight: W.semibold,
                                        color: AppColors.inkSoft,
                                        tracking: Tracking.wide,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AppIcons.lock(
                                    size: 18,
                                    color: AppColors.inkFaint,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'Kart bilgilerini değiştirmek için bu kartı silip yeniden eklemeniz gerekir.',
                            style: figtree(
                              size: 11.5,
                              weight: W.medium,
                              color: AppColors.inkFaint,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kayıtlı kartınız burada güvende',
                          style: figtree(size: 16, weight: W.extrabold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kart bilgileriniz maskelenerek gösterilir ve bu ekrandan değiştirilemez.',
                          style: figtree(
                            size: 13,
                            weight: W.medium,
                            color: AppColors.inkSoft,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    button: true,
                    label: 'Kart adını güncelle',
                    child: PressableScale(
                      scale: 0.98,
                      onTap: _updateCard,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.nearBlack,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 18,
                              spreadRadius: -8,
                              offset: const Offset(0, 9),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Kart Adını Güncelle',
                            style: figtree(
                              size: 15,
                              weight: W.extrabold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Kayıtlı kartı sil',
                    child: PressableScale(
                      scale: 0.98,
                      onTap: _confirmDelete,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.ink.withValues(alpha: 0.70),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Kartı Sil',
                            style: figtree(
                              size: 15,
                              weight: W.extrabold,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: figtree(size: 13, weight: W.medium, color: AppColors.inkFaint),
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.brand400, width: 1.6),
  ),
);

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: figtree(
        size: 10.5,
        weight: W.bold,
        color: AppColors.inkSoft,
        tracking: Tracking.widest,
      ),
    ),
  );
}

class _SchemeBadge extends StatelessWidget {
  final String scheme;
  const _SchemeBadge({required this.scheme});

  @override
  Widget build(BuildContext context) {
    switch (scheme) {
      case 'visa':
        return Text(
          'VISA',
          style: figtree(size: 15, weight: W.extrabold, color: Colors.white),
        );
      case 'mastercard':
        return SizedBox(
          height: 22,
          width: 34,
          child: Stack(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEB001B),
                ),
              ),
              Positioned(
                left: 12,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'troy':
        return Text(
          'TROY',
          style: figtree(size: 13, weight: W.extrabold, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SchemeChip extends StatelessWidget {
  final String scheme;
  const _SchemeChip({required this.scheme});

  @override
  Widget build(BuildContext context) {
    switch (scheme) {
      case 'visa':
        return Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'VISA',
              style: figtree(size: 9, weight: W.extrabold, color: Colors.white),
            ),
          ),
        );
      case 'mastercard':
        return SizedBox(
          width: 40,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 4,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEB001B).withValues(alpha: 0.9),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'troy':
        return Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF003082),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'TROY',
              style: figtree(
                size: 8.5,
                weight: W.extrabold,
                color: Colors.white,
              ),
            ),
          ),
        );
      default:
        return Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.slate200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'KART',
              style: figtree(size: 8, weight: W.bold, color: AppColors.inkSoft),
            ),
          ),
        );
    }
  }
}

class _CardRow extends StatelessWidget {
  final SavedCard card;
  final VoidCallback onTap;
  const _CardRow({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5ECEB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: -4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _SchemeChip(scheme: card.scheme),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.label.isNotEmpty ? card.label : 'Kart',
                    style: figtree(
                      size: 13.5,
                      weight: W.extrabold,
                      color: AppColors.ink,
                      tracking: Tracking.tight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '•••• ${card.last4}',
                        style: figtree(
                          size: 11.5,
                          weight: W.semibold,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7),
                        child: Text(
                          '·',
                          style: TextStyle(color: AppColors.inkFaint),
                        ),
                      ),
                      Text(
                        card.expiry,
                        style: figtree(
                          size: 11,
                          weight: W.semibold,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
