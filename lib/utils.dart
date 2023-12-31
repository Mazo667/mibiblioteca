import 'package:flutter/material.dart';

Color hexToColor(String code, defaultColor){
  try {
    var substring =
    code.length > 7 ? code.substring(3, 9) : code.substring(1, 7);
    return Color(int.parse(substring, radix: 16) + 0x66000000);
  } on FormatException catch (_) {
    return defaultColor;
  } on RangeError catch (e) {
    debugPrint(e.message);
    return defaultColor;
  }
}

ImageProvider getImageWidget(String coverUrl) {
  if (coverUrl.startsWith("http")) {
    return NetworkImage(coverUrl);
  } else {
    return AssetImage(coverUrl);
  }
}