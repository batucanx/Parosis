import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:parosis_sulama/features/payment_cards/domain/entities/saved_card.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/slide_up_page_route.dart';
import 'card_storage_notice_screen.dart';

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

/// Kart ağlarında geçerlilik süresi genelde birkaç yılı geçmez; bu sınır,
/// yanlış yazılmış (ör. "12/55") yılları erkenden yakalamak için makul bir
/// varsayılandır. Gerçek kart/BIN doğrulaması sağlayıcı API'sine
/// bağlandığında bu istemci tarafı kontrolün yerini sunucu doğrulaması alır;
/// o zamana kadar aynı UX'i (kart ağı + issuer'dan bağımsız, anında geri
/// bildirim) korur.
const int maxCardValidityYears = 20;

/// Hem yeni kart ekleme hem de kayıtlı kart güncelleme ekranında kullanılan
/// tek doğrulama noktası — ileride API'ye bağlanınca değiştirilecek yer de
/// burası olur.
String? validateCardExpiry(String? value) {
  final v = value?.trim() ?? '';
  final parts = v.split('/');
  if (v.length != 5 || parts.length != 2) {
    return 'Son kullanma tarihi gerekli.';
  }
  final month = int.tryParse(parts[0]);
  final year = int.tryParse(parts[1]);
  if (month == null || year == null || month < 1 || month > 12) {
    return 'Geçersiz tarih.';
  }
  final fullYear = 2000 + year;
  final now = DateTime.now();
  if (fullYear < now.year || (fullYear == now.year && month < now.month)) {
    return 'Kartın süresi dolmuş.';
  }
  if (fullYear > now.year + maxCardValidityYears) {
    return 'Yıl çok ileride.';
  }
  return null;
}

class CardsModal extends StatefulWidget {
  final PaymentCardsController controller;
  const CardsModal({super.key, required this.controller});

