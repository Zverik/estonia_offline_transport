import 'package:estonia_offline_transport/widgets/transit_icon.dart';
import 'package:flutter/material.dart';
import 'package:gtfs_proto_flutter/gtfs_proto_flutter.dart' as m;
import 'package:intl/intl.dart' show DateFormat;

class ArrivalRow extends StatefulWidget {
  final m.Arrival first;
  final m.Arrival? second;
  final bool forceExactTime;

  const ArrivalRow(this.first, {this.second, this.forceExactTime = false});

  @override
  State<ArrivalRow> createState() => _ArrivalRowState();
}

class _ArrivalRowState extends State<ArrivalRow> {
  final scrollController = ScrollController();

  final tf = DateFormat.Hm();

  String formatArrivalTime(BuildContext context, m.Arrival arrival) {
    final arrivesInSec = arrival.stop.departure.difference(DateTime.now()).inSeconds;
    final arrivalSec = arrivesInSec < 0 ? 0 : arrivesInSec;
    return arrivalSec > 700 || widget.forceExactTime
        ? tf.format(arrival.stop.departure)
        : '${(arrivalSec / 60).round()} min';
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstTime = formatArrivalTime(context, widget.first);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Row(
        children: [
          TransitIcon(widget.first.trip.route),
          SizedBox(width: 10.0),
          Expanded(
            flex: 100,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Text(widget.first.stop.headsign ?? 'Bus', style: TextStyle(fontSize: 20.0)),
            ),
          ),
          Expanded(child: Container()),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatArrivalTime(context, widget.first), style: TextStyle(fontSize: 20.0)),
              if (widget.second != null)
                Text(
                  'next ${formatArrivalTime(context, widget.second!)}',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
