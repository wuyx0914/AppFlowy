import 'package:appflowy/mobile/presentation/base/app_bar/app_bar_actions.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flutter/material.dart';

const _height = 44.0;

class MobileDateHeader extends StatelessWidget {
  const MobileDateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AppBarCloseButton(),
          ),
          Align(
            child: FlowyText.medium(
              '日期',
              fontSize: 16,
            ),
          ),
        ].map((e) => SizedBox(height: _height, child: e)).toList(),
      ),
    );
  }
}
