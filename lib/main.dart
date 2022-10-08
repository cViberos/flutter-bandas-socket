import 'package:flu_band_names/services/service_socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flu_band_names/pages/pages.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SocketService())],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        initialRoute: 'status',
        routes: {
          'home': (context) => HomePage(),
          'status': (context) => StatusPage(),
        },
      ),
    );
  }
}
