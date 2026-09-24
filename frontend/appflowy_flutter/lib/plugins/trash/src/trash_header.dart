import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flutter/material.dart';
import 'sizes.dart';

class TrashHeaderDelegate extends SliverPersistentHeaderDelegate {
  TrashHeaderDelegate();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return TrashHeader();
  }

  @override
  double get maxExtent => TrashSizes.headerHeight;

  @override
  double get minExtent => TrashSizes.headerHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class TrashHeaderItem {
  TrashHeaderItem({required this.width, required this.title});

  double width;
  String title;
}

class TrashHeader extends StatelessWidget {
  TrashHeader({super.key});

  final List<TrashHeaderItem> items = [
    TrashHeaderItem(
      title: '文件名',
      width: TrashSizes.fileNameWidth,
    ),
    TrashHeaderItem(
      title: '最近修改',
      width: TrashSizes.lashModifyWidth,
    ),
    TrashHeaderItem(
      title: '创建时间',
      width: TrashSizes.createTimeWidth,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final headerItems = List<Widget>.empty(growable: true);
    items.asMap().forEach((index, item) {
      headerItems.add(
        SizedBox(
          width: item.width,
          child: FlowyText(
            item.title,
            color: Theme.of(context).disabledColor,
          ),
        ),
      );
    });

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...headerItems,
        ],
      ),
    );
  }
}
