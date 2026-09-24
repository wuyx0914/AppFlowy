import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/database/view/database_filter_condition_list.dart';
import 'package:appflowy/plugins/database/application/field/filter_entities.dart';
import 'package:appflowy/plugins/database/grid/presentation/widgets/filter/condition_button.dart';
import 'package:appflowy/workspace/presentation/widgets/pop_up_action.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:appflowy_popover/appflowy_popover.dart';
import 'package:flutter/widgets.dart';

class SelectOptionFilterConditionList extends StatelessWidget {
  const SelectOptionFilterConditionList({
    super.key,
    required this.filter,
    required this.fieldType,
    required this.popoverMutex,
    required this.onCondition,
  });

  final SelectOptionFilter filter;
  final FieldType fieldType;
  final PopoverMutex popoverMutex;
  final void Function(SelectOptionFilterConditionPB) onCondition;

  @override
  Widget build(BuildContext context) {
    final conditions = (fieldType == FieldType.SingleSelect
        ? SingleSelectOptionFilterCondition().conditions
        : MultiSelectOptionFilterCondition().conditions);
    return PopoverActionList<ConditionWrapper>(
      asBarrier: true,
      mutex: popoverMutex,
      direction: PopoverDirection.bottomWithCenterAligned,
      actions: conditions
          .map(
            (action) => ConditionWrapper(
              action.$1,
              filter.condition == action.$1,
            ),
          )
          .toList(),
      buildChild: (controller) {
        return ConditionButton(
          conditionName: filter.condition.i18n,
          onTap: () => controller.show(),
        );
      },
      onSelected: (action, controller) async {
        onCondition(action.inner);
        controller.close();
      },
    );
  }
}

class ConditionWrapper extends ActionCell {
  ConditionWrapper(this.inner, this.isSelected);

  final SelectOptionFilterConditionPB inner;
  final bool isSelected;

  @override
  Widget? rightIcon(Color iconColor) {
    return isSelected ? const FlowySvg(FlowySvgs.check_s) : null;
  }

  @override
  String get name => inner.i18n;
}

extension SelectOptionFilterConditionPBExtension
    on SelectOptionFilterConditionPB {
  String get i18n {
    return switch (this) {
      SelectOptionFilterConditionPB.OptionIs =>
        '是',
      SelectOptionFilterConditionPB.OptionIsNot =>
        '不是',
      SelectOptionFilterConditionPB.OptionContains =>
        '包含',
      SelectOptionFilterConditionPB.OptionDoesNotContain =>
        '不含',
      SelectOptionFilterConditionPB.OptionIsEmpty =>
        '为空',
      SelectOptionFilterConditionPB.OptionIsNotEmpty =>
        '不为空',
      _ => "",
    };
  }
}
