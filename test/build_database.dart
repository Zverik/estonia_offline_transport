import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:libcompress/libcompress.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gtfs_proto_flutter/gtfs_proto_flutter.dart';

class TestZstdDecompressor implements ZstdDecompressor {
  final zstd = ZstdCodec();

  @override
  Future<Uint8List?> decompress(Uint8List data) async {
    return zstd.decompress(data);
  }
}

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final proto = GtfsProto('estonia.db', decompressor: TestZstdDecompressor());
  final file = File('assets/estonia.gtp');
  final data = file.readAsBytesSync();
  await proto.loadProto('feed', data);
}
