import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CardsModal extends StatefulWidget {
  final VoidCallback onClose;
  const CardsModal({super.key, required this.onClose});
  @override
  State<CardsModal> createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  final cards = <_CardInfo>[
    const _CardInfo('Garanti Banka Kartım', '4242', '08/27', true),
    const _CardInfo('Akbank Kredi Kartım', '5500', '03/26', false),
  ];
  _CardInfo? editing;
  final name = TextEditingController();
  final cvv = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    cvv.dispose();
    super.dispose();
  }

  void _openEdit(_CardInfo card) => setState(() {
    editing = card;
    name.text = card.name;
    cvv.clear();
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black.withOpacity(.4)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.sizeOf(context).height - 54,
            decoration: const BoxDecoration(
              color: AppColors.sheetBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(29)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 18, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kayıtlı Kartlar',
                          style: figtree(size: 18, weight: W.extrabold),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                    children: [
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() {
                            editing = const _CardInfo(
                              '',
                              '0000',
                              '12/28',
                              true,
                            );
                            name.clear();
                          }),
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Yeni Kart Ekle',
                            style: figtree(size: 14, weight: W.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      if (editing != null && !cards.contains(editing))
                        _EditForm(
                          name: name,
                          cvv: cvv,
                          onSave: () => setState(() {
                            cards.add(_CardInfo(name.text.isEmpty ? 'Kartım' : name.text, '0000', '12/28', true));
                            editing = null;
                          }),
                          onDelete: () => setState(() => editing = null),
                          onCancel: () => setState(() => editing = null),
                        ),
                      const SizedBox(height: 18),
                      Divider(color: Colors.black12),
                      const SizedBox(height: 12),
                      for (final card in cards) ...[
                        if (editing == card)
                          _EditForm(
                            name: name,
                            cvv: cvv,
                            onSave: () => setState(() {
                              final i = cards.indexOf(card);
                              cards[i] = _CardInfo(
                                name.text.isEmpty ? card.name : name.text,
                                card.last4,
                                card.expiry,
                                card.visa,
                              );
                              editing = null;
                            }),
                            onDelete: () => setState(() {
                              cards.remove(card);
                              editing = null;
                            }),
                            onCancel: () => setState(() => editing = null),
                          )
                        else
                          _CardRow(card: card, onTap: () => _openEdit(card)),
                        const SizedBox(height: 12),
                      ],
                      if (false && editing != null && !cards.contains(editing))
                        _EditForm(
                          name: name,
                          cvv: cvv,
                          onSave: () => setState(() {
                            cards.add(
                              _CardInfo(
                                name.text.isEmpty ? 'Kartım' : name.text,
                                '0000',
                                '12/28',
                                true,
                              ),
                            );
                            editing = null;
                          }),
                          onDelete: () => setState(() => editing = null),
                          onCancel: () => setState(() => editing = null),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _CardInfo {
  final String name, last4, expiry;
  final bool visa;
  const _CardInfo(this.name, this.last4, this.expiry, this.visa);
}

class _CardRow extends StatelessWidget {
  final _CardInfo card;
  final VoidCallback onTap;
  const _CardRow({required this.card, required this.onTap});
  @override
  Widget build(BuildContext c) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5ECEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 8,
            spreadRadius: -4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _Scheme(visa: card.visa),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.name,
                        style: figtree(size: 13.5, weight: W.extrabold),
                      ),
                    ),
                    Text(
                      '•••• ${card.last4}',
                      style: figtree(size: 13.5, weight: W.extrabold),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'BATUHAN CANARACI',
                      style: figtree(
                        size: 11.5,
                        weight: W.semibold,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      card.expiry,
                      style: figtree(
                        size: 11.5,
                        weight: W.semibold,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
        ],
      ),
    ),
  );
}

class _Scheme extends StatelessWidget {
  final bool visa;
  const _Scheme({required this.visa});
  @override
  Widget build(BuildContext c) => visa
      ? Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF202078),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              'VISA',
              style: figtree(
                size: 10,
                weight: W.extrabold,
                color: Colors.white,
              ),
            ),
          ),
        )
      : const Icon(Icons.circle, color: Color(0xFFEF3340), size: 25);
}

class _EditForm extends StatelessWidget {
  final TextEditingController name, cvv;
  final VoidCallback onSave, onDelete, onCancel;
  const _EditForm({
    required this.name,
    required this.cvv,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DÜZENLE',
          style: figtree(
            size: 10.5,
            weight: W.bold,
            color: AppColors.brand700,
            tracking: Tracking.widest,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'Kart Adı',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: cvv,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'CVV / CVC',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Kaydet'),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onDelete, child: const Text('Sil')),
            TextButton(onPressed: onCancel, child: const Text('İptal')),
          ],
        ),
      ],
    ),
  );
}
