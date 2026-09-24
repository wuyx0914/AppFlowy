import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/desktop_toolbar/link/link_hover_menu.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/desktop_toolbar/link/link_replace_menu.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/link_preview/shared.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/menu/menu_extension.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/widgets.dart';

import 'link_embed_block_component.dart';

class LinkEmbedMenu extends StatefulWidget {
  const LinkEmbedMenu({
    super.key,
    required this.node,
    required this.editorState,
    required this.onMenuShowed,
    required this.onMenuHided,
    required this.onReload,
  });

  final Node node;
  final EditorState editorState;
  final VoidCallback onMenuShowed;
  final VoidCallback onMenuHided;
  final VoidCallback onReload;

  @override
  State<LinkEmbedMenu> createState() => _LinkEmbedMenuState();
}

class _LinkEmbedMenuState extends State<LinkEmbedMenu> {
  final turnIntoController = PopoverController();
  final moreOptionController = PopoverController();
  int turnIntoMenuNum = 0, moreOptionNum = 0, alignMenuNum = 0;
  final moreOptionButtonKey = GlobalKey();
  bool get isTurnIntoShowing => turnIntoMenuNum > 0;
  bool get isMoreOptionShowing => moreOptionNum > 0;
  bool get isAlignMenuShowing => alignMenuNum > 0;

  Node get node => widget.node;
  EditorState get editorState => widget.editorState;
  bool get editable => editorState.editable;

  String get url => node.attributes[LinkPreviewBlockKeys.url] ?? '';

  @override
  void dispose() {
    super.dispose();
    turnIntoController.close();
    moreOptionController.close();
    widget.onMenuHided.call();
  }

  @override
  Widget build(BuildContext context) {
    return buildChild();
  }

