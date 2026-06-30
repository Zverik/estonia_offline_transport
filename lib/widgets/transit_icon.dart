import 'package:flutter/material.dart';
import 'package:gtfs_proto_flutter/gtfs_proto_flutter.dart' as m;

class TransitIcon extends StatelessWidget {
  final m.Route route;

  const TransitIcon(this.route);

  @override
  Widget build(BuildContext context) {
    return RoutePlace(
      color: route.color,
      number: route.name,
      isBold: true,
      icon: Icons.directions_bus_filled,
      semantics: '${route.routeType.name} ${route.name}',
    );
  }
}

class RoutePlace extends StatelessWidget {
  final Color color;
  final String number;
  final IconData icon;
  final bool isBold;
  final String semantics;

  const RoutePlace(
      {super.key, required this.color,
        required this.number,
        required this.icon,
        required this.isBold,
        required this.semantics});

  @override
  Widget build(BuildContext context) {
    Color foreground =
    color.computeLuminance() >= 0.8 ? Colors.black : Colors.white;

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: foreground,
                size: 20.0,
              ),
              Text(
                number,
                style: TextStyle(
                  color: foreground,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
