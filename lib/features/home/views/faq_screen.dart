import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/load_result.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/sub_page.dart';
import '../../../ui/tokens.dart';
import 'guidelines_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final c = Get.find<InfoController>();

  @override
  void initState() {
    super.initState();
    c.loadFAQs();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final st = c.faqStatus.value;
      final list = c.faqList.toList();
      List<Widget> children;
      if (st == LoadStatus.loading) {
        children = [for (var i = 0; i < 4; i++) const Glass(child: Skeleton(height: 18))];
      } else if (st == LoadStatus.error) {
        children = [Glass(child: InlineNotice.error('Couldn\'t load the FAQ.', c.loadFAQs))];
      } else if (list.isEmpty) {
        children = [Glass(child: Text('No questions have been published yet.', style: T.muted))];
      } else {
        children = [
          for (final f in list) _FaqItem(q: '${f['question'] ?? ''}', a: '${f['answer'] ?? ''}'),
        ];
      }
      return SubPage(title: 'FAQ', onRefresh: c.loadFAQs, children: children);
    });
  }
}

class _FaqItem extends StatefulWidget {
  final String q, a;
  const _FaqItem({required this.q, required this.a});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      pressedScale: 0.99,
      onTap: () => setState(() => _open = !_open),
      child: Glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.q, style: T.strong)),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 350),
                  curve: kEase,
                  child: const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 16),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 380),
              curve: kEase,
              alignment: Alignment.topCenter,
              child: _open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: simpleHtml(widget.a)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
