import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tec_assessment_test/features/meeting_room/presentation/pages/meeting_room_home_page.dart';

void main() {
  if (kDebugMode) {
    HttpOverrides.global = _DebugHttpOverrides();
  }
  runApp(const ProviderScope(child: MyApp()));
}

class _DebugHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) =>
        host == 'octo.pr-product-core.executivecentre.net';
    return client;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MeetingRoomHomePage());
  }
}
