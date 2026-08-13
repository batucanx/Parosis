import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  AppIcons._();

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  static Widget _svg(
    String inner, {
    required double size,
    required Color color,
    double strokeWidth = 1.8,
  }) {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="${_hex(color)}" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">$inner</svg>';
    final picture = SvgPicture.string(svg, width: size, height: size);
    final opacity = color.a;
    return opacity < 1 ? Opacity(opacity: opacity, child: picture) : picture;
  }

  static Widget logoMark({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M12 3.2s5.8 5.5 5.8 9.5a5.8 5.8 0 1 1-11.6 0C6.2 8.7 12 3.2 12 3.2Z" />'
    '<path d="M10.1 15.6c0-2.7 1.9-4.6 4.6-4.8.2 2.7-1.8 4.7-4.6 4.8Z" />'
    '<path d="M14.7 10.8 10.4 15.3" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget droplet({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M12 3.4s5.6 5.4 5.6 9.3a5.6 5.6 0 1 1-11.2 0C6.4 8.8 12 3.4 12 3.4Z" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget home({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M4 10.2 12 4l8 6.2v8.1a1.7 1.7 0 0 1-1.7 1.7H5.7A1.7 1.7 0 0 1 4 18.3v-8.1Z" />'
    '<path d="M9.6 20v-6.2h4.8V20" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget user({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<circle cx="12" cy="8.2" r="3.6" />'
    '<path d="M4.8 19.6a7.2 7.2 0 0 1 14.4 0" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget wallet({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M3.4 8.6A2.6 2.6 0 0 1 6 6h11.4a2.6 2.6 0 0 1 2.6 2.6v7.8a2.6 2.6 0 0 1-2.6 2.6H6a2.6 2.6 0 0 1-2.6-2.6V8.6Z" />'
    '<path d="M16.4 12.5h3.6" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget plus({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 2.2,
  }) => _svg(
    '<path d="M12 5.4v13.2M5.4 12h13.2" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget search({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<circle cx="10.8" cy="10.8" r="6.4" />'
    '<path d="m15.6 15.6 4 4" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget play({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M8.4 5.6 18 12l-9.6 6.4V5.6Z" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget arrowLeft({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 2.2,
  }) => _svg(
    '<path d="M19 12H5" />'
    '<path d="m11 6-6 6 6 6" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget chevronRight({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 2.2,
  }) => _svg(
    '<path d="m9.6 5.6 6.4 6.4-6.4 6.4" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget calendarClock({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<rect x="3.4" y="5.2" width="17.2" height="15.4" rx="3" />'
    '<path d="M3.4 9.8h17.2M8.2 3.4v3.6M15.8 3.4v3.6" />'
    '<path d="M12 12.8v2.8l2 1.2" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget history({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M3.6 12a8.4 8.4 0 1 0 2.5-6" />'
    '<path d="M3.4 3.8v4.6h4.6" />'
    '<path d="M12 7.6V12l3 1.8" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget clock({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<circle cx="12" cy="12" r="8.4" />'
    '<path d="M12 7.4V12l3 1.8" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget mapPin({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M12 21.2s6.6-5.4 6.6-10.4a6.6 6.6 0 0 0-13.2 0c0 5 6.6 10.4 6.6 10.4Z" />'
    '<circle cx="12" cy="10.6" r="2.6" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget gauge({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M4.2 17.4a8.6 8.6 0 1 1 15.6 0" />'
    '<path d="m14.6 9.8-2.8 4.2" />'
    '<circle cx="12" cy="17.4" r="1.3" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget thermometer({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M13.8 13.4V5.6a1.8 1.8 0 1 0-3.6 0v7.8a3.6 3.6 0 1 0 3.6 0Z" />'
    '<path d="M12 15.4v-4" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget bolt({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M13.4 2.8 5.2 13.4h5.6l-1 7.8 8.2-10.6h-5.6l1-7.8Z" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget signal({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M12 19.4h.01" />'
    '<path d="M8.4 15.9a5.1 5.1 0 0 1 7.2 0" />'
    '<path d="M5.2 12.6a9.6 9.6 0 0 1 13.6 0" />'
    '<path d="M2.2 9.4a14 14 0 0 1 19.6 0" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget globe({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<circle cx="12" cy="12" r="8.4" />'
    '<path d="M3.6 12h16.8" />'
    '<path d="M12 3.6c2.1 2.3 3.3 5.3 3.3 8.4s-1.2 6.1-3.3 8.4c-2.1-2.3-3.3-5.3-3.3-8.4S9.9 5.9 12 3.6Z" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget mail({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<rect x="3.2" y="5.6" width="17.6" height="12.8" rx="2.6" />'
    '<path d="m4.4 8 6.3 4.4a2.2 2.2 0 0 0 2.6 0L19.6 8" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget phone({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M8.1 4.4h-2A2.1 2.1 0 0 0 4 6.7c.4 6.7 5.6 11.9 12.3 12.3a2.1 2.1 0 0 0 2.3-2.1v-2a1.4 1.4 0 0 0-1.1-1.4l-2.4-.5a1.4 1.4 0 0 0-1.4.6l-.7 1a11 11 0 0 1-4.4-4.4l1-.7a1.4 1.4 0 0 0 .6-1.4l-.5-2.4a1.4 1.4 0 0 0-1.4-1.1Z" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget idCard({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<rect x="3" y="5.4" width="18" height="13.2" rx="2.8" />'
    '<circle cx="8.6" cy="10.8" r="1.9" />'
    '<path d="M5.6 15.8a3.4 3.4 0 0 1 6 0" />'
    '<path d="M14.4 10.4h4M14.4 13.8h2.8" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget check({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 2.4,
  }) => _svg(
    '<path d="m5 12.6 4.6 4.6L19 6.8" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget creditCard({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<rect x="2.6" y="5.4" width="18.8" height="13.2" rx="2.6" />'
    '<path d="M2.6 9.6h18.8" />'
    '<path d="M5.6 14.4h4.4" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget x({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 2.2,
  }) => _svg(
    '<path d="m6 6 12 12M18 6 6 18" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget lock({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<rect x="5" y="10" width="14" height="10" rx="2.5" />'
    '<path d="M8 10V7.5a4 4 0 0 1 8 0V10" />'
    '<path d="M12 14v2" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget chevronDown({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="m6 9 6 6 6-6" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget menu({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 2,
  }) => _svg(
    '<path d="M4 6h16M4 12h16M4 18h16" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget listChecks({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M4 8h10M4 14h7" />'
    '<path d="m13 12 2 2 4-4" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget tractor({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M3 8v8a5 5 0 0 0 10 0V8H3Z" />'
    '<path d="M13 8V6a2 2 0 0 1 4 0v2" />'
    '<circle cx="19" cy="17" r="2" />'
    '<path d="M13 14h6" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget eye({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M2.4 12S5.8 5.6 12 5.6 21.6 12 21.6 12 18.2 18.4 12 18.4 2.4 12 2.4 12Z" />'
    '<circle cx="12" cy="12" r="3" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget eyeOff({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M3.6 3.6l16.8 16.8" />'
    '<path d="M10.6 5.7A10.4 10.4 0 0 1 12 5.6c6.2 0 9.6 6.4 9.6 6.4a15.6 15.6 0 0 1-3.5 4.4M7.2 7.3C4.4 9.1 2.4 12 2.4 12s3.4 6.4 9.6 6.4c1.4 0 2.7-.3 3.8-.8" />'
    '<path d="M9.9 10a3 3 0 0 0 4.1 4.1" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget logout({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M9 4.4H6.4A2 2 0 0 0 4.4 6.4v11.2a2 2 0 0 0 2 2H9" />'
    '<path d="M16 15.6 20 12l-4-3.6" />'
    '<path d="M20 12H9.6" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget bell({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M6 8.4a6 6 0 0 1 12 0c0 4.2 1.6 5.6 1.6 5.6H4.4S6 12.6 6 8.4Z" />'
    '<path d="M10.2 18.4a1.8 1.8 0 0 0 3.6 0" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget shield({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M12 3.4 5 5.8v5.6c0 4.8 3 7.9 7 8.8 4-.9 7-4 7-8.8V5.8L12 3.4Z" />'
    '<path d="m9.2 12 2 2 3.6-4" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget helpCircle({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<circle cx="12" cy="12" r="8.6" />'
    '<path d="M9.6 9.4a2.4 2.4 0 1 1 3.4 2.2c-.8.4-1 .9-1 1.6" />'
    '<path d="M12 17.2h.01" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );

  static Widget droplets({
    double size = 24,
    Color color = Colors.black,
    double strokeWidth = 1.8,
  }) => _svg(
    '<path d="M7 16.3c2.2 0 4-1.83 4-4.05 0-1.16-.57-2.26-1.71-3.19S7.29 6.75 7 5.3c-.29 1.45-1.14 2.84-2.29 3.76S3 11.1 3 12.25c0 2.22 1.8 4.05 4 4.05Z" />'
    '<path d="M12.56 6.6A10.97 10.97 0 0 0 14 3.02c.5 2.5 2 4.9 4 6.5s3 3.5 3 5.5a6.98 6.98 0 0 1-11.91 4.97" />',
    size: size,
    color: color,
    strokeWidth: strokeWidth,
  );
}
