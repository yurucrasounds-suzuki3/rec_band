import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/part_service.dart';
import 'services/song_service.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => StorageService()),
        ProxyProvider<StorageService, SongService>(
          update: (_, storageService, previous) => SongService(storageService),
        ),
        ProxyProvider<StorageService, PartService>(
          update: (_, storageService, previous) => PartService(storageService),
        ),
      ],
      child: const RecBandApp(),
    ),
  );
}
