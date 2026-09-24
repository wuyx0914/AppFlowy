import 'package:appflowy/workspace/application/settings/date_time/date_format_ext.dart';
import 'package:appflowy_backend/protobuf/flowy-user/date_time.pbenum.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/material.dart';

class ViewMetaInfo extends StatelessWidget {
  const ViewMetaInfo({
    super.key,
    required this.dateFormat,
    required this.timeFormat,
    this.documentCounters,
    this.titleCounters,
    this.createdAt,
  });

  final UserDateFormatPB dateFormat;
  final UserTimeFormatPB timeFormat;
  final Counters? documentCounters;
  final Counters? titleCounters;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat();

    // If more info is added to this Widget, use a separated ListView
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (documentCounters != null && titleCounters != null) ...[
            FlowyText.regular(
              '字数: ${numberFormat.format(documentCounters!.wordCount + titleCounters!.wordCount)}',
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
            const VSpace(2),
            FlowyText.regular(
              '字符数: ${numberFormat.format(documentCounters!.charCount + titleCounters!.charCount)}',
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ],
          if (createdAt != null) ...[
            if (documentCounters != null && titleCounters != null)
              const VSpace(2),
            FlowyText.regular(
              '创建于: ${dateFormat.formatDate(createdAt!, true, timeFormat)}',
              fontSize: 12,
              maxLines: 2,
              color: Theme.of(context).hintColor,
            ),
          ],
        ],
      ),
    );
  }
}
