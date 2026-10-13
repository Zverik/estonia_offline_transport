import 'package:estonia_offline_transport/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locationProvider = NotifierProvider<LocationNotifier, LatLng>(
  LocationNotifier.new,
);

class LocationNotifier extends Notifier<LatLng> {
  static const kPref = 'location';

  @override
  LatLng build() {
    _loadLast();
    return kDefaultLocation;
  }

  void _loadLast() async {
    final prefs = SharedPreferencesAsync();
    final loc = await prefs.getStringList(kPref);
    if (loc != null && loc.length == 2) {
      final coords = loc
          .map((e) => double.tryParse(e))
          .whereType<double>()
          .toList();
      if (coords.length == 2 && state == kDefaultLocation) {
        state = LatLng(coords[0], coords[1]);
      }
    }
  }

  void set(LatLng loc) async {
    state = loc;
    final prefs = SharedPreferencesAsync();
    await prefs.setStringList(kPref, [
      loc.latitude.toString(),
      loc.longitude.toString(),
    ]);
  }
}
