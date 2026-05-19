import 'package:aitmatov_app/app/app.dart';
import 'package:aitmatov_app/app/di.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  ChuckerFlutter.configure(
    showOnRelease: true,
    showNotification: true,
    notificationAlignment: Alignment.bottomCenter,
    offsetBegin: const Offset(0, -0.1),
    offsetEnd: Offset.zero,
  );
  runApp(const AitmatovApp());
}
