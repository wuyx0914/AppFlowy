import 'dart:ui';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:protobuf/protobuf.dart';

extension FieldTypeExtension on FieldType {
  String get i18n => switch (this) {
        FieldType.RichText => '文本',
        FieldType.Number => '数字',
        FieldType.DateTime => '日期',
        FieldType.SingleSelect =>
          '单项选择器',
        FieldType.MultiSelect =>
          '多项选择器',
        FieldType.Checkbox => '勾选框',
        FieldType.Checklist => '清单',
        FieldType.URL => '链接',
        FieldType.LastEditedTime =>
          '修改时间',
        FieldType.CreatedTime => '创建时间',
        FieldType.Relation => '关系',
        FieldType.Summary => 'AI 总结',
        FieldType.Time => '时间',
        FieldType.Translate => 'AI 翻译',
        FieldType.Media => '文件和媒体',
        _ => throw UnimplementedError(),
      };

  FlowySvgData get svgData => switch (this) {
        FieldType.RichText => FlowySvgs.text_s,
        FieldType.Number => FlowySvgs.number_s,
        FieldType.DateTime => FlowySvgs.date_s,
        FieldType.SingleSelect => FlowySvgs.single_select_s,
        FieldType.MultiSelect => FlowySvgs.multiselect_s,
        FieldType.Checkbox => FlowySvgs.checkbox_s,
        FieldType.URL => FlowySvgs.url_s,
        FieldType.Checklist => FlowySvgs.checklist_s,
        FieldType.LastEditedTime => FlowySvgs.time_s,
        FieldType.CreatedTime => FlowySvgs.time_s,
        FieldType.Relation => FlowySvgs.relation_s,
        FieldType.Summary => FlowySvgs.ai_summary_s,
        FieldType.Time => FlowySvgs.timer_start_s,
        FieldType.Translate => FlowySvgs.ai_translate_s,
        FieldType.Media => FlowySvgs.media_s,
        _ => throw UnimplementedError(),
      };

  FlowySvgData? get rightIcon => switch (this) {
        FieldType.Summary => FlowySvgs.ai_indicator_s,
        FieldType.Translate => FlowySvgs.ai_indicator_s,
        _ => null,
      };

  Color get mobileIconBackgroundColor => switch (this) {
        FieldType.RichText => const Color(0xFFBECCFF),
        FieldType.Number => const Color(0xFFCABDFF),
        FieldType.URL => const Color(0xFFFFB9EF),
        FieldType.SingleSelect => const Color(0xFFBECCFF),
        FieldType.MultiSelect => const Color(0xFFBECCFF),
        FieldType.DateTime => const Color(0xFFFDEDA7),
        FieldType.LastEditedTime => const Color(0xFFFDEDA7),
        FieldType.CreatedTime => const Color(0xFFFDEDA7),
        FieldType.Checkbox => const Color(0xFF98F4CD),
        FieldType.Checklist => const Color(0xFF98F4CD),
        FieldType.Relation => const Color(0xFFFDEDA7),
        FieldType.Summary => const Color(0xFFBECCFF),
        FieldType.Time => const Color(0xFFFDEDA7),
        FieldType.Translate => const Color(0xFFBECCFF),
        FieldType.Media => const Color(0xFF91EBF5),
        _ => throw UnimplementedError(),
      };

  // TODO(RS): inner icon color isn't always white
  Color get mobileIconBackgroundColorDark => switch (this) {
        FieldType.RichText => const Color(0xFF6859A7),
        FieldType.Number => const Color(0xFF6859A7),
        FieldType.URL => const Color(0xFFA75C96),
        FieldType.SingleSelect => const Color(0xFF5366AB),
        FieldType.MultiSelect => const Color(0xFF5366AB),
        FieldType.DateTime => const Color(0xFFB0A26D),
        FieldType.LastEditedTime => const Color(0xFFB0A26D),
        FieldType.CreatedTime => const Color(0xFFB0A26D),
        FieldType.Checkbox => const Color(0xFF42AD93),
        FieldType.Checklist => const Color(0xFF42AD93),
        FieldType.Relation => const Color(0xFFFDEDA7),
        FieldType.Summary => const Color(0xFF6859A7),
        FieldType.Time => const Color(0xFFFDEDA7),
        FieldType.Translate => const Color(0xFF6859A7),
        FieldType.Media => const Color(0xFF91EBF5),
        _ => throw UnimplementedError(),
      };

  bool get canBeGroup => switch (this) {
        FieldType.URL ||
        FieldType.Checkbox ||
        FieldType.MultiSelect ||
        FieldType.SingleSelect ||
        FieldType.DateTime =>
          true,
        _ => false
      };

  bool get canCreateFilter => switch (this) {
        FieldType.Number ||
        FieldType.Checkbox ||
        FieldType.MultiSelect ||
        FieldType.RichText ||
        FieldType.SingleSelect ||
        FieldType.Checklist ||
        FieldType.URL ||
        FieldType.DateTime ||
        FieldType.CreatedTime ||
        FieldType.LastEditedTime =>
          true,
        _ => false
      };

  bool get canCreateSort => switch (this) {
        FieldType.RichText ||
        FieldType.Checkbox ||
        FieldType.Number ||
        FieldType.DateTime ||
        FieldType.SingleSelect ||
        FieldType.MultiSelect ||
        FieldType.LastEditedTime ||
        FieldType.CreatedTime ||
        FieldType.Checklist ||
        FieldType.URL ||
        FieldType.Time =>
          true,
        _ => false
      };

  bool get canEditHeader => switch (this) {
        FieldType.MultiSelect => true,
        FieldType.SingleSelect => true,
        _ => false,
      };

  bool get canCreateNewGroup => switch (this) {
        FieldType.MultiSelect => true,
        FieldType.SingleSelect => true,
        _ => false,
      };

  bool get canDeleteGroup => switch (this) {
        FieldType.URL ||
        FieldType.SingleSelect ||
        FieldType.MultiSelect ||
        FieldType.DateTime =>
          true,
        _ => false,
      };

  List<ProtobufEnum> get groupConditions {
    switch (this) {
      case FieldType.DateTime:
        return DateConditionPB.values;
      default:
        return [];
    }
  }
}
