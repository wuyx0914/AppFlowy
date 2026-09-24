import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/home/shared/mobile_page_card.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

class EmptySpacePlaceholder extends StatelessWidget {
  const EmptySpacePlaceholder({
    super.key,
    required this.type,
  });

  final MobilePageCardType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlowySvg(
            FlowySvgs.m_empty_page_xl,
          ),
          const VSpace(16.0),
          FlowyText.medium(
            _emptyPageText,
            fontSize: 18.0,
            textAlign: TextAlign.center,
          ),
          const VSpace(8.0),
          FlowyText.regular(
            _emptyPageSubText,
            fontSize: 17.0,
            maxLines: 10,
            textAlign: TextAlign.center,
            lineHeight: 1.3,
            color: Theme.of(context).hintColor,
          ),
          const VSpace(kBottomNavigationBarHeight + 36.0),
        ],
      ),
    );
  }

  String get _emptyPageText => switch (type) {
        MobilePageCardType.recent => '没有最近页面',
        MobilePageCardType.favorite => '无收藏页面',
      };

  String get _emptyPageSubText => switch (type) {
        MobilePageCardType.recent =>
          '在你查看页面时，它们会出现在这里，方便检索。',
        MobilePageCardType.favorite =>
          '将页面收藏起来——它们会列在这里，方便快速访问！',
      };
}
