import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  UnityAds.init(
    gameId: '5823***',
    testMode: false,
  );

  UnityAds.load(placementId: 'Banner_Android');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap War',
      debugShowCheckedModeBanner: true,
      home: HomeScreen(),
    );
  }
}
