import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4960154231239334/2834433937', // Your AdMob unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('❌ Ad failed to load: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    try {
      _bannerAd.dispose();
    } catch (e) {
      print('Error disposing ad: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/redBack.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tap War',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black26)
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        _buildGameButton('Play with Power-Ups', Colors.blueAccent, 'normal'),
                        const SizedBox(height: 16),
                        _buildGameButton('Play without Power-Ups', Colors.grey.shade800, 'noPower'),
                        const SizedBox(height: 16),
                        _buildGameButton('Timer Mode', Colors.redAccent, 'timer'),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isAdLoaded)
                Container(
                  alignment: Alignment.bottomCenter,
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper function to create game mode buttons
  Widget _buildGameButton(String text, Color color, String mode) {
    return ElevatedButton(
      style: _buttonStyle(color),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(mode: mode),
        ),
      ),
      child: Text(text),
    );
  }

  /// Button style customization
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}