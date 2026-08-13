import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/well_requests/presentation/controllers/well_requests_controller.dart';
import 'package:parosis_sulama/features/well_requests/presentation/screens/well_requests_tab.dart';
import 'package:parosis_sulama/widgets/page_heading.dart';

class WellRequestsScreen extends StatelessWidget {
  final WellRequestsController controller;
  const WellRequestsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 2, 20, 104),
    children: [
      const PageHeading(
        title: 'Kuyularım',
        subtitle: 'Kuyu kayıt taleplerinizi yönetin',
      ),
      const SizedBox(height: 18),
      WellRequestsTab(controller: controller),
    ],
  );
}
