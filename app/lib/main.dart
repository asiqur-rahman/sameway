import 'package:flutter/material.dart';
import 'package:sameway/app.dart';
import 'package:sameway/core/push/push_service.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.instance.initialize();
  await AppDataStore.instance.initialize();
  await PushService.instance.initialize();
  await RideDayStore.instance.refreshAll();
  runApp(const SameWayApp());
}
