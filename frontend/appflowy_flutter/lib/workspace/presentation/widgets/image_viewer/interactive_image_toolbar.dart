import 'dart:convert';
import 'dart:io';

import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/common.dart';
import 'package:appflowy_backend/protobuf/flowy-user/user_profile.pb.dart';
import 'package:flowy_infra/file_picker/file_picker_impl.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/style_widget/hover.dart';
import 'package:flowy_infra_ui/style_widget/snap_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:universal_platform/universal_platform.dart';

class InteractiveImageToolbar extends StatelessWidget {
  const InteractiveImageToolbar({
    super.key,
    required this.currentImage,
    required this.imageCount,
    required this.isFirstIndex,
    required this.isLastIndex,
    required this.currentScale,
    required this.onPrevious,
    required this.onNext,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onScaleChanged,
    this.onDelete,
    this.userProfile,
  });

  final ImageBlockData currentImage;
  final int imageCount;
  final bool isFirstIndex;
  final bool isLastIndex;
  final int currentScale;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final Function(double scale) onScaleChanged;
  final UserProfilePB? userProfile;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageCount > 1)
                _renderToolbarItems(
                  children: [
                    _ToolbarItem(
                      isDisabled: isFirstIndex,
                      tooltip: '上一张图片',
                      icon: FlowySvgs.arrow_left_s,
                      onTap: () {
                        if (!isFirstIndex) {
                          onPrevious();
                        }
                      },
                    ),
                    _ToolbarItem(
                      isDisabled: isLastIndex,
                      tooltip: '下一张图片',
                      icon: FlowySvgs.arrow_right_s,
                      onTap: () {
                        if (!isLastIndex) {
                          onNext();
                        }
                      },
                    ),
                  ],
                ),
              const HSpace(10),
              _renderToolbarItems(
                children: [
                  _ToolbarItem(
                    tooltip: '缩小',
                    icon: FlowySvgs.minus_s,
                    onTap: onZoomOut,
                  ),
                  AppFlowyPopover(
                    offset: const Offset(0, -8),
                    decorationColor: Colors.transparent,
                    direction: PopoverDirection.topWithCenterAligned,
                    constraints: const BoxConstraints(maxHeight: 50),
                    popupBuilder: (context) => _renderToolbarItems(
                      children: [
                        _ScaleSlider(
                          currentScale: currentScale,
                          onScaleChanged: onScaleChanged,
                        ),
                      ],
                    ),
                    child: FlowyTooltip(
                      message: '更改缩放级别',
                      child: FlowyHover(
                        resetHoverOnRebuild: false,
                        style: HoverStyle(
                          hoverColor: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: SizedBox(
                            width: 40,
                            child: Center(
                              child: FlowyText(
                                '{currentScale.toString()}%',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _ToolbarItem(
                    tooltip: '放大',
                    icon: FlowySvgs.add_s,
                    onTap: onZoomIn,
                  ),
                ],
              ),
              const HSpace(10),
              _renderToolbarItems(
                children: [
                  if (onDelete != null)
                    _ToolbarItem(
                      tooltip: '删除图片',
                      icon: FlowySvgs.delete_s,
                      onTap: () {
                        onDelete!();
                        Navigator.of(context).pop();
                      },
                    ),
                  if (!UniversalPlatform.isMobile) ...[
                    _ToolbarItem(
                      tooltip: currentImage.isNotInternal
                          ? '打开图片'
                          : '下载图片',
                      icon: currentImage.isNotInternal
                          ? currentImage.isLocal
                              ? FlowySvgs.folder_m
                              : FlowySvgs.m_aa_link_s
                          : FlowySvgs.download_s,
                      onTap: () => _locateOrDownloadImage(context),
                    ),
                  ],
                ],
              ),
              const HSpace(10),
              _renderToolbarItems(
                children: [
                  _ToolbarItem(
                    tooltip: '关闭交互式查看器',
                    icon: FlowySvgs.close_viewer_s,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderToolbarItems({required List<Widget> children}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black.withValues(alpha: 0.6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SeparatedRow(
          mainAxisSize: MainAxisSize.min,
          separatorBuilder: () => const HSpace(4),
          children: children,
        ),
      ),
    );
  }

  Future<void> _locateOrDownloadImage(BuildContext context) async {
    if (currentImage.isLocal || currentImage.isNotInternal) {
      /// If the image type is local, we simply open the image
      ///
      /// // In case of eg. Unsplash images (images without extension type in URL),
      // we don't know their mimetype. In the future we can write a parser
      // using the Mime package and read the image to get the proper extension.
      await afLaunchUrlString(currentImage.url);
    } else {
      if (userProfile == null) {
        return showSnapBar(
          context,
          '图片下载因缺少用户凭证而失败，请再试一次\n',
        );
      }

      final uri = Uri.parse(currentImage.url);
      final imgFile = File(uri.pathSegments.last);
      final savePath = await FilePicker().saveFile(
        fileName: basename(imgFile.path),
      );

      if (savePath != null) {
        final uri = Uri.parse(currentImage.url);

        final token = jsonDecode(userProfile!.token)['access_token'];
        final response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final imgFile = File(savePath);
          await imgFile.writeAsBytes(response.bodyBytes);
        } else if (context.mounted) {
          showSnapBar(
            context,
            '图片下载失败，请再试一次',
          );
        }
      }
    }
  }
}

class _ToolbarItem extends StatelessWidget {
  const _ToolbarItem({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  final String tooltip;
  final FlowySvgData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: FlowyTooltip(
        message: tooltip,
        child: FlowyHover(
          resetHoverOnRebuild: false,
          style: HoverStyle(
            hoverColor: isDisabled
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(8),
            child: FlowySvg(
              icon,
              color: isDisabled ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleSlider extends StatefulWidget {
  const _ScaleSlider({
    required this.currentScale,
    required this.onScaleChanged,
  });

  final int currentScale;
  final Function(double scale) onScaleChanged;

  @override
  State<_ScaleSlider> createState() => __ScaleSliderState();
}

class __ScaleSliderState extends State<_ScaleSlider> {
  late int _currentScale = widget.currentScale;

  @override
  Widget build(BuildContext context) {
    return Slider(
      max: 5.0,
      min: 0.5,
      value: _currentScale / 100,
      onChanged: (scale) {
        widget.onScaleChanged(scale);
        setState(
          () => _currentScale = (scale * 100).toInt(),
        );
      },
    );
  }
}
