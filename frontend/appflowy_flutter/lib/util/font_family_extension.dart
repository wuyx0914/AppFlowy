import 'package:appflowy/shared/google_fonts_extension.dart';
import 'package:appflowy/shared/patterns/common_patterns.dart';
import 'package:appflowy/workspace/application/settings/appearance/base_appearance.dart';

extension FontFamilyExtension on String {
  String parseFontFamilyName() => replaceAll('_regular', '')
      .replaceAllMapped(camelCaseRegex, (m) => ' ${m.group(0)}');

  // display the default font name if the font family name is empty
  //  or using the default font family
  String get fontFamilyDisplayName => isEmpty || this == defaultFontFamily
      ? '系统'
      : parseFontFamilyName();

  // the font display name is not the same as the font family name
  // for example, the display name is "Noto Sans HK"
  // the font family name is "NotoSansHK_Regular"
  String get fontFamilyName => isEmpty || this == defaultFontFamily
      ? defaultFontFamily
      : getGoogleFontSafely(this).fontFamily ?? defaultFontFamily;
}
