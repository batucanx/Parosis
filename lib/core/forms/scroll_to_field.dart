import 'package:flutter/widgets.dart';

typedef ValidatedField = (String? error, GlobalKey key, FocusNode? focusNode);

Future<void> scrollToFirstError(List<ValidatedField> fields) async {
  for (final (error, key, focusNode) in fields) {
    if (error == null) continue;
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
    if (focusNode != null) FocusScope.of(ctx).requestFocus(focusNode);
    return;
  }
}