  @override
  State<CardsModal> createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  String? _successMessage;
  bool _cardStorageConsent = false;
  bool _makePrimaryOnCreate = false;
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
      validateCardExpiry(_expiryCtrl.text) == null &&
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
    _makePrimaryOnCreate = false;
  }

  Future<SavedCard?> _saveNewCard() async {
    if (!_canSaveCard) return null;
    final last4 = _rawNumber.substring(_rawNumber.length - 4);
    final customLabel = _labelCtrl.text.trim();
    final schemeName = _scheme.isEmpty ? 'other' : _scheme;
    return widget.controller.addCard(
      label: customLabel.isEmpty ? 'Kartım •••• $last4' : customLabel,
      last4: last4,
      expiry: _expiryCtrl.text,
      holderName: _holderCtrl.text.trim().toUpperCase(),
      scheme: CardScheme.values.byName(schemeName),
      makePrimary: _makePrimaryOnCreate,
    );
  }

  Future<void> _openNewCard() async {
    _resetForm();
    final card = await Navigator.of(context).push<SavedCard>(
      SlideUpPageRoute<SavedCard>(
        builder: (_) => StatefulBuilder(
          builder: (pageContext, pageSetState) =>
              _buildNewCardScreen(pageContext, pageSetState),
        ),
      ),
    );
    if (!mounted) return;
    _resetForm();
    if (card == null) return;

    setState(() => _successMessage = 'Kart başarıyla kaydedildi.');
    _scheduleSuccessReset();
  }

  Future<void> _openEdit(SavedCard card) async {
    final result = await Navigator.of(context).push<_CardEditResult>(
      SlideUpPageRoute(
        builder: (_) =>
            _SavedCardEditScreen(card: card, controller: widget.controller),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _successMessage = result.deleted
          ? 'Kart başarıyla silindi.'
          : 'Kart başarıyla güncellendi.';
    });
    _scheduleSuccessReset();
  }

  Future<void> _openCardStorageNotice() async {
    await Navigator.of(context).push<void>(
      SlideUpPageRoute(builder: (_) => const CardStorageNoticeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => Scaffold(
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
                      label: 'Kayıtlı Kartlar ekranını kapat',
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
                        'Kayıtlı Kartlar',
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    if (_successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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

                    if (widget.controller.isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Kartlar yükleniyor…',
                            style: figtree(
                              size: 13,
                              weight: W.semibold,
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ),
                      )
                    else if (widget.controller.displayCards.isEmpty)
                      const _EmptyCardsState()
                    else
                      for (final card in widget.controller.displayCards) ...[
                        _CardRow(card: card, onTap: () => _openEdit(card)),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
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

          _ResponsiveFieldPair(
            first: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('Son Kullanma'),
                TextFormField(
                  controller: _expiryCtrl,
                  focusNode: _expiryFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateCardExpiry,
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
            second: Column(
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
          const SizedBox(height: 10),

          _FieldLabel('Kart Sahibi Adı'),
          TextField(
            controller: _holderCtrl,
            focusNode: _holderFocus,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ\s]'),
              ),
            ],
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

          if (widget.controller.cards.isEmpty)
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
                  Icon(Icons.star_rounded, size: 18, color: AppColors.brand700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'İlk kartınız otomatik olarak birincil kart olacak.',
                      style: figtree(
                        size: 11.8,
                        weight: W.semibold,
                        color: AppColors.brand800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Semantics(
              container: true,
              checked: _makePrimaryOnCreate,
              label: 'Bu kartı birincil kart olarak ayarla',
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => pageSetState(
                  () => _makePrimaryOnCreate = !_makePrimaryOnCreate,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _makePrimaryOnCreate,
                        onChanged: (value) => pageSetState(
                          () => _makePrimaryOnCreate = value ?? false,
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
                        child: Text(
                          'Bu kartı birincil kart yap.',
                          style: figtree(
                            size: 11.8,
                            weight: W.semibold,
                            color: AppColors.ink,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              onTap: () async {
                final card = await _saveNewCard();
                if (card != null && pageContext.mounted) {
                  Navigator.of(pageContext).pop(card);
                }
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
  final bool deleted;
  const _CardEditResult.updated() : deleted = false;
  const _CardEditResult.deleted() : deleted = true;
}

class _SavedCardEditScreen extends StatefulWidget {
  final SavedCard card;
  final PaymentCardsController controller;

  const _SavedCardEditScreen({required this.card, required this.controller});

  @override
  State<_SavedCardEditScreen> createState() => _SavedCardEditScreenState();
}

class _SavedCardEditScreenState extends State<_SavedCardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _expiryController;
  final _cvvController = TextEditingController();
  final _cvvFocus = FocusNode();
  bool _setPrimary = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.card.label);
    _expiryController = TextEditingController(text: widget.card.expiry);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  String? _validateCvv(String? value) {
    final v = value?.trim() ?? '';
    final expiryChanged =
        _expiryController.text.trim() != widget.card.expiry.trim();
    if (v.isEmpty && !expiryChanged) return null;
    if (v.length < 3) return 'Güvenlik kodu gerekli.';
    return null;
  }

  Future<void> _showCvvHelp() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Güvenlik kodu nedir?',
          style: figtree(size: 17, weight: W.extrabold),
        ),
        content: Text(
          'Kartınızın arkasındaki imza panelinde bulunan 3 haneli koddur (Visa, Mastercard) ya da Troy kartlarda kartın ön veya arka yüzünde yer alır.',
          style: figtree(
            size: 14,
            weight: W.medium,
            color: AppColors.inkSoft,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Anladım',
              style: figtree(
                size: 14,
                weight: W.bold,
                color: AppColors.brand700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCard() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = await widget.controller.updateCard(
      id: widget.card.id,
      label: _labelController.text.trim(),
      expiry: _expiryController.text.trim(),
      makePrimary: _setPrimary,
    );
    if (!mounted || updated == null) return;
    Navigator.of(context).pop(const _CardEditResult.updated());
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

    if (confirmed != true || !mounted) return;
    await widget.controller.deleteCard(widget.card.id);
    if (!mounted) return;
    Navigator.of(context).pop(const _CardEditResult.deleted());
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
                      'Kayıtlı Kartı Düzenle',
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
                          const _FieldLabel('Kart Numarası'),
                          const SizedBox(height: 8),
                          Semantics(
                            readOnly: true,
                            label:
                                'Kart numarası. Son dört hanesi ${widget.card.last4}. Salt okunur.',
                            excludeSemantics: true,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _SchemeChip(scheme: widget.card.scheme.name),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '•••• •••• •••• ${widget.card.last4}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: figtree(
                                        size: 13.5,
                                        weight: W.semibold,
                                        color: AppColors.inkSoft,
                                        tracking: Tracking.wide,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AppIcons.lock(
                                    size: 16,
                                    color: AppColors.inkFaint,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ResponsiveFieldPair(
                            first: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Son Kullanma'),
                                const SizedBox(height: 8),
                                _ValidatedTextField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  validator: validateCardExpiry,
                                  onChanged: (v) {
                                    final formatted = _formatExpiry(v);
                                    _setFormatted(_expiryController, formatted);
                                    if (formatted.length == 5) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_cvvFocus);
                                    }
                                  },
                                  style: figtree(size: 14, weight: W.bold),
                                  decoration: _fieldDecoration('AA/YY'),
                                ),
                              ],
                            ),
                            second: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Flexible(
                                      child: _FieldLabel('Güvenlik Kodu'),
                                    ),
                                    const SizedBox(width: 4),
                                    Semantics(
                                      button: true,
                                      label: 'Güvenlik kodu nedir, bilgi al',
                                      child: PressableScale(
                                        scale: 0.85,
                                        onTap: _showCvvHelp,
                                        child: Icon(
                                          Icons.help_outline_rounded,
                                          size: 15,
                                          color: AppColors.inkFaint,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _ValidatedTextField(
                                  controller: _cvvController,
                                  focusNode: _cvvFocus,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _updateCard(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  validator: _validateCvv,
                                  style: figtree(size: 14, weight: W.bold),
                                  decoration: _fieldDecoration('•••'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'CVV/CVC kodunuz kaydedilmez; son kullanma tarihini değiştirirseniz kartı doğrulamak için istenir.',
                            style: figtree(
                              size: 11.5,
                              weight: W.medium,
                              color: AppColors.inkFaint,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(height: 1, color: AppColors.surfaceBorder),
                          const SizedBox(height: 20),
                          const _FieldLabel('Takma Ad'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _labelController,
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              final label = value?.trim() ?? '';
                              if (label.isEmpty) {
                                return 'Takma ad boş bırakılamaz.';
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
                          const SizedBox(height: 20),
                          Container(height: 1, color: AppColors.surfaceBorder),
                          const SizedBox(height: 20),
                          if (widget.card.isPrimary)
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
                                  Icon(
                                    Icons.star_rounded,
                                    size: 20,
                                    color: AppColors.brand700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Bu, birincil kartınız. Ödeme geldiğinde bu karttan çekilir.',
                                      style: figtree(
                                        size: 12.5,
                                        weight: W.semibold,
                                        color: AppColors.brand800,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Semantics(
                              container: true,
                              checked: _setPrimary,
                              label: 'Bu kartı birincil kart olarak ayarla',
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () =>
                                    setState(() => _setPrimary = !_setPrimary),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _setPrimary,
                                        onChanged: (value) => setState(
                                          () => _setPrimary = value ?? false,
                                        ),
                                        activeColor: AppColors.brand600,
                                        side: const BorderSide(
                                          color: AppColors.inkFaint,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Bu kartı birincil kart olarak ayarla. Ödemeler bundan sonra bu karttan çekilir.',
                                          style: figtree(
                                            size: 12.5,
                                            weight: W.semibold,
                                            color: AppColors.ink,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                          'Kart numaranız maskelenerek gösterilir ve bu ekrandan değiştirilemez; son kullanma tarihi, güvenlik kodu ve takma adı güncelleyebilirsiniz.',
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: _EditActionButton(
                  label: 'Kartı Sil',
                  semanticLabel: 'Kayıtlı kartı sil',
                  onTap: _confirmDelete,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EditActionButton(
                  label: 'Güncelle',
                  semanticLabel: 'Kartı güncelle',
                  onTap: _updateCard,
                  isPrimary: true,
                ),
              ),
            ],
          ),
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

class _ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextStyle? style;
  final InputDecoration decoration;
  final bool obscureText;

  const _ValidatedTextField({
    required this.controller,
    required this.decoration,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.style,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      builder: (field) => TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: style,
        decoration: decoration.copyWith(errorText: field.errorText),
        onChanged: (value) {
          onChanged?.call(value);
          field.didChange(controller.text);
        },
        onSubmitted: onFieldSubmitted,
      ),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsiveFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaledLabelSize = MediaQuery.textScalerOf(context).scale(10.5);
        final hasRoomForTwoColumns =
            constraints.maxWidth >= 340 && scaledLabelSize <= 13;

        if (!hasRoomForTwoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 14), second],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 10),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _EditActionButton extends StatelessWidget {
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool isPrimary;

  const _EditActionButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: PressableScale(
        scale: 0.98,
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.nearBlack : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: AppColors.ink.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
          ),
          child: Center(
            child: Text(
              label,
              style: figtree(
                size: 14.5,
                weight: W.extrabold,
                color: isPrimary ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
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

class _EmptyCardsState extends StatelessWidget {
  const _EmptyCardsState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.brand100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: AppIcons.creditCard(size: 24, color: AppColors.brand700),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Henüz kayıtlı kartınız yok',
          style: figtree(size: 14.5, weight: W.extrabold),
        ),
        const SizedBox(height: 4),
        Text(
          'Bakiye yüklemelerinde kullanabilmek için yukarıdan bir kart ekleyin.',
          textAlign: TextAlign.center,
          style: figtree(
            size: 12.5,
            weight: W.medium,
            color: AppColors.inkSoft,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
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
          border: Border.all(
            color: card.isPrimary
                ? AppColors.brand300
                : const Color(0xFFE5ECEB),
            width: card.isPrimary ? 1.4 : 1,
          ),
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
            _SchemeChip(scheme: card.scheme.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.label.isNotEmpty ? card.label : 'Kart',
                          style: figtree(
                            size: 13.5,
                            weight: W.extrabold,
                            color: AppColors.ink,
                            tracking: Tracking.tight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (card.isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brand100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: AppColors.brand700,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Varsayılan',
                                style: figtree(
                                  size: 10,
                                  weight: W.extrabold,
                                  color: AppColors.brand700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
