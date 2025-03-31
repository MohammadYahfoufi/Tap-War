import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  UnityAds.init(
    gameId: '5823812', // Your Android Game ID from Unity Dashboard
    testMode: true,     // Set to false when publishing to the Play Store
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap War',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
