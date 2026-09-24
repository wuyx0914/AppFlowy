import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/setting_entities.pbenum.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pbenum.dart';

extension DatabaseLayoutExtension on DatabaseLayoutPB {
  String get layoutName {
    return switch (this) {
      DatabaseLayoutPB.Board => '看板',
      DatabaseLayoutPB.Calendar => '日历',
      DatabaseLayoutPB.Grid => '网格',
      _ => "",
    };
  }

  ViewLayoutPB get layoutType {
    return switch (this) {
      DatabaseLayoutPB.Board => ViewLayoutPB.Board,
      DatabaseLayoutPB.Calendar => ViewLayoutPB.Calendar,
      DatabaseLayoutPB.Grid => ViewLayoutPB.Grid,
      _ => throw UnimplementedError(),
    };
  }

  FlowySvgData get icon {
    return switch (this) {
      DatabaseLayoutPB.Board => FlowySvgs.board_s,
      DatabaseLayoutPB.Calendar => FlowySvgs.calendar_s,
      DatabaseLayoutPB.Grid => FlowySvgs.grid_s,
      _ => throw UnimplementedError(),
    };
  }
}
