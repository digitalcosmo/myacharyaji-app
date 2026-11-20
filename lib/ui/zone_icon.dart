import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/zone.dart';
import 'zone_svgs.dart';

/// The zone's chevron icon from the CK reports (triple-up green for Optimal
/// … triple-down red for Critical), with the same soft glow behind it.
class ZoneIcon extends StatelessWidget {
  final Zone zone;
  final double size;
  final bool glow;
  const ZoneIcon(this.zone, {super.key, this.size = 22, this.glow = true});

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.string(kZoneSvgs[zone.svgKey]!, width: size, height: size);
    return SizedBox(
      width: size,
      height: size,
      child: glow
          ? Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.75,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: size * 0.12, sigmaY: size * 0.12),
                    child: svg,
                  ),
                ),
                svg,
              ],
            )
          : svg,
    );
  }
}
