import 'package:estonia_offline_transport/arrivals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const OfflineApp()));
}

class OfflineApp extends StatelessWidget {
  const OfflineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estonia Offline Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ArrivalsPage(),
    );
  }
}