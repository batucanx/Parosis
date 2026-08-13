import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parosis_sulama/core/geo/countries.dart';
import 'package:parosis_sulama/core/geo/turkey_provinces.dart';
import 'package:parosis_sulama/features/well_requests/domain/entities/well_request.dart';
import 'package:parosis_sulama/features/well_requests/presentation/controllers/well_requests_controller.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/confirm_dialog.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/searchable_picker_field.dart';

/// Yeni kuyu talebi oluşturma / mevcut (henüz onaylanmamış) bir talebi
/// düzenleme formu. `existing` verilmezse yeni talep, verilirse düzenleme
/// modunda açılır.
class WellRequestFormScreen extends StatefulWidget {
  final WellRequestsController controller;
  final WellRequest? existing;
  const WellRequestFormScreen({
    super.key,
    required this.controller,
    this.existing,
  });

  @override
  State<WellRequestFormScreen> createState() => _WellRequestFormScreenState();
}

class _WellRequestFormScreenState extends State<WellRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _postalCodeCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  late String _country;
  String? _province;
  String? _district;
  bool _attemptedSubmit = false;
  bool _locating = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _neighborhoodCtrl = TextEditingController(
      text: existing?.neighborhood ?? '',
    );
    _postalCodeCtrl = TextEditingController(text: existing?.postalCode ?? '');
    _addressCtrl = TextEditingController(text: existing?.address ?? '');
    _latCtrl = TextEditingController(
      text: existing?.latitude?.toString() ?? '',
    );
    _lngCtrl = TextEditingController(
      text: existing?.longitude?.toString() ?? '',
    );
    _country = existing?.country ?? 'Türkiye';
    _province = existing?.province;
    _district = existing?.district;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _postalCodeCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  List<String> get _districtOptions =>
      turkeyProvinceDistricts[_province] ?? const [];

  Future<void> _submit() async {
    setState(() => _attemptedSubmit = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _province == null || _district == null) return;

    final latitude = double.tryParse(_latCtrl.text.trim());
    final longitude = double.tryParse(_lngCtrl.text.trim());

    final result = _isEditing
        ? await widget.controller.updateRequest(
            id: widget.existing!.id,
            name: _nameCtrl.text.trim(),
            country: _country,
            province: _province!,
            district: _district!,
            neighborhood: _neighborhoodCtrl.text.trim(),
            postalCode: _postalCodeCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            latitude: latitude,
            longitude: longitude,
          )
        : await widget.controller.createRequest(
            name: _nameCtrl.text.trim(),
            country: _country,
            province: _province!,
            district: _district!,
            neighborhood: _neighborhoodCtrl.text.trim(),
            postalCode: _postalCodeCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            latitude: latitude,
            longitude: longitude,
          );

    if (!mounted || result == null) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _getCoordinates() async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.location_on_rounded,
      title: 'Kuyunun Yanında mısınız?',
      message:
          'Konum, o an bulunduğunuz yerden alınır. Doğru enlem/boylam için '
          'bu işlemi su kuyusunun yanındayken yapmanız gerekir.',
      confirmLabel: 'Onaylıyorum',
    );
    if (!confirmed || !mounted) return;

    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Konum servisleri kapalı. Lütfen açıp tekrar deneyin.';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'Konum izni verilmedi. Ayarlardan konum iznini açmanız gerekiyor.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latCtrl.text = position.latitude.toStringAsFixed(6);
        _lngCtrl.text = position.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (mounted) {
        final message = e is String
            ? e
            : 'Konum alınamadı. Lütfen tekrar deneyin.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                  label: 'Kuyu talebi formunu kapat',
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
                    _isEditing ? 'Kuyu Talebini Düzenle' : 'Yeni Kuyu Talebi',
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              children: [
                GlassPanel(
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Kuyu Adı', required: true, bold: true),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Kuyu adı gerekli.';
                            if (v.length < 2)
                              return 'En az 2 karakter giriniz.';
                            return null;
                          },
                          style: figtree(size: 15, weight: W.bold),
                          decoration: _fieldDecoration(
                            'Örn: Kuzey Tarla Kuyusu',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(height: 1, color: AppColors.surfaceBorder),
                        const SizedBox(height: 20),
                        Text(
                          'Konum / Adres',
                          style: figtree(size: 14, weight: W.extrabold),
                        ),
                        const SizedBox(height: 14),
                        _ResponsiveFieldPair(
                          first: SearchablePickerField(
                            label: 'Ülke',
                            hint: 'Ülke seçiniz…',
                            value: _country,
                            options: countries,
                            onSelected: (v) => setState(() => _country = v),
                          ),
                          second: SearchablePickerField(
                            label: 'İl',
                            hint: 'İl seçiniz…',
                            value: _province,
                            options: turkeyProvinceDistricts.keys.toList(),
                            onSelected: (v) => setState(() {
                              _province = v;
                              _district = null;
                            }),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ResponsiveFieldPair(
                          first: SearchablePickerField(
                            label: 'İlçe / Şehir',
                            hint: _province == null
                                ? 'Önce il seçin'
                                : 'İlçe seçiniz…',
                            value: _district,
                            options: _districtOptions,
                            enabled: _province != null,
                            onSelected: (v) => setState(() => _district = v),
                          ),
                          second: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Mahalle / Köy'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _neighborhoodCtrl,
                                textInputAction: TextInputAction.next,
                                style: figtree(size: 14, weight: W.semibold),
                                decoration: _fieldDecoration(''),
                              ),
                            ],
                          ),
                        ),
                        if (_attemptedSubmit && _province == null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'İl seçimi gerekli.',
                            style: figtree(
                              size: 11.5,
                              weight: W.semibold,
                              color: AppColors.red600,
                            ),
                          ),
                        ] else if (_attemptedSubmit &&
                            _province != null &&
                            _district == null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'İlçe seçimi gerekli.',
                            style: figtree(
                              size: 11.5,
                              weight: W.semibold,
                              color: AppColors.red600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        _FieldLabel('Posta Kodu'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _postalCodeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          style: figtree(size: 14, weight: W.semibold),
                          decoration: _fieldDecoration(''),
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel('Açık Adres'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressCtrl,
                          maxLines: 3,
                          style: figtree(size: 14, weight: W.semibold),
                          decoration: _fieldDecoration(''),
                        ),
                        const SizedBox(height: 20),
                        Container(height: 1, color: AppColors.surfaceBorder),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.inkSoft,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Koordinat',
                              style: figtree(size: 14, weight: W.extrabold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(isteğe bağlı)',
                              style: figtree(
                                size: 11,
                                weight: W.medium,
                                color: AppColors.inkFaint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GetCoordinatesButton(
                          loading: _locating,
                          onTap: _getCoordinates,
                        ),
                        const SizedBox(height: 14),
                        _ResponsiveFieldPair(
                          first: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Enlem'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _latCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.\-]'),
                                  ),
                                ],
                                style: figtree(size: 14, weight: W.semibold),
                                decoration: _fieldDecoration('39.925533'),
                              ),
                            ],
                          ),
                          second: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Boylam'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lngCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.\-]'),
                                  ),
                                ],
                                style: figtree(size: 14, weight: W.semibold),
                                decoration: _fieldDecoration('32.866287'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"Konumu Al" ile kuyunun yanındayken enlem/boylamı '
                          'otomatik doldurabilir, ya da haritadan bulup elle '
                          'yazabilirsin (isteğe bağlı, yetkili sonra da '
                          'ekleyebilir).',
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _FormActionButton(
                        label: 'İptal',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: widget.controller,
                        builder: (context, _) => _FormActionButton(
                          label: _isEditing ? 'Güncelle' : 'Talebi Gönder',
                          isPrimary: true,
                          disabled: widget.controller.isSubmitting,
                          onTap: _submit,
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
  );
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
  final bool required;
  final bool bold;
  const _FieldLabel(this.text, {this.required = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        text,
        style: bold
            ? figtree(size: 14, weight: W.extrabold, color: AppColors.ink)
            : figtree(size: 12, weight: W.semibold, color: AppColors.inkSoft),
      ),
      if (required)
        Text(
          ' *',
          style: figtree(size: 12, weight: W.bold, color: AppColors.red600),
        ),
    ],
  );
}

class _GetCoordinatesButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _GetCoordinatesButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Konumumu al',
    child: PressableScale(
      scale: 0.97,
      disabled: loading,
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.brand100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.brand700,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      size: 17,
                      color: AppColors.brand700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Konumu Al',
                      style: figtree(
                        size: 13.5,
                        weight: W.extrabold,
                        color: AppColors.brand700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _ResponsiveFieldPair extends StatelessWidget {
  final Widget first;
  final Widget second;
  const _ResponsiveFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scaledLabelSize = MediaQuery.textScalerOf(context).scale(12);
      final hasRoomForTwoColumns =
          constraints.maxWidth >= 340 && scaledLabelSize <= 15;

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

class _FormActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool disabled;
  const _FormActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) => PressableScale(
    scale: 0.98,
    disabled: disabled,
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: disabled
            ? AppColors.mist200
            : (isPrimary ? AppColors.nearBlack : AppColors.surface),
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
  );
}
