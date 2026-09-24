import 'package:appflowy/workspace/application/settings/appearance/appearance_cubit.dart';
import 'package:appflowy/workspace/application/settings/date_time/date_format_ext.dart';
import 'package:appflowy/workspace/application/settings/date_time/time_format_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

String formatTimestampWithContext(
  BuildContext context, {
  required int timestamp,
  String? prefix,
}) {
  final now = DateTime.now();
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final difference = now.difference(dateTime);
  final String date;

  final dateFormat = context.read<AppearanceSettingsCubit>().state.dateFormat;
  final timeFormat = context.read<AppearanceSettingsCubit>().state.timeFormat;

  if (difference.inMinutes < 1) {
    date = '现在';
  } else if (difference.inHours < 1 && dateTime.isToday) {
    // Less than 1 hour
    date = '{difference.inMinutes.toString()} 分钟以前';
  } else if (difference.inHours >= 1 && dateTime.isToday) {
    // in same day
    date = timeFormat.formatTime(dateTime);
  } else {
    date = dateFormat.formatDate(dateTime, false);
  }

  if (difference.inHours >= 1 && prefix != null) {
    return '$prefix $date';
  }

  return date;
}
