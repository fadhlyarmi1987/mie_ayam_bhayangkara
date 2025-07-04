import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mie_ayam_bhayangkara/pages/pesanan.dart';
import 'control_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absen',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const ControlPage(),
        '/pesanan' : (context) => AntreanPage(),
      },
    );
  }
}
