import 'package:flutter/material.dart';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/workspace/presentation/widgets/date_picker/utils/layout.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/date_entities.pbenum.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';

typedef OnReminderSelected = void Function(ReminderOption option);

class ReminderSelector extends StatelessWidget {
  const ReminderSelector({
    super.key,
    required this.mutex,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.timeFormat,
    this.hasTime = false,
  });

  final PopoverMutex? mutex;
  final ReminderOption selectedOption;
  final OnReminderSelected? onOptionSelected;
  final TimeFormatPB timeFormat;
  final bool hasTime;

  @override
  Widget build(BuildContext context) {
    final options = ReminderOption.values.toList();
    if (selectedOption != ReminderOption.custom) {
      options.remove(ReminderOption.custom);
    }

    options.removeWhere(
      (o) => !o.timeExempt && (!hasTime ? !o.withoutTime : o.requiresNoTime),
    );

    final optionWidgets = options.map(
      (o) {
        String label = o.label;
        if (o.withoutTime && !o.timeExempt) {
          const time = "09:00";
          final t = timeFormat == TimeFormatPB.TwelveHour ? "$time AM" : time;

          label = "$label ($t)";
        }

        return SizedBox(
          height: DatePickerSize.itemHeight,
          child: FlowyButton(
            text: FlowyText(label),
            rightIcon:
                o == selectedOption ? const FlowySvg(FlowySvgs.check_s) : null,
            onTap: () {
              if (o != selectedOption) {
                onOptionSelected?.call(o);
                mutex?.close();
              }
            },
          ),
        );
      },
    ).toList();

    return AppFlowyPopover(
      mutex: mutex,
      offset: const Offset(8, 0),
      margin: EdgeInsets.zero,
      constraints: const BoxConstraints(maxHeight: 400, maxWidth: 205),
      popupBuilder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: SeparatedColumn(
              children: optionWidgets,
              separatorBuilder: () => VSpace(DatePickerSize.seperatorHeight),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SizedBox(
          height: DatePickerSize.itemHeight,
          child: FlowyButton(
            text: FlowyText('提醒'),
            rightIcon: Row(
              children: [
                FlowyText.regular(selectedOption.label),
                const FlowySvg(FlowySvgs.more_s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ReminderOption {
  none(time: Duration()),
  atTimeOfEvent(time: Duration()),
  fiveMinsBefore(time: Duration(minutes: 5)),
  tenMinsBefore(time: Duration(minutes: 10)),
  fifteenMinsBefore(time: Duration(minutes: 15)),
  thirtyMinsBefore(time: Duration(minutes: 30)),
  oneHourBefore(time: Duration(hours: 1)),
  twoHoursBefore(time: Duration(hours: 2)),
  onDayOfEvent(
    time: Duration(hours: 9),
    withoutTime: true,
    requiresNoTime: true,
  ),
  // 9:00 AM the day before (24-9)
  oneDayBefore(time: Duration(hours: 15), withoutTime: true),
  twoDaysBefore(time: Duration(days: 1, hours: 15), withoutTime: true),
  oneWeekBefore(time: Duration(days: 6, hours: 15), withoutTime: true),
  custom(time: Duration());

  const ReminderOption({
    required this.time,
    this.withoutTime = false,
    this.requiresNoTime = false,
  }) : assert(!requiresNoTime || withoutTime);

  final Duration time;

  /// If true, don't consider the time component of the dateTime
  final bool withoutTime;

  /// If true, [withoutTime] must be true as well. Will add time instead of subtract to get notification time.
  final bool requiresNoTime;

  bool get timeExempt =>
      [ReminderOption.none, ReminderOption.custom].contains(this);

  String get label => switch (this) {
        ReminderOption.none => '无',
        ReminderOption.atTimeOfEvent =>
          '活动时间',
        ReminderOption.fiveMinsBefore =>
          '5 分钟以前',
        ReminderOption.tenMinsBefore =>
          '10 分钟以前',
        ReminderOption.fifteenMinsBefore =>
          '15 分钟以前',
        ReminderOption.thirtyMinsBefore =>
          '30 分钟以前',
        ReminderOption.oneHourBefore =>
          '1 小时以前',
        ReminderOption.twoHoursBefore =>
          '2 小时以前',
        ReminderOption.onDayOfEvent =>
          '活动当天',
        ReminderOption.oneDayBefore =>
          '1 天以前',
        ReminderOption.twoDaysBefore =>
          '2 天以前',
        ReminderOption.oneWeekBefore =>
          '1 周以前',
        ReminderOption.custom =>
          '自订',
      };

  static ReminderOption fromDateDifference(
    DateTime eventDate,
    DateTime reminderDate,
  ) {
    final def = fromMinutes(eventDate.difference(reminderDate).inMinutes);
    if (def != ReminderOption.custom) {
      return def;
    }

    final diff = eventDate.withoutTime.difference(reminderDate).inMinutes;
    return fromMinutes(diff);
  }

  static ReminderOption fromMinutes(int minutes) => switch (minutes) {
        0 => ReminderOption.atTimeOfEvent,
        5 => ReminderOption.fiveMinsBefore,
        10 => ReminderOption.tenMinsBefore,
        15 => ReminderOption.fifteenMinsBefore,
        30 => ReminderOption.thirtyMinsBefore,
        60 => ReminderOption.oneHourBefore,
        120 => ReminderOption.twoHoursBefore,
        // Negative because Event Day Today + 940 minutes
        -540 => ReminderOption.onDayOfEvent,
        900 => ReminderOption.oneDayBefore,
        2340 => ReminderOption.twoDaysBefore,
        9540 => ReminderOption.oneWeekBefore,
        _ => ReminderOption.custom,
      };

  DateTime getNotificationDateTime(DateTime date) {
    return withoutTime
        ? requiresNoTime
            ? date.withoutTime.add(time)
            : date.withoutTime.subtract(time)
        : date.subtract(time);
  }
}
