import 'package:flutter/material.dart';
import 'package:sameway/app.dart';
import 'package:sameway/core/session/app_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.instance.initialize();
  runApp(const SameWayApp());
}
