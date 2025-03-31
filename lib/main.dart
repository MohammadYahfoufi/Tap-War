import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Unity Ads
  UnityAds.init(
    gameId: '5823812', // Replace with your Unity Game ID
    testMode: true,
  );

  // Optional: Preload the banner (optional in Unity but nice for speed)
  UnityAds.load(placementId: 'Banner_Android');

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
