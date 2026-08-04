import 'package:flutter/material.dart';
import '../icons/app_icons.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenCards;
  final ValueChanged<String> onOpenSheet;
  const ProfileScreen({
    super.key,
    required this.onOpenCards,
    required this.onOpenSheet,
  });
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 104),
    children: [
      Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.brand400, AppColors.brand600],
              ),
            ),
            child: Center(
              child: Text(
                'BC',
                style: figtree(
                  size: 16,
                  weight: W.extrabold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Batuhan Canaracı',
                style: figtree(size: 17, weight: W.extrabold),
              ),
              const SizedBox(height: 3),
              Text(
                'SLM-48210 · Aktif Üye',
                style: figtree(
                  size: 12.5,
                  weight: W.semibold,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _row(
              icon: AppIcons.user(size: 20, color: AppColors.brand700),
              label: 'Kullanıcı Bilgileri',
              subtitle: 'Ad, e-posta, ID',
              onTap: () => onOpenSheet('user'),
            ),
            _row(
              icon: AppIcons.phone(size: 20, color: AppColors.brand700),
              label: 'İletişim Bilgileri',
              subtitle: 'Telefon, e-posta',
              onTap: () => onOpenSheet('contact'),
            ),
            _row(
              icon: AppIcons.creditCard(size: 20, color: AppColors.brand700),
              label: 'Kayıtlı Kartlar',
              subtitle: 'Ödeme yöntemleriniz',
              onTap: onOpenCards,
              last: true,
            ),
          ],
        ),
      ),
    ],
  );
  Widget _row({
    required Widget icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool last = false,
  }) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: figtree(size: 14.5, weight: W.bold)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: figtree(
                    size: 12,
                    weight: W.medium,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          AppIcons.chevronRight(size: 16, color: AppColors.inkFaint),
        ],
      ),
    ),
  );
}

class ProfileInfoSheet extends StatelessWidget {
  final String type;
  final VoidCallback onClose;
  const ProfileInfoSheet({
    super.key,
    required this.type,
    required this.onClose,
  });
  @override
  Widget build(BuildContext context) {
    final rows = type == 'user'
        ? const [
            'Ad Soyad|Batuhan Canaracı',
            'E-posta|batuhancanaraci85@gmail.com',
            'Kullanıcı ID|SLM-48210',
          ]
        : const [
            'Telefon|0532 118 04 76',
            'E-posta|batuhancanaraci85@gmail.com',
          ];
    return _OverlaySheet(
      title: type == 'user' ? 'Kullanıcı Bilgileri' : 'İletişim Bilgileri',
      onClose: onClose,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [for (final row in rows) _infoRow(row)],
      ),
    );
  }

  Widget _infoRow(String data) {
    final parts = data.split('|');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parts[0],
            style: figtree(
              size: 11.5,
              weight: W.semibold,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 3),
          Text(parts[1], style: figtree(size: 14, weight: W.bold)),
        ],
      ),
    );
  }
}

class CardsSheet extends StatefulWidget {
  final VoidCallback onClose;
  const CardsSheet({super.key, required this.onClose});
  @override
  State<CardsSheet> createState() => _CardsSheetState();
}

class _CardsSheetState extends State<CardsSheet> {
  final cards = <String>[
    'Garanti Banka Kartım •••• 4242',
    'Akbank Kredi Kartım •••• 5500',
  ];
  final controller = TextEditingController();
  bool form = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _OverlaySheet(
    title: 'Kayıtlı Kartlar',
    onClose: widget.onClose,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        ElevatedButton.icon(
          onPressed: () => setState(() => form = !form),
          icon: const Icon(Icons.add),
          label: const Text('Yeni Kart Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand600,
            foregroundColor: Colors.white,
          ),
        ),
        if (form) ...[
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Kart adı',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() {
              if (controller.text.isNotEmpty)
                cards.add('${controller.text} •••• 0000');
              controller.clear();
              form = false;
            }),
            child: const Text('Kartı Kaydet'),
          ),
        ],
        const SizedBox(height: 16),
        for (final card in cards)
          Card(
            color: AppColors.brand700,
            child: ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.white),
              title: Text(
                card,
                style: figtree(size: 14, weight: W.bold, color: Colors.white),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => cards.remove(card)),
              ),
            ),
          ),
      ],
    ),
  );
}

class _OverlaySheet extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;
  const _OverlaySheet({
    required this.title,
    required this.onClose,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black.withOpacity(.4)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: 0),
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.translate(offset: Offset(0, value * 420), child: child),
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
                  color: Colors.black12,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: figtree(size: 17, weight: W.extrabold),
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, color: AppColors.red500),
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
          ),
        ),
      ],
    ),
  );
}
