import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';

extension CalcTypeLabel on CalculationType {
  String get label => switch (this) {
        CalculationType.Average =>
          '平均的',
        CalculationType.Max => '最大限度',
        CalculationType.Median =>
          '中位数',
        CalculationType.Min => '分钟',
        CalculationType.Sum => '和',
        CalculationType.Count =>
          '计数',
        CalculationType.CountEmpty =>
          '计数为空',
        CalculationType.CountNonEmpty =>
          '计数不为空',
        _ => throw UnimplementedError(
            'Label for $this has not been implemented',
          ),
      };

  String get shortLabel => switch (this) {
        CalculationType.CountEmpty =>
          '空的',
        CalculationType.CountNonEmpty =>
          '已满',
        _ => label,
      };
}
