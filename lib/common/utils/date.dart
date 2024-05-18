// import 'dart:io';
import 'package:universal_io/io.dart';
import 'package:intl/intl.dart';

String timeFormated(String? time) {
  final DateTime now =
      time == null ? DateTime.now().toLocal() : DateTime.parse(time).toLocal();
  final DateFormat formatter =
      DateFormat('yyyy-MM-dd HH:mm:ss', Platform.localeName);
  return formatter.format(now);
}

String duTimeLineFormat(DateTime dt) {
  var now = DateTime.now();
  var difference = now.difference(dt);
  if (difference.inSeconds < 60) {
    if (difference.inSeconds < 0) {
      return "0s ago";
    }
    return "${difference.inSeconds}s ago";
  }
  if (difference.inMinutes < 60) {
    return "${difference.inMinutes}m ago";
  }
  if (difference.inHours < 12) {
    return "${difference.inHours}h ago";
  }
  if (difference.inDays < 3) {
    final dtFormat = DateFormat('MM-dd hh:mm', Platform.localeName);
    return dtFormat.format(dt);
  }
  if (difference.inDays < 30) {
    final dtFormat = DateFormat('yy-MM-dd hh:mm', Platform.localeName);
    return dtFormat.format(dt);
  }
  // MM-dd
  else if (difference.inDays < 365) {
    final dtFormat = DateFormat('yy-MM-dd', Platform.localeName);
    return dtFormat.format(dt);
  }
  // yyyy-MM-dd
  else {
    final dtFormat = DateFormat('yyyy-MM-dd', Platform.localeName);
    var str = dtFormat.format(dt);
    return str;
  }
}
