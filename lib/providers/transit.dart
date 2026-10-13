import 'package:estonia_offline_transport/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtfs_binary_dart/gtfs_binary_dart.dart';

final transitProvider = FutureProvider((_) async {
  final data = await rootBundle.load('assets/$kFeed.gtb');
  final reader = BinaryDataReader(data.buffer);
  return GtfsBinary.read(reader).withFile(reader);
});