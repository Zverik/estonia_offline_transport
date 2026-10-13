import 'package:estonia_offline_transport/providers/vector_theme.dart';
import 'package:estonia_offline_transport/widgets/stop_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_dart/gtfs_binary_dart.dart';
import 'package:latlong2/latlong.dart';

class RoutePage extends ConsumerStatefulWidget {
  final Trip trip;

  const RoutePage(this.trip, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoutePageState();
}

class _RoutePageState extends ConsumerState<RoutePage> {
  bool showLabels = true;
  List<LatLng> _path = const [];

  @override
  void initState() {
    super.initState();
    if (widget.trip.path != null) {
      _path = widget.trip.path!;
    } else {
      _path = widget.trip.stops.map((s) => s.stop.location).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vector = ref.watch(vectorLayerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.route.longName ?? 'Route ${widget.trip.route.name}'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showLabels = !showLabels;
              });
            },
            icon: Icon(showLabels ? Icons.label_off_outlined : Icons.label_outline),
            tooltip: 'Show stop names',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(bounds: LatLngBounds.fromPoints(_path)),
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all - InteractiveFlag.rotate - InteractiveFlag.flingAnimation,
          ),
        ),
        children: [
          vector.value ??
              Container(
                color: Colors.grey,
                child: Center(child: Text(vector.error?.toString() ?? 'Loading the map...')),
              ),
          PolylineLayer(
            polylines: [Polyline(points: _path, color: Colors.blue.shade800, strokeWidth: 3.0)],
          ),
          for (var stop in widget.trip.stops) StopWithLabel(stop.stop, showLabel: showLabels),
        ],
      ),
    );
  }
}
