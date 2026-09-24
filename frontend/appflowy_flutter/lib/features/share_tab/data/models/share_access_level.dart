import 'package:appflowy/generated/flowy_svgs.g.dart';

/// The access level a user can have on a shared page.
enum ShareAccessLevel {
  /// Can view the page only.
  readOnly,

  /// Can read and comment on the page.
  readAndComment,

  /// Can read and write to the page.
  readAndWrite,

  /// Full access (edit, share, remove, etc.) and can add new users.
  fullAccess;

  String get title {
    switch (this) {
      case ShareAccessLevel.readOnly:
        return '查看';
      case ShareAccessLevel.readAndComment:
        return '评论';
      case ShareAccessLevel.readAndWrite:
        return '编辑';
      case ShareAccessLevel.fullAccess:
        return '完全访问权限';
    }
  }

  String get subtitle {
    switch (this) {
      case ShareAccessLevel.readOnly:
        return '无法进行变更';
      case ShareAccessLevel.readAndComment:
        return '可以进行任何变更';
      case ShareAccessLevel.readAndWrite:
        return '可以进行任何变更';
      case ShareAccessLevel.fullAccess:
        return '可以进行任何变更';
    }
  }

  FlowySvgData get icon {
    switch (this) {
      case ShareAccessLevel.readOnly:
        return FlowySvgs.access_level_view_m;
      case ShareAccessLevel.readAndComment:
        return FlowySvgs.access_level_edit_m;
      case ShareAccessLevel.readAndWrite:
        return FlowySvgs.access_level_edit_m;
      case ShareAccessLevel.fullAccess:
        return FlowySvgs.access_level_edit_m;
    }
  }
}
