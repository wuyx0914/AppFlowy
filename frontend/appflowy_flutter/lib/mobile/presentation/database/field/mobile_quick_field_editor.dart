import 'package:flutter/material.dart';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/database/card/card_detail/widgets/widgets.dart';
import 'package:appflowy/mobile/presentation/database/field/mobile_field_bottom_sheets.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:appflowy/plugins/database/application/field/field_controller.dart';
import 'package:appflowy/plugins/database/application/field/field_editor_bloc.dart';
import 'package:appflowy/plugins/database/application/field/field_info.dart';
import 'package:appflowy/plugins/database/domain/field_backend_service.dart';
import 'package:appflowy/plugins/database/widgets/setting/field_visibility_extension.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class QuickEditField extends StatefulWidget {
  const QuickEditField({
    super.key,
    required this.viewId,
    required this.fieldController,
    required this.fieldInfo,
  });

  final String viewId;
  final FieldController fieldController;
  final FieldInfo fieldInfo;

  @override
  State<QuickEditField> createState() => _QuickEditFieldState();
}

class _QuickEditFieldState extends State<QuickEditField> {
  final TextEditingController controller = TextEditingController();

  late final FieldServices service = FieldServices(
    viewId: widget.viewId,
    fieldId: widget.fieldInfo.field.id,
  );

  late FieldVisibility fieldVisibility;

  @override
  void initState() {
    super.initState();
    fieldVisibility =
        widget.fieldInfo.visibility ?? FieldVisibility.AlwaysShown;
    controller.text = widget.fieldInfo.field.name;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FieldEditorBloc(
        viewId: widget.viewId,
        fieldController: widget.fieldController,
        fieldInfo: widget.fieldInfo,
        isNew: false,
      ),
      child: BlocConsumer<FieldEditorBloc, FieldEditorState>(
        listenWhen: (previous, current) =>
            previous.field.name != current.field.name,
        listener: (context, state) => controller.text = state.field.name,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VSpace(16),
              OptionTextField(
                controller: controller,
                isPrimary: state.field.isPrimary,
                fieldType: state.field.fieldType,
                onTextChanged: (text) {
                  context
                      .read<FieldEditorBloc>()
                      .add(FieldEditorEvent.renameField(text));
                },
                onFieldTypeChanged: (fieldType) {
                  context
                      .read<FieldEditorBloc>()
                      .add(FieldEditorEvent.switchFieldType(fieldType));
                },
              ),
              const _Divider(),
              FlowyOptionTile.text(
                text: '编辑列属性',
                leftIcon: const FlowySvg(FlowySvgs.m_field_edit_s),
                onTap: () {
                  showEditFieldScreen(
                    context,
                    widget.viewId,
                    state.field,
                  );
                  context.pop();
                },
              ),
              if (!widget.fieldInfo.isPrimary) ...[
                FlowyOptionTile.text(
                  showTopBorder: false,
                  text: fieldVisibility.isVisibleState()
                      ? '隐藏'
                      : '展示',
                  leftIcon: const FlowySvg(FlowySvgs.m_field_hide_s),
                  onTap: () async {
                    context.pop();
                    if (fieldVisibility.isVisibleState()) {
                      await service.hide();
                    } else {
                      await service.hide();
                    }
                  },
                ),
                FlowyOptionTile.text(
                  showTopBorder: false,
                  text: '左侧插入',
                  leftIcon: const FlowySvg(FlowySvgs.m_filed_insert_left_s),
                  onTap: () {
                    context.pop();
                    mobileCreateFieldWorkflow(
                      context,
                      widget.viewId,
                      position: OrderObjectPositionPB(
                        position: OrderObjectPositionTypePB.Before,
                        objectId: widget.fieldInfo.id,
                      ),
                    );
                  },
                ),
              ],
              FlowyOptionTile.text(
                showTopBorder: false,
                text: '右侧插入',
                leftIcon: const FlowySvg(FlowySvgs.m_filed_insert_right_s),
                onTap: () {
                  context.pop();
                  mobileCreateFieldWorkflow(
                    context,
                    widget.viewId,
                    position: OrderObjectPositionPB(
                      position: OrderObjectPositionTypePB.After,
                      objectId: widget.fieldInfo.id,
                    ),
                  );
                },
              ),
              if (!widget.fieldInfo.isPrimary) ...[
                FlowyOptionTile.text(
                  showTopBorder: false,
                  text: '复制',
                  leftIcon: const FlowySvg(FlowySvgs.m_field_copy_s),
                  onTap: () {
                    context.pop();
                    service.duplicate();
                  },
                ),
                FlowyOptionTile.text(
                  showTopBorder: false,
                  text: '删除',
                  textColor: Theme.of(context).colorScheme.error,
                  leftIcon: FlowySvg(
                    FlowySvgs.m_field_delete_s,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () {
                    context.pop();
                    service.delete();
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const VSpace(20);
  }
}
