import 'package:appflowy_backend/protobuf/flowy-user/protobuf.dart';

extension AFRolePBExtension on AFRolePB {
  bool get isOwner => this == AFRolePB.Owner;

  bool get isMember => this == AFRolePB.Member;

  bool get canInvite => isOwner;

  bool get canDelete => isOwner;

  bool get canUpdate => isOwner;

  bool get canLeave => this != AFRolePB.Owner;

  String get description {
    switch (this) {
      case AFRolePB.Owner:
        return '所有者';
      case AFRolePB.Member:
        return '成员';
      case AFRolePB.Guest:
        return '访客';
    }
    throw UnimplementedError('Unknown role: $this');
  }
}
