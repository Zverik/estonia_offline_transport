import 'package:flutter/material.dart' show Colors;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StopCircle extends CircleMarker {
  const StopCircle(LatLng location)
    : super(point: location, color: Colors.yellow, borderColor: Colors.black, borderStrokeWidth: 1.0, radius: 5.0);
}
