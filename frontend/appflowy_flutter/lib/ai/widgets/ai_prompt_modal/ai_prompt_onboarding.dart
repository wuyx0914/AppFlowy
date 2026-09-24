import 'package:appflowy/ai/ai.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_prompt_database_modal.dart';

class AiPromptOnboarding extends StatelessWidget {
  const AiPromptOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '自订提示',
          style: theme.textStyle.heading3.standard(
            color: theme.textColorScheme.primary,
          ),
        ),
        VSpace(
          theme.spacing.s,
        ),
        Text(
          '从您自己的数据库加载提示',
          style: theme.textStyle.body.standard(
            color: theme.textColorScheme.secondary,
          ),
        ),
        VSpace(
          theme.spacing.xxl,
        ),
        AFFilledButton.primary(
          onTap: () async {
            final config = await changeCustomPromptDatabaseConfig(context);

            if (config != null && context.mounted) {
              context
                  .read<AiPromptSelectorCubit>()
                  .updateCustomPromptDatabaseConfiguration(config);
            }
          },
          builder: (context, isHovering, disabled) {
            return Text(
              '选择数据库',
              style: theme.textStyle.body.enhanced(
                color: theme.textColorScheme.onFill,
              ),
            );
          },
        ),
      ],
    );
  }
}
