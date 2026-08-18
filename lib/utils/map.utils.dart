import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

class MapUtils {
  //
  static targetBounds(LatLng locNE, LatLng locSW) {
    var nLat, nLon, sLat, sLon;

    if (locSW.latitude <= locNE.latitude) {
      sLat = locSW.latitude;
      nLat = locNE.latitude;
    } else {
      sLat = locNE.latitude;
      nLat = locSW.latitude;
    }
    if (locSW.longitude <= locNE.longitude) {
      sLon = locSW.longitude;
      nLon = locNE.longitude;
    } else {
      sLon = locNE.longitude;
      nLon = locSW.longitude;
    }

    return LatLngBounds(
      northeast: LatLng(nLat, nLon),
      southwest: LatLng(sLat, sLon),
    );
  }

  static Future<Uint8List?> imageToUint8List({
    String? url,
    String? base64String,
  }) async {
    try {
      Uint8List imageData;

      if (base64String != null) {
        // Decode the base64 string into Uint8List
        imageData = base64Decode(base64String);
      } else if (url != null) {
        // Fetch the image data from the URL
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          imageData = response.bodyBytes;
        } else {
          throw Exception('Failed to load image from URL');
        }
      } else {
        throw Exception('Either URL or base64 string must be provided');
      }

      // Decode the image to get its dimensions
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(imageData, (ui.Image img) {
        completer.complete(img);
      });
      ui.Image img = await completer.future;

      // Convert the image to ByteData
      ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      // Return the data as Uint8List
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
