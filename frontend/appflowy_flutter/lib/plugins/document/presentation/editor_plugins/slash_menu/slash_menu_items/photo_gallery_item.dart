import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/image_placeholder.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'slash_menu_items.dart';

final _keywords = [
  '图像',
  '图片库',
  '照片',
  '照片浏览器',
  '图库',
];

// photo gallery menu item
SelectionMenuItem photoGallerySlashMenuItem = SelectionMenuItem(
  getName: () => '图片库',
  keywords: _keywords,
  handler: (editorState, _, __) async => editorState.insertPhotoGalleryBlock(),
  nameBuilder: slashMenuItemNameBuilder,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_photo_gallery_s,
    isSelected: isSelected,
    style: style,
  ),
);

extension on EditorState {
  Future<void> insertPhotoGalleryBlock() async {
    final imagePlaceholderKey = GlobalKey<ImagePlaceholderState>();
    await insertEmptyMultiImageBlock(imagePlaceholderKey);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => imagePlaceholderKey.currentState?.controller.show(),
    );
  }
}
