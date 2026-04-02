import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters._();

  static final DateFormat fullDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  static final DateFormat shortDate = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat time = DateFormat('HH:mm');
}
