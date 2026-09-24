import 'package:flutter/material.dart';

extension LabelTextPhrasing on ThemeMode {
  String get labelText => switch (this) {
        ThemeMode.light => '日间模式',
        ThemeMode.dark => '夜间模式',
        ThemeMode.system =>
          '系统自适应',
      };
}
