import 'package:appflowy_backend/protobuf/flowy-error/code.pb.dart';

extension PublishNameErrorCodeMap on ErrorCode {
  String? get publishErrorMessage {
    return switch (this) {
      ErrorCode.PublishNameAlreadyExists =>
        '该路径名称已被使用，请尝试其他路径名称',
      ErrorCode.PublishNameInvalidCharacter => '该路径名称包含无效的字符，请尝试其他的路径名称',
      ErrorCode.PublishNameTooLong =>
        '路径名称过长，请尝试其他路径名称',
      ErrorCode.UserUnauthorized =>
        '仅工作空间所有者或页面发布者可管理发布设置',
      ErrorCode.ViewNameInvalid =>
        '该路径名称不能为空，请尝试其他路径名称',
      _ => null,
    };
  }
}

extension DomainErrorCodeMap on ErrorCode {
  String? get namespaceErrorMessage {
    return switch (this) {
      ErrorCode.CustomNamespaceRequirePlanUpgrade =>
        '您需要升级至 Pro 方案以更新名称空间',
      ErrorCode.CustomNamespaceAlreadyTaken =>
        '该名称空间已被占用你，请尝试其他名称空间',
      ErrorCode.InvalidNamespace ||
      ErrorCode.InvalidRequest =>
        '无效的名称空间，请尝试其他的名称空间',
      ErrorCode.CustomNamespaceTooLong =>
        '该名称空间过长，请尝试其他名称空间',
      ErrorCode.CustomNamespaceTooShort =>
        '该名称空间过短，请尝试其他名称空间',
      ErrorCode.CustomNamespaceReserved =>
        '该名称空间已被占用，请尝试其他名称空间',
      ErrorCode.CustomNamespaceInvalidCharacter =>
        '该名称空间包含无效的字符，请尝试其他名称空间',
      _ => null,
    };
  }
}
