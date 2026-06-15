import 'package:flutter/material.dart';
import 'package:sameway/app.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.instance.initialize();
  await AppDataStore.instance.initialize();
  runApp(const SameWayApp());
}
