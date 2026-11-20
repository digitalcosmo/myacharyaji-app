import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a 24×24 stroke path (prototype `ic()` helper) with flutter_svg,
/// which handles every SVG path command correctly.
class StrokeIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double size;
  final double strokeWidth;

  /// Extra SVG elements (e.g. `<circle cx="12" cy="12" r="4"/>`).
  final String extra;

  const StrokeIcon(
    this.path, {
    super.key,
    required this.color,
    this.size = 18,
    this.strokeWidth = 2,
    this.extra = '',
  });

  String _hex(Color c) {
    final argb = c.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="${_hex(color)}" stroke-opacity="${color.a.toStringAsFixed(3)}" '
        'stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">'
        '$extra<path d="$path"/></svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// Icon paths reused across screens.
class Ic {
  Ic._();
  static const chevLeft = 'M15 5l-7 7 7 7';
  static const chevRight = 'M9 5l7 7-7 7';
  static const chevDown = 'M6 9l6 6 6-6';
  static const calendar = 'M3 5h18v16H3zM3 10h18M8 3v4M16 3v4';
  static const check = 'M5 12l5 5 9-10';
  static const phone =
      'M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2';
  static const whatsapp = 'M21 12a9 9 0 0 1-13.5 7.8L3 21l1.2-4.5A9 9 0 1 1 21 12z';
  static const mail = 'M3 6h18v12H3zM3 7l9 6 9-6';
  static const pin = 'M12 21s-7-6.2-7-11a7 7 0 0 1 14 0c0 4.8-7 11-7 11zM12 12.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5z';
  static const user = 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21c1.2-4 4.6-6 8-6s6.8 2 8 6';
  static const doc = 'M6 3h9l4 4v14H6zM14 3v5h5M9 13h7M9 17h5';
  static const sunRays =
      'M12 2v2.5M12 19.5V22M2 12h2.5M19.5 12H22M4.9 4.9l1.8 1.8M17.3 17.3l1.8 1.8M4.9 19.1l1.8-1.8M17.3 6.7l1.8-1.8';
  static const sunCircle = '<circle cx="12" cy="12" r="4"/>';
  static const book = 'M4 5a2 2 0 0 1 2-2h14v16H6a2 2 0 0 0-2 2zM4 21V5';
  static const help = 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.6V14M12 17.5v.01';
  static const shield = 'M12 3l8 3v6c0 4.5-3.4 8.3-8 9-4.6-.7-8-4.5-8-9V6z';
  static const logout = 'M15 4h4v16h-4M10 8l-4 4 4 4M6 12h11';
  static const refresh = 'M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7';
  static const lock = 'M6 11h12v10H6zM8 11V8a4 4 0 0 1 8 0v3';
  static const star = 'M12 3l2.5 5.5L20 9l-4 4 1 6-5-3-5 3 1-6-4-4 5.5-.5z';
  static const edit = 'M4 20h4L19 9l-4-4L4 16zM14 6l4 4';
}
