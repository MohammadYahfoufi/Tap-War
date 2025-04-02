import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this to control system UI
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the status bar and nav bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Unity Ads
  UnityAds.init(
    gameId: '5823812', // Replace with your Unity Game ID
    testMode: true,
  );

  // Optional: Preload the banner ad
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
