import 'package:flutter/material.dart';

import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/glass.dart';
import 'package:parosis_sulama/widgets/modal_header.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: Column(
        children: [
          const ModalHeader(title: 'Yardım & Destek'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                GlassPanel(
                  borderRadius: BorderRadius.circular(21),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  elevated: false,
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.sea100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: AppIcons.helpCircle(
                            size: 26,
                            color: AppColors.sea700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Yardım merkezi yakında burada',
                        textAlign: TextAlign.center,
                        style: figtree(size: 14.5, weight: W.extrabold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sıkça sorulan sorular ve destek hattı bilgileri '
                        'çok yakında bu ekrana eklenecek.',
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
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
