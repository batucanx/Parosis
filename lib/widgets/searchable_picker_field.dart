import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Etiketli, tek seçimlik alan — dokunulunca arama kutulu bir liste sheet'i
/// açar. Ülke/İl/İlçe gibi uzun listeler için (bkz. kuyu talebi formu).
class SearchablePickerField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool enabled;

  const SearchablePickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onSelected,
    this.enabled = true,
  });

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(title: label, options: options),
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: figtree(size: 12, weight: W.semibold, color: AppColors.inkSoft),
      ),
      const SizedBox(height: 6),
      Semantics(
        button: true,
        label: '$label seçin. ${value ?? "seçilmedi"}',
        child: InkWell(
          onTap: enabled ? () => _open(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figtree(
                      size: 14,
                      weight: value == null ? W.medium : W.semibold,
                      color: value == null
                          ? AppColors.inkFaint
                          : AppColors.ink,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.inkFaint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _PickerSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  const _PickerSheet({required this.title, required this.options});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.options
        : widget.options.where((o) => o.toLowerCase().contains(q)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: figtree(size: 16, weight: W.extrabold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: figtree(size: 14, weight: W.semibold),
                decoration: InputDecoration(
                  hintText: '${widget.title} ara…',
                  hintStyle: figtree(
                    size: 14,
                    weight: W.medium,
                    color: AppColors.inkFaint,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.inkFaint,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Sonuç bulunamadı',
                        style: figtree(
                          size: 13,
                          weight: W.medium,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(
                          filtered[i],
                          style: figtree(size: 14.5, weight: W.semibold),
                        ),
                        onTap: () => Navigator.of(context).pop(filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
