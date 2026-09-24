import 'dart:io';

import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

// used to prevent loading font from google fonts every time
List<String>? _cachedFallbackFontFamily;

// Some emojis are not supported by the default font on Android or Linux, fallback to noto color emoji
class EmojiText extends StatelessWidget {
  const EmojiText({
    super.key,
    required this.emoji,
    required this.fontSize,
    this.textAlign,
    this.lineHeight,
  });

  final String emoji;
  final double fontSize;
  final TextAlign? textAlign;
  final double? lineHeight;

  @override
  Widget build(BuildContext context) {
    _loadFallbackFontFamily();
    return FlowyText(
      emoji,
      fontSize: fontSize,
      textAlign: textAlign,
      strutStyle: const StrutStyle(forceStrutHeight: true),
      fallbackFontFamily: _cachedFallbackFontFamily,
      lineHeight: lineHeight,
      isEmoji: true,
    );
  }

  void _loadFallbackFontFamily() {
    // Local-only build: rely on the system emoji font instead of Google Fonts.
    if (Platform.isLinux) {
      _cachedFallbackFontFamily = ['Noto Color Emoji'];
    }
  }
}
