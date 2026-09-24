import 'package:appflowy/ai/ai.dart';
import 'package:appflowy_backend/protobuf/flowy-ai/entities.pb.dart';
import 'package:flutter/material.dart';

import 'package:appflowy/workspace/application/settings/ai/settings_ai_bloc.dart';
import 'package:appflowy/workspace/presentation/settings/shared/af_dropdown_menu_entry.dart';
import 'package:appflowy/workspace/presentation/settings/shared/settings_dropdown.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AIModelSelection extends StatelessWidget {
  const AIModelSelection({super.key});
  static const double height = 49;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsAIBloc, SettingsAIState>(
      builder: (context, state) {
        final models = state.availableModels?.models;
        if (models == null) {
          return const SizedBox(
            // Using same height as SettingsDropdown to avoid layout shift
            height: height,
          );
        }

        final localModels = models.where((model) => model.isLocal).toList();
        final cloudModels = models.where((model) => !model.isLocal).toList();
        final selectedModel = state.availableModels!.selectedModel;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: FlowyText.medium(
                  '语言模型类别',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: SettingsDropdown<AIModelPB>(
                  key: ValueKey(selectedModel.name),
                  onChanged: (model) => context
                      .read<SettingsAIBloc>()
                      .add(SettingsAIEvent.selectModel(model)),
                  selectedOption: selectedModel,
                  selectOptionCompare: (left, right) =>
                      left?.name == right?.name,
                  options: [...localModels, ...cloudModels]
                      .map(
                        (model) => buildDropdownMenuEntry<AIModelPB>(
                          context,
                          value: model,
                          label:
                              model.isLocal ? "${model.i18n} 🔐" : model.i18n,
                          subLabel: model.desc,
                          maximumHeight: height,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
