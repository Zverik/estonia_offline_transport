import 'package:estonia_offline_transport/constants.dart';
import 'package:estonia_offline_transport/providers/transit.dart';
import 'package:estonia_offline_transport/providers/vector_theme.dart';
import 'package:estonia_offline_transport/route.dart';
import 'package:estonia_offline_transport/widgets/arrival_row.dart';
import 'package:estonia_offline_transport/widgets/stop_circle.dart';
import 'package:estonia_offline_transport/widgets/stop_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gtfs_binary_dart/gtfs_binary_dart.dart';
import 'package:latlong2/latlong.dart';

class ArrivalsPage extends ConsumerStatefulWidget {
  const ArrivalsPage({super.key});

  @override
  ConsumerState<ArrivalsPage> createState() => _ArrivalsPageState();
}

enum DataStatus { missing, loading, loaded }

class ArrivalDisplayedItem {
  final Departure first;
  Departure? second;

  ArrivalDisplayedItem(this.first);
  bool get hasSecond => second != null;
}

class _ArrivalsPageState extends ConsumerState<ArrivalsPage> {
  DataStatus _status = DataStatus.loaded;
  final _mapController = MapController();
  LatLng? _center;
  String? _stage;
  List<Stop> _stops = [];
  String? _stopsError;
  Stop? _nearestStop;
  List<Departure> _arrivals = [];

  @override
  void initState() {
    super.initState();
    checkLoaded();
  }

  void checkLoaded() async {
    final feed = 1; // await ref.read(transitProvider).queries.feeds.getByName('feed');
    if (feed != null) {
      setState(() {
        _status = DataStatus.loaded;
      });
    }
  }

  void loadData() async {
    setState(() {
      _status = DataStatus.loading;
    });
    final asset = await rootBundle.load("assets/estonia.gtp");
    /*
    await ref.read(transitProvider).loadProto('feed', asset.buffer.asUint8List(), (status, perc) {
      setState(() {
        _stage = 'Loading... $perc% ${status.name}';
      });
    });
    */
    setState(() {
      _status = DataStatus.loaded;
    });
  }

  void updateStops(MapCamera camera) async {
    final bounds = camera.visibleBounds;
    _arrivals = [];
    try {
      if (camera.zoom < 13) {
        _stops = [];
      } else {
        _stops = (await ref.read(transitProvider.future)).findStopsForBounds(bounds.southWest, bounds.northEast);
      }
    } on Exception catch (e) {
      setState(() {
        _stopsError = e.toString();
        _nearestStop = null;
      });
      return;
    }
    _stopsError = null;

    if (_stops.isEmpty) {
      _nearestStop = null;
    } else {
      final distance = DistanceHaversine();
      final center = camera.center;
      _nearestStop = _stops.fold<Stop>(
        _stops.first,
        (a, b) => distance(a.location, center) < distance(b.location, center) ? a : b,
      );
      if (!bounds.contains(_nearestStop!.location)) _nearestStop = null;
    }
    setState(() {});
    updateArrivals();
  }

  void onMapEvent(MapEvent event) async {
    if (event is MapEventWithMove) {
      setState(() {
        _center = event.camera.center;
      });
    }

    if (event is MapEventMoveEnd) {
      updateStops(event.camera);
    }
  }

  List<ArrivalDisplayedItem> sortArrivals() {
    if (_arrivals.isEmpty) return [];
    var byRoute = <int, ArrivalDisplayedItem>{};
    for (var arrival in _arrivals) {
      if (!byRoute.containsKey(arrival.trip.route.feedId)) {
        byRoute[arrival.trip.route.feedId] = ArrivalDisplayedItem(arrival);
      } else {
        var item = byRoute[arrival.trip.route.feedId]!;
        if (!item.hasSecond) item.second = arrival;
      }
    }
    var fixedArrivals = byRoute.values.toList();
    fixedArrivals.sort((a, b) => a.first.stop.departure.compareTo(b.first.stop.departure));
    return fixedArrivals;
  }

  void updateArrivals() async {
    final stop = _nearestStop;
    if (stop == null) {
      setState(() {
        _arrivals.clear();
      });
      return;
    }

    final arrivals = ref.read(transitProvider).requireValue.findDepartures(stop: stop, futureSeconds: 3600 * 2);
    setState(() {
      _arrivals = arrivals;
    });
  }

  Future<void> navigateToLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      try {
        perm = await Geolocator.requestPermission();
      } on Exception catch (e) {
        print('Permission request failed: $e');
        return;
      }
      if (perm == LocationPermission.denied) {
        print('Geolocation denied');
        return;
      }
    }

    if (perm == LocationPermission.deniedForever) {
      print('Geolocation denied forever');
      return;
    }

    final location = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(location.latitude, location.longitude), 15);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateStops(_mapController.camera);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bottom;
    if (_status == DataStatus.missing) {
      bottom = Center(
        child: ElevatedButton(
          child: Text('Load GTFS Data'),
          onPressed: () {
            loadData();
          },
        ),
      );
    } else if (_arrivals.isNotEmpty) {
      final sortedArrivals = sortArrivals();
      bottom = ListView.separated(
        itemCount: sortedArrivals.length,
        separatorBuilder: (_, _) => Divider(),
        itemBuilder: (ctx, idx) {
          final a = sortedArrivals[idx];
          return GestureDetector(
            child: ArrivalRow(a.first, second: a.second),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RoutePage(a.first.trip)));
            },
          );
        },
      );
    } else {
      String message;
      if (_status == DataStatus.loading) {
        message = _stage ?? 'Loading...';
      } else if (_stopsError != null) {
        message = _stopsError ?? 'Stops error';
      } else {
        message = 'OK, ${_stops.length} stops';
      }
      bottom = Center(child: Text(message));
    }

    final vector = ref.watch(vectorLayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Swiss Offline Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: navigateToLocation,
          ),
        ],
      ),
      body: Column(
        mainAxisSize: .max,
        children: [
          Expanded(
            flex: 1,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: kDefaultLocation,
                initialZoom: 15,
                minZoom: 8,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all - InteractiveFlag.rotate - InteractiveFlag.flingAnimation,
                ),
                onMapEvent: onMapEvent,
                onMapReady: () {
                  updateStops(_mapController.camera);
                },
              ),
              children: [
                vector.value ??
                    Container(
                      color: Colors.grey,
                      child: Center(child: Text(vector.error?.toString() ?? 'Loading the map...')),
                    ),
                if (_center != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center!,
                        alignment: Alignment.center,
                        child: Icon(Icons.adjust, color: Colors.black.withValues(alpha: 0.3), size: 24.0),
                      ),
                    ],
                  ),
                if (_stops.isNotEmpty) CircleLayer(circles: [for (final stop in _stops) StopCircle(stop.location)]),
                if (_nearestStop != null) StopWithLabel(_nearestStop!),
              ],
            ),
          ),
          Expanded(flex: 1, child: bottom),
        ],
      ),
    );
  }
}