  Widget buildChild() {
    final theme = AppFlowyTheme.of(context),
        iconScheme = theme.iconColorScheme,
        surfaceColorScheme = theme.surfaceColorScheme;

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: surfaceColorScheme.inverse,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FlowyIconButton(
          //   icon: FlowySvg(
          //     FlowySvgs.embed_fullscreen_m,
          //     color: iconScheme.tertiary,
          //   ),
          //   tooltipText: '全屏幕打开',
          //   preferBelow: false,
          //   onPressed: () {},
          // ),
          FlowyIconButton(
            icon: FlowySvg(
              FlowySvgs.toolbar_link_m,
              color: iconScheme.tertiary,
            ),
            radius: BorderRadius.all(Radius.circular(theme.borderRadius.m)),
            tooltipText: '复制链接',
            preferBelow: false,
            onPressed: () => copyLink(context),
          ),
          buildConvertButton(),
          buildMoreOptionButton(),
        ],
      ),
    );
  }

  Widget buildConvertButton() {
    final theme = AppFlowyTheme.of(context), iconScheme = theme.iconColorScheme;
    final button = FlowyIconButton(
      icon: FlowySvg(
        FlowySvgs.turninto_m,
        color: iconScheme.tertiary,
      ),
      radius: BorderRadius.all(Radius.circular(theme.borderRadius.m)),
      tooltipText: '转换为',
      preferBelow: false,
      onPressed: getTapCallback(showTurnIntoMenu),
    );
    if (!editable) return button;
    return AppFlowyPopover(
      offset: Offset(0, 6),
      direction: PopoverDirection.bottomWithRightAligned,
      margin: EdgeInsets.zero,
      controller: turnIntoController,
      onOpen: () {
        keepEditorFocusNotifier.increase();
        turnIntoMenuNum++;
      },
      onClose: () {
        keepEditorFocusNotifier.decrease();
        turnIntoMenuNum--;
        checkToHideMenu();
      },
      popupBuilder: (context) => buildConvertMenu(),
      child: button,
    );
  }

  Widget buildConvertMenu() {
    final types = LinkEmbedConvertCommand.values;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SeparatedColumn(
        mainAxisSize: MainAxisSize.min,
        separatorBuilder: () => const VSpace(0.0),
        children: List.generate(types.length, (index) {
          final command = types[index];
          return SizedBox(
            height: 36,
            child: FlowyButton(
              text: FlowyText(
                command.title,
                fontWeight: FontWeight.w400,
                figmaLineHeight: 20,
              ),
              onTap: () {
                if (command == LinkEmbedConvertCommand.toBookmark) {
                  final transaction = editorState.transaction;
                  transaction.updateNode(node, {
                    LinkPreviewBlockKeys.url: url,
                    LinkEmbedKeys.previewType: '',
                  });
                  editorState.apply(transaction);
                } else if (command == LinkEmbedConvertCommand.toMention) {
                  convertUrlPreviewNodeToMention(editorState, node);
                } else if (command == LinkEmbedConvertCommand.toURL) {
                  convertUrlPreviewNodeToLink(editorState, node);
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget buildMoreOptionButton() {
    final theme = AppFlowyTheme.of(context), iconScheme = theme.iconColorScheme;
    final button = FlowyIconButton(
      key: moreOptionButtonKey,
      icon: FlowySvg(
        FlowySvgs.toolbar_more_m,
        color: iconScheme.tertiary,
      ),
      radius: BorderRadius.all(Radius.circular(theme.borderRadius.m)),
      tooltipText: '更多选项',
      preferBelow: false,
      onPressed: getTapCallback(showMoreOptionMenu),
    );
    if (!editable) return button;
    return AppFlowyPopover(
      offset: Offset(0, 6),
      direction: PopoverDirection.bottomWithRightAligned,
      margin: EdgeInsets.zero,
      controller: moreOptionController,
      onOpen: () {
        keepEditorFocusNotifier.increase();
        moreOptionNum++;
      },
      onClose: () {
        keepEditorFocusNotifier.decrease();
        moreOptionNum--;
        checkToHideMenu();
      },
      popupBuilder: (context) => buildMoreOptionMenu(),
      child: button,
    );
  }

  Widget buildMoreOptionMenu() {
    final types = LinkEmbedMenuCommand.values;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SeparatedColumn(
        mainAxisSize: MainAxisSize.min,
        separatorBuilder: () => const VSpace(0.0),
        children: List.generate(types.length, (index) {
          final command = types[index];
          return SizedBox(
            height: 36,
            child: FlowyButton(
              text: FlowyText(
                command.title,
                fontWeight: FontWeight.w400,
                figmaLineHeight: 20,
              ),
              onTap: () => onEmbedMenuCommand(command),
            ),
          );
        }),
      ),
    );
  }

  void showTurnIntoMenu() {
    keepEditorFocusNotifier.increase();
    turnIntoController.show();
    checkToShowMenu();
    turnIntoMenuNum++;
    if (isMoreOptionShowing) closeMoreOptionMenu();
  }

  void closeTurnIntoMenu() {
    turnIntoController.close();
    checkToHideMenu();
  }

  void showMoreOptionMenu() {
    keepEditorFocusNotifier.increase();
    moreOptionController.show();
    checkToShowMenu();
    moreOptionNum++;
    if (isTurnIntoShowing) closeTurnIntoMenu();
  }

  void closeMoreOptionMenu() {
    moreOptionController.close();
    checkToHideMenu();
  }

  void checkToHideMenu() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (!mounted) return;
      if (!isAlignMenuShowing && !isMoreOptionShowing && !isTurnIntoShowing) {
        widget.onMenuHided.call();
      }
    });
  }

  void checkToShowMenu() {
    if (!isAlignMenuShowing && !isMoreOptionShowing && !isTurnIntoShowing) {
      widget.onMenuShowed.call();
    }
  }

  Future<void> copyLink(BuildContext context) async {
    await context.copyLink(url);
    widget.onMenuHided.call();
  }

  void onEmbedMenuCommand(LinkEmbedMenuCommand command) {
    switch (command) {
      case LinkEmbedMenuCommand.openLink:
        afLaunchUrlString(url, addingHttpSchemeWhenFailed: true);
        break;
      case LinkEmbedMenuCommand.replace:
        final box = moreOptionButtonKey.currentContext?.findRenderObject()
            as RenderBox?;
        if (box == null) return;
        final p = box.localToGlobal(Offset.zero);
        showReplaceMenu(
          context: context,
          editorState: editorState,
          node: node,
          url: url,
          ltrb: LTRB(left: p.dx - 330, top: p.dy),
          onReplace: (url) async {
            await convertLinkBlockToOtherLinkBlock(
              editorState,
              node,
              node.type,
              url: url,
            );
          },
        );
        break;
      case LinkEmbedMenuCommand.reload:
        widget.onReload.call();
        break;
      case LinkEmbedMenuCommand.removeLink:
        removeUrlPreviewLink(editorState, node);
        break;
    }
    closeMoreOptionMenu();
  }

  VoidCallback? getTapCallback(VoidCallback callback) {
    if (editable) return callback;
    return null;
  }
}

enum LinkEmbedMenuCommand {
  openLink,
  replace,
  reload,
  removeLink;

  String get title {
    switch (this) {
      case openLink:
        return '打开链接';
      case replace:
        return '替换';
      case reload:
        return '重新加载';
      case removeLink:
        return '移除链接';
    }
  }
}

enum LinkEmbedConvertCommand {
  toMention,
  toURL,
  toBookmark;

  String get title {
    switch (this) {
      case toMention:
        return '转换为提及';
      case toURL:
        return '转换为URL';
      case toBookmark:
        return '转换为书签';
    }
  }
}
