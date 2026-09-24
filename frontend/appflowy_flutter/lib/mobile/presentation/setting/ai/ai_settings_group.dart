import 'package:appflowy/mobile/presentation/bottom_sheet/show_mobile_bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_group_widget.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_item_widget.dart';
import 'package:appflowy/mobile/presentation/setting/widgets/mobile_setting_trailing.dart';
import 'package:appflowy/mobile/presentation/widgets/flowy_option_tile.dart';
import 'package:appflowy/workspace/application/settings/ai/settings_ai_bloc.dart';
import 'package:appflowy_backend/protobuf/flowy-user/user_profile.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AiSettingsGroup extends StatelessWidget {
  const AiSettingsGroup({
    super.key,
    required this.userProfile,
    required this.workspaceId,
  });

  final UserProfilePB userProfile;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsAIBloc(
        userProfile,
        workspaceId,
      )..add(const SettingsAIEvent.started()),
      child: BlocBuilder<SettingsAIBloc, SettingsAIState>(
        builder: (context, state) {
          return MobileSettingGroup(
            groupTitle: 'AI 设置',
            settingItemList: [
              MobileSettingItem(
                name: '语言模型类别',
                trailing: MobileSettingTrailing(
                  text: state.availableModels?.selectedModel.name ?? "",
                ),
                onTap: () => _onLLMModelTypeTap(context, state),
              ),
              // enable AI search if needed
              // MobileSettingItem(
              //   name: 'AI 搜索',
              //   trailing: const Icon(
              //     Icons.chevron_right,
              //   ),
              //   onTap: () => context.push(AppFlowyCloudPage.routeName),
              // ),
            ],
          );
        },
      ),
    );
  }

  void _onLLMModelTypeTap(BuildContext context, SettingsAIState state) {
    final availableModels = state.availableModels;
    showMobileBottomSheet(
      context,
      showHeader: true,
      showDragHandle: true,
      showDivider: false,
      title: '语言模型类别',
      builder: (_) {
        return Column(
          children: (availableModels?.models ?? [])
              .asMap()
              .entries
              .map(
                (entry) => FlowyOptionTile.checkbox(
                  text: entry.value.name,
                  showTopBorder: entry.key == 0,
                  isSelected:
                      availableModels?.selectedModel.name == entry.value.name,
                  onTap: () {
                    context
                        .read<SettingsAIBloc>()
                        .add(SettingsAIEvent.selectModel(entry.value));
                    context.pop();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}
