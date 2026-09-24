import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';

class AFPasswordErrorExtension {
  static final RegExp incorrectPasswordPattern =
      RegExp('Incorrect current password');
  static final RegExp tooShortPasswordPattern =
      RegExp(r'Password should be at least (\d+) characters');
  static final RegExp tooLongPasswordPattern =
      RegExp(r'Password cannot be longer than (\d+) characters');

  static String getErrorMessage(FlowyError error) {
    final msg = error.msg;
    if (incorrectPasswordPattern.hasMatch(msg)) {
      return '目前的密码错误';
    } else if (tooShortPasswordPattern.hasMatch(msg)) {
      return '密码至少应有 ${tooShortPasswordPattern.firstMatch(msg)?.group(1) ?? '6'} 个字符';
    } else if (tooLongPasswordPattern.hasMatch(msg)) {
      return '密码不能长于 ${tooLongPasswordPattern.firstMatch(msg)?.group(1) ?? '72'} 个字符';
    }

    return msg;
  }
}
