import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/load_result.dart';
import '../../../ui/glass.dart';
import '../../../ui/states.dart';
import '../../../ui/sub_page.dart';
import '../../../ui/tokens.dart';

/// How to read the planner — content comes from the Guidline API as simple
/// HTML, rendered here as headings, paragraphs and bullet points.
class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  State<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends State<GuidelinesScreen> {
  final c = Get.find<InfoController>();

  @override
  void initState() {
    super.initState();
    c.loadGuidelines();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final st = c.guidelineStatus.value;
      final html = c.guidelineContent.value;
      Widget body;
      if (st == LoadStatus.loading) {
        body = const Glass(child: DimBarsSkeleton());
      } else if (st == LoadStatus.error) {
        body = Glass(child: InlineNotice.error('Couldn\'t load the guidelines.', c.loadGuidelines));
      } else if (html.isEmpty) {
        body = Glass(child: Text('No guidelines have been published yet.', style: T.muted));
      } else {
        body = Glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: simpleHtml(html)));
      }
      return SubPage(title: 'How to read your planner', onRefresh: c.loadGuidelines, children: [body]);
    });
  }
}

/// Very small HTML → widgets converter for server-authored help text.
List<Widget> simpleHtml(String html) {
  String clean(String s) => s
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final out = <Widget>[];
  final re = RegExp(r'<(h[1-6]|p|li|div)[^>]*>([\s\S]*?)</\1>', caseSensitive: false);
  final matches = re.allMatches(html).toList();
  if (matches.isEmpty) {
    for (final para in html.split(RegExp(r'<br\s*/?>|\n\n', caseSensitive: false))) {
      final t = clean(para);
      if (t.isNotEmpty) {
        out.add(Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(t, style: T.muted)));
      }
    }
    return out;
  }
  for (final m in matches) {
    final tag = m.group(1)!.toLowerCase();
    final t = clean(m.group(2)!);
    if (t.isEmpty) continue;
    if (tag.startsWith('h')) {
      out.add(Padding(
        padding: EdgeInsets.only(top: out.isEmpty ? 0 : 14, bottom: 6),
        child: Text(t, style: T.h3.copyWith(color: AppColors.sun2)),
      ));
    } else if (tag == 'li') {
      out.add(Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 10),
              child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle)),
            ),
            Expanded(child: Text(t, style: T.muted)),
          ],
        ),
      ));
    } else {
      out.add(Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: T.muted)));
    }
  }
  return out;
}
