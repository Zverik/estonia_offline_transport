import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_proto_flutter/gtfs_proto_flutter.dart';

final transitProvider = Provider((_) => GtfsProto('gtfs_proto.db'));