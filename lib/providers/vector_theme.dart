import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final vectorLayerProvider = FutureProvider<VectorTileLayer>((ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  if (!await appDir.exists()) {
    await appDir.create(recursive: true);
  }

  final dbFile = File(path.join(appDir.path, 'estonia.mbtiles'));
  if (!await dbFile.exists()) {
    final mbtilesContent = await rootBundle.load('assets/estonia.mbtiles');
    final bytes = mbtilesContent.buffer.asUint8List();
    await dbFile.writeAsBytes(bytes, flush: true);
  }
  final mbtiles = MbTiles(mbtilesPath: dbFile.path);

  final asset = await rootBundle.loadString("assets/liberty.json");
  final theme = ThemeReader().read(json.decode(asset));

  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'openmaptiles': MbTilesVectorTileProvider(mbtiles: mbtiles)}),
  );
});
