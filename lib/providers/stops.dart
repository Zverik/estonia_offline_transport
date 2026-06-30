import 'package:estonia_offline_transport/providers/transit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_proto_flutter/gtfs_proto_flutter.dart';

final stopsProvider = FutureProvider.autoDispose.family<List<Stop>, LatLngBounds>((ref, bounds) async {
  return await ref.read(transitProvider).findStopsForBounds(bounds.southWest, bounds.northEast);
});