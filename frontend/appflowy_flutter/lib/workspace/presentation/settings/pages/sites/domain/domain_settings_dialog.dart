import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/shared/share/constants.dart';
import 'package:appflowy/plugins/shared/share/publish_color_extension.dart';
import 'package:appflowy/shared/error_code/error_code_map.dart';
import 'package:appflowy/util/string_extension.dart';
import 'package:appflowy/workspace/presentation/settings/pages/sites/settings_sites_bloc.dart';
import 'package:appflowy/workspace/presentation/widgets/dialogs.dart';
import 'package:appflowy_backend/log.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DomainSettingsDialog extends StatefulWidget {
  const DomainSettingsDialog({
    super.key,
    required this.namespace,
  });

  final String namespace;

  @override
  State<DomainSettingsDialog> createState() => _DomainSettingsDialogState();
}

class _DomainSettingsDialogState extends State<DomainSettingsDialog> {
  final focusNode = FocusNode();
  final controller = TextEditingController();
  late final controllerText = ValueNotifier<String>(widget.namespace);
  String errorHintText = '';

  @override
  void initState() {
    super.initState();

    controller.text = widget.namespace;
    controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => controllerText.value = controller.text;

  @override
  void dispose() {
    focusNode.dispose();
    controller.removeListener(_onTextChanged);
    controller.dispose();
    controllerText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsSitesBloc, SettingsSitesState>(
      listener: _onListener,
      child: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const VSpace(12),
              _buildNamespaceDescription(),
              const VSpace(20),
              _buildNamespaceTextField(),
              _buildPreviewNamespace(),
              _buildErrorHintText(),
              const VSpace(20),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        FlowyText(
          '更新现有的名称空间',
          fontSize: 16.0,
          figmaLineHeight: 22.0,
          fontWeight: FontWeight.w500,
          overflow: TextOverflow.ellipsis,
        ),
        const HSpace(6.0),
        FlowyTooltip(
          message: '我们保留删除任何不当命名空间的权利',
          child: const FlowySvg(FlowySvgs.information_s),
        ),
        const HSpace(6.0),
        const Spacer(),
        FlowyButton(
          margin: const EdgeInsets.all(3),
          useIntrinsicWidth: true,
          text: const FlowySvg(
            FlowySvgs.upgrade_close_s,
            size: Size.square(18.0),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildNamespaceDescription() {
    return FlowyText(
      '此变更将适用于此命名空间中所有已发布的页面',
      fontSize: 14.0,
      color: Theme.of(context).hintColor,
      figmaLineHeight: 16.0,
      maxLines: 3,
    );
  }

  Widget _buildNamespaceTextField() {
    return SizedBox(
      height: 36,
      child: FlowyTextField(
        autoFocus: false,
        controller: controller,
        enableBorderColor: ShareMenuColors.borderColor(context),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedRoundedButton(
          text: '取消',
          onTap: () => Navigator.of(context).pop(),
        ),
        const HSpace(12.0),
        PrimaryRoundedButton(
          text: '保存',
          radius: 8.0,
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 9.0,
          ),
          onTap: _onSave,
        ),
      ],
    );
  }

  Widget _buildErrorHintText() {
    if (errorHintText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 2.0),
      child: FlowyText(
        errorHintText,
        fontSize: 12.0,
        figmaLineHeight: 18.0,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget _buildPreviewNamespace() {
    return ValueListenableBuilder<String>(
      valueListenable: controllerText,
      builder: (context, value, child) {
        final url = ShareConstants.buildNamespaceUrl(
          nameSpace: value,
        );
        return Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 2.0),
          child: Opacity(
            opacity: 0.8,
            child: FlowyText(
              url,
              fontSize: 14.0,
              figmaLineHeight: 18.0,
              withTooltip: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  void _onSave() {
    // listen on the result
    context
        .read<SettingsSitesBloc>()
        .add(SettingsSitesEvent.updateNamespace(controller.text));
  }

  void _onListener(BuildContext context, SettingsSitesState state) {
    final actionResult = state.actionResult;
    final type = actionResult?.actionType;
    final result = actionResult?.result;
    if (type != SettingsSitesActionType.updateNamespace || result == null) {
      return;
    }

    result.fold(
      (s) {
        showToastNotification(
          message: '更新名称空间成功',
        );

        Navigator.of(context).pop();
      },
      (f) {
        final basicErrorMessage =
            '更新名称空间失败';
        final errorMessage = f.code.namespaceErrorMessage;

        setState(() {
          errorHintText = errorMessage.orDefault(basicErrorMessage);
        });

        Log.error('Failed to update namespace: $f');

        showToastNotification(
          message: basicErrorMessage,
          type: ToastificationType.error,
          description: errorMessage,
        );
      },
    );
  }
}
