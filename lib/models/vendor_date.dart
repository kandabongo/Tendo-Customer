import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class VendorDay {
  final int id;
  final String name;
  final String open;
  final String close;

  VendorDay({
    required this.id,
    required this.name,
    required this.open,
    required this.close,
  });

  factory VendorDay.fromJson(Map<String, dynamic> json) {
    return VendorDay(
      id: json["id"],
      name: json["name"],
      open: json["pivot"] != null ? json["pivot"]["open"] ?? "" : json["open"],
      close:
          json["pivot"] != null ? json["pivot"]["close"] ?? "" : json["close"],
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "open": open,
    "close": close,
  };

  // getters
  String get openTime {
    try {
      // Parse the time string into a DateTime object
      DateTime time = DateFormat("HH:mm:ss", "en").parse(open);
      // Format the time into hh:mm a format in Arabic
      return DateFormat('hh:mm a', translator.activeLanguageCode).format(time);
      // return DateFormat('hh:mm a', "en").format(time);
    } catch (error) {
      //
    }

    try {
      return Jiffy.parse(open, pattern: "HH:mm:ss").format(pattern: "hh:mm a");
    } catch (error) {
      return open;
    }
  }

  String get closeTime {
    try {
      // Parse the time string into a DateTime object
      DateTime time = DateFormat("HH:mm:ss", "en").parse(close);
      // Format the time into hh:mm a format in Arabic
      return DateFormat('hh:mm a', translator.activeLanguageCode).format(time);
      // return DateFormat('hh:mm a', "en").format(time);
    } catch (error) {
      //
    }

    try {
      return Jiffy.parse(close, pattern: "HH:mm:ss").format(pattern: "hh:mm a");
    } catch (error) {
      return close;
    }
  }
}
