import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/util/theme_extension.dart';
import 'package:appflowy/workspace/application/settings/ai/local_ai_bloc.dart';
import 'package:appflowy_backend/protobuf/flowy-ai/protobuf.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalAIStatusIndicator extends StatelessWidget {
  const LocalAIStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAiPluginBloc, LocalAiPluginState>(
      builder: (context, state) {
        return state.maybeWhen(
          ready: (_, isReady, lackOfResource) {
            if (lackOfResource != null) {
              return _LackOfResource(resource: lackOfResource);
            }

            return switch (isReady) {
              true => const _LocalAIRunning(),
              false => const _RestartPluginButton(),
            };
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _RestartPluginButton extends StatelessWidget {
  const _RestartPluginButton();

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).isLightMode
            ? const Color(0x80FFE7EE)
            : const Color(0x80591734),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const FlowySvg(
            FlowySvgs.toast_error_filled_s,
            size: Size.square(20.0),
            blendMode: null,
          ),
          const HSpace(8),
          Expanded(
            child: RichText(
              maxLines: 3,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '启动本地 AI 失败。',
                    style: textStyle,
                  ),
                  TextSpan(
                    text: ' ',
                    style: textStyle,
                  ),
                  TextSpan(
                    text: '重新启动',
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context
                            .read<LocalAiPluginBloc>()
                            .add(const LocalAiPluginEvent.restart());
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalAIRunning extends StatelessWidget {
  const _LocalAIRunning();

  @override
  Widget build(BuildContext context) {
    final runningText = '本地 AI 正在运行中';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEDF7ED),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const FlowySvg(
            FlowySvgs.download_success_s,
            color: Color(0xFF2E7D32),
          ),
          const HSpace(6),
          Expanded(
            child: FlowyText(
              runningText,
              color: const Color(0xFF1E4620),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LackOfResource extends StatelessWidget {
  const _LackOfResource({required this.resource});

  final LackOfAIResourcePB resource;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).isLightMode
            ? const Color(0x80FFE7EE)
            : const Color(0x80591734),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          FlowySvg(
            FlowySvgs.toast_error_filled_s,
            size: const Size.square(20.0),
            blendMode: null,
          ),
          const HSpace(8),
          Expanded(
            child: switch (resource.resourceType) {
              LackOfAIResourceTypePB.PluginExecutableNotReady =>
                _buildNoLAI(context),
              LackOfAIResourceTypePB.OllamaServerNotReady =>
                _buildNoOllama(context),
              LackOfAIResourceTypePB.MissingModel =>
                _buildNoModel(context, resource.missingModelNames),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  TextStyle? _textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
  }

  Widget _buildNoLAI(BuildContext context) {
    final textStyle = _textStyle(context);
    return RichText(
      maxLines: 3,
      text: TextSpan(
        children: [
          TextSpan(
            text: '本地 AI 应用程序未正确安装。',
            style: textStyle,
          ),
          TextSpan(text: ' ', style: _textStyle(context)),
          ..._downloadInstructions(textStyle),
        ],
      ),
    );
  }

  Widget _buildNoOllama(BuildContext context) {
    final textStyle = _textStyle(context);
    return RichText(
      maxLines: 3,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Ollama 服务器尚未就绪。',
            style: textStyle,
          ),
          TextSpan(text: ' ', style: textStyle),
          ..._downloadInstructions(textStyle),
        ],
      ),
    );
  }

  Widget _buildNoModel(BuildContext context, List<String> modelNames) {
    final textStyle = _textStyle(context);

    return RichText(
      maxLines: 3,
      text: TextSpan(
        children: [
          TextSpan(
            text: '找不到所需的模型:',
            style: textStyle,
          ),
          TextSpan(
            text: modelNames.join(', '),
            style: textStyle,
          ),
          TextSpan(
            text: ' ',
            style: textStyle,
          ),
          TextSpan(
            text: '请依照这些...',
            style: textStyle,
          ),
          TextSpan(
            text: ' ',
            style: textStyle,
          ),
          TextSpan(
            text: '指示',
            style: textStyle,
          ),
          TextSpan(
            text: ' ',
            style: textStyle,
          ),
          TextSpan(
            text: '以下载它们。',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  List<TextSpan> _downloadInstructions(TextStyle? textStyle) {
    return [
      TextSpan(
        text: '请依照这些...',
        style: textStyle,
      ),
      TextSpan(
        text: ' ',
        style: textStyle,
      ),
      TextSpan(
            text: '指示',
            style: textStyle,
          ),
      TextSpan(text: ' ', style: textStyle),
      TextSpan(
        text: '来设置 Ollama 和 AppFlowy 本地 AI。',
        style: textStyle,
      ),
    ];
  }
}
