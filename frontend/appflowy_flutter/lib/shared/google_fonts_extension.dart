import 'package:appflowy/workspace/application/settings/appearance/base_appearance.dart';
import 'package:flutter/material.dart';

const _defaultFontFamilies = [
  defaultFontFamily,
  builtInCodeFontFamily,
];

// Local-only build: never fetch fonts from Google Fonts service.
// If the font family is not built-in, fall back to the system font.
TextStyle getGoogleFontSafely(
  String fontFamily, {
  FontWeight? fontWeight,
  double? fontSize,
  Color? fontColor,
  double? letterSpacing,
  double? lineHeight,
}) {
  if (_defaultFontFamilies.contains(fontFamily)) {
    return TextStyle(
      fontFamily: fontFamily.isEmpty ? null : fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: fontColor,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );
  }

  return TextStyle(
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: fontColor,
    letterSpacing: letterSpacing,
    height: lineHeight,
  );
}
