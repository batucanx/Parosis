import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:parosis_sulama/core/geo/countries.dart';
import 'package:parosis_sulama/core/geo/turkey_provinces.dart';
import 'package:parosis_sulama/features/profile/domain/entities/user.dart';
import 'package:parosis_sulama/features/profile/presentation/controllers/profile_controller.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/page_heading.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';
import 'package:parosis_sulama/widgets/searchable_picker_field.dart';

class AddressInfoScreen extends StatefulWidget {
  final ProfileController controller;
  final VoidCallback? onSaved;
  const AddressInfoScreen({super.key, required this.controller, this.onSaved});

  @override
  State<AddressInfoScreen> createState() => _AddressInfoScreenState();
}

class _AddressInfoScreenState extends State<AddressInfoScreen> {
  final _postalCodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _country;
  String? _province;
  String? _district;
  bool _attemptedSubmit = false;
  bool _initialized = false;

  void _initFromUser(User user) {
    if (_initialized) return;
    _initialized = true;
    _country = user.country.isEmpty ? 'Türkiye' : user.country;
    _province = user.province.isEmpty ? null : user.province;
    _district = user.district.isEmpty ? null : user.district;
    _postalCodeCtrl.text = user.postalCode;
    _addressCtrl.text = user.address;
  }

  @override
  void dispose() {
    _postalCodeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  List<String> get _districtOptions =>
      turkeyProvinceDistricts[_province] ?? const [];

  bool get _hasAllFields =>
      (_country?.trim().isNotEmpty ?? false) &&
      (_province?.trim().isNotEmpty ?? false) &&
      (_district?.trim().isNotEmpty ?? false) &&
      _postalCodeCtrl.text.trim().isNotEmpty &&
      _addressCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() => _attemptedSubmit = true);
    if (!_hasAllFields) return;

    final success = await widget.controller.updateAddress(
      country: _country!.trim(),
      province: _province!.trim(),
      district: _district!.trim(),
      postalCode: _postalCodeCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adres bilgileri kaydedildi.')),
    );
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final user = widget.controller.user;
      if (user != null) _initFromUser(user);

      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 104),
        children: [
          const PageHeading(
            title: 'Adres Bilgilerim',
            subtitle:
                'Kuyularınızı başlatabilmek için adres bilgilerinizi tamamlayın',
          ),
          const SizedBox(height: 20),
          if (user == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Profil yükleniyor…',
                  style: figtree(
                    size: 13,
                    weight: W.semibold,
                    color: AppColors.inkFaint,
                  ),
                ),
              ),
            )
          else
            GlassPanel(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchablePickerField(
                    label: 'Ülke',
                    hint: 'Ülke seçiniz…',
                    value: _country,
                    options: countries,
                    onSelected: (v) => setState(() => _country = v),
                  ),
                  const SizedBox(height: 14),
                  SearchablePickerField(
                    label: 'İl',
                    hint: 'İl seçiniz…',
                    value: _province,
                    options: turkeyProvinceDistricts.keys.toList(),
                    onSelected: (v) => setState(() {
                      _province = v;
                      _district = null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  SearchablePickerField(
                    label: 'İlçe / Şehir',
                    hint: _province == null ? 'Önce il seçin' : 'İlçe seçiniz…',
                    value: _district,
                    options: _districtOptions,
                    enabled: _province != null,
                    onSelected: (v) => setState(() => _district = v),
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Posta Kodu'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _postalCodeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onChanged: (_) => setState(() {}),
                    style: figtree(size: 14, weight: W.semibold),
                    decoration: _fieldDecoration(''),
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel('Açık Adres'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressCtrl,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: figtree(size: 14, weight: W.semibold),
                    decoration: _fieldDecoration(''),
                  ),
                  if (_attemptedSubmit && !_hasAllFields) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Kuyuları başlatabilmek için tüm adres alanlarını doldurmanız gerekiyor.',
                      style: figtree(
                        size: 11.5,
                        weight: W.semibold,
                        color: AppColors.red600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 20),
          PressableScale(
            scale: .98,
            disabled: widget.controller.isSubmitting,
            onTap: _submit,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.nearBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: widget.controller.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Bilgileri Kaydet',
                        style: figtree(
                          size: 14.5,
                          weight: W.extrabold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      );
    },
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
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: figtree(size: 12, weight: W.semibold, color: AppColors.inkSoft),
  );
}
