import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Kart saklama faaliyetine özel, katmanlı KVKK aydınlatma ekranı.
///
/// YAYIN ÖNCESİ: Ticari unvan, tebligat adresi, KVKK başvuru kanalı,
/// ödeme kuruluşu ve varsa yurt dışı aktarım bilgileri hukuk danışmanı ile
/// doğrulanmalıdır.
class CardStorageNoticeScreen extends StatelessWidget {
  const CardStorageNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sheetBg,
      appBar: AppBar(
        backgroundColor: AppColors.sheetBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kapat',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.inkSoft),
        ),
        title: Text(
          'Kart Saklama Aydınlatma Metni',
          style: figtree(size: 16, weight: W.extrabold, color: AppColors.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _IntroCard(),
            const SizedBox(height: 14),
            _DraftNotice(),
            const SizedBox(height: 18),
            _Section(
              icon: Icons.business_outlined,
              title: '1. Veri sorumlusu',
              body:
                  'Kart saklama faaliyeti bakımından veri sorumlusu, Parosis Sulama hizmetini sunan işletmecidir. Veri sorumlusunun tam ticari unvanı, açık adresi ve KVKK başvuru kanalı yayın öncesinde bu alana eklenecektir.',
            ),
            _Section(
              icon: Icons.credit_card_outlined,
              title: '2. İşlenen veriler',
              body:
                  'Kart üzerindeki ad-soyad, kartın maskelenmiş son dört hanesi, son kullanma tarihi, kart türü, kartınıza verdiğiniz ad, ödeme kuruluşunca üretilen kart belirteci (token) ile onay ve işlem kayıtları işlenebilir. CVV/CVC kodu saklanmaz.',
            ),
            _Section(
              icon: Icons.flag_outlined,
              title: '3. İşleme amacı',
              body:
                  'Veriler, seçtiğiniz ödeme yöntemini hesabınızla ilişkilendirmek, sonraki bakiye yüklemelerinde hızlı ve güvenli ödeme sunmak, kart tercihlerinizi yönetmek, sahteciliği önlemek ve bilgi güvenliğini sağlamak amaçlarıyla işlenir.',
            ),
            _Section(
              icon: Icons.gavel_outlined,
              title: '4. Toplama yöntemi ve hukuki sebep',
              body:
                  'Veriler mobil uygulamadaki kart ekleme formu ve ödeme kuruluşunun güvenli altyapısı üzerinden elektronik olarak elde edilir. Kartın sonraki işlemler için saklanması, 6698 sayılı Kanun’un 5/1 maddesi kapsamında verdiğiniz açık rızaya dayanır. Güvenlik ve işlem kayıtları, uygulanabildiği ölçüde Kanun’un 5/2 maddesindeki hukuki yükümlülük ve meşru menfaat şartlarına dayanabilir.',
            ),
            _Section(
              icon: Icons.swap_horiz_rounded,
              title: '5. Aktarım',
              body:
                  'Veriler; kart saklama ve ödeme hizmetinin sunulmasıyla sınırlı olarak anlaşmalı lisanslı ödeme kuruluşuna, bankalara ve kart kuruluşlarına; hukuken gerekli hâllerde yetkili kamu kurumlarına aktarılabilir. Kullanılacak ödeme kuruluşu ve varsa yurt dışı aktarım ayrıntıları yayın öncesinde kesinleştirilecektir.',
            ),
            _Section(
              icon: Icons.schedule_outlined,
              title: '6. Saklama süresi ve rızanın geri alınması',
              body:
                  'Kart saklama tercihi, kartı hesabınızdan silene veya açık rızanızı geri alana kadar sürer. Rızanın geri alınması geçmiş işlemlerin hukuka uygunluğunu etkilemez. Kanuni saklama zorunluluğu bulunan işlem ve güvenlik kayıtları ilgili sürelerin sonunda silinir, yok edilir veya anonim hâle getirilir.',
            ),
            _Section(
              icon: Icons.account_balance_outlined,
              title: '7. KVKK kapsamındaki haklarınız',
              body:
                  '6698 sayılı Kanun’un 11. maddesi kapsamında verilerinizin işlenip işlenmediğini öğrenme, bilgi talep etme, düzeltme, silme veya yok etme, aktarılan üçüncü kişilere bildirim isteme, otomatik analiz sonucuna itiraz etme ve zararın giderilmesini talep etme haklarına sahipsiniz. Başvuru kanalı ve usulü, veri sorumlusu bilgileri kesinleştiğinde burada yayımlanacaktır.',
              isLast: true,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.brand100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.brand700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bu metin yalnızca kart saklama faaliyetine ilişkindir. Genel gizlilik politikası ve diğer veri işleme faaliyetleri ayrıca sunulmalıdır.',
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
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brand700, AppColors.brand600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            'Kartınızın nasıl korunduğunu bilin',
            style: figtree(size: 16, weight: W.extrabold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Bu metin, ödeme yönteminizin sonraki yüklemeler için saklanması sırasında kişisel verilerinizin nasıl işlendiğini açıklar.',
            style: figtree(
              size: 12.2,
              weight: W.medium,
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.edit_note_rounded,
            size: 21,
            color: Color(0xFFC2410C),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Yayın öncesi hukuk kontrolü gerekli: ticari unvan, adres, başvuru kanalı ve ödeme kuruluşu bilgileri henüz projede tanımlı değil.',
              style: figtree(
                size: 11.5,
                weight: W.semibold,
                color: const Color(0xFF9A3412),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool isLast;

  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.brand700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: figtree(
                    size: 13.5,
                    weight: W.extrabold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: figtree(
                    size: 12,
                    weight: W.medium,
                    color: AppColors.inkSoft,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
