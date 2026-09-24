import 'package:flutter/material.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:flowy_infra/theme_extension.dart';
import 'package:flowy_infra_ui/style_widget/icon_button.dart';
import 'package:flowy_infra_ui/widget/flowy_tooltip.dart';

import 'layout_define.dart';

class PromptInputAttachmentButton extends StatelessWidget {
  const PromptInputAttachmentButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: '上传聊天使用的 PDF、md 或 txt 文件',
      child: SizedBox.square(
        dimension: DesktopAIPromptSizes.actionBarButtonSize,
        child: FlowyIconButton(
          hoverColor: AFThemeExtension.of(context).lightGreyHover,
          radius: BorderRadius.circular(8),
          icon: FlowySvg(
            FlowySvgs.ai_attachment_s,
            size: const Size.square(16),
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class PromptInputMentionButton extends StatelessWidget {
  const PromptInputMentionButton({
    super.key,
    required this.buttonSize,
    required this.iconSize,
    required this.onTap,
  });

  final double buttonSize;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: '点击以提及页面',
      preferBelow: false,
      child: FlowyIconButton(
        width: buttonSize,
        hoverColor: AFThemeExtension.of(context).lightGreyHover,
        radius: BorderRadius.circular(8),
        icon: FlowySvg(
          FlowySvgs.chat_at_s,
          size: Size.square(iconSize),
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: onTap,
      ),
    );
  }
}
