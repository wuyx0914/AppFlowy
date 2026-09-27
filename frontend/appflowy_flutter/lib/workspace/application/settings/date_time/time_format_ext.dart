import 'package:appflowy_backend/protobuf/flowy-user/date_time.pbenum.dart';
import 'package:intl/intl.dart';

extension TimeFormatter on UserTimeFormatPB {
  DateFormat get toFormat => _toFormat[this]!;

  String formatTime(DateTime date) => toFormat.format(date);
}

final _toFormat = {
  UserTimeFormatPB.TwentyFourHour: DateFormat.Hm(),
  UserTimeFormatPB.TwelveHour: DateFormat.jm(),
};
