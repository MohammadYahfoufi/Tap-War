import 'package:flutter/material.dart';
import 'dart:math';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class GameScreen extends StatefulWidget {
  final String mode;

  GameScreen({required this.mode});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _gameStarted = false;
  int _flexRed = 10;
  int _flexBlue = 10;
  String _winner = '';
  bool _canRestartGame = true;

  int _timeLeft = 20;
  bool _timerRunning = false;

  final Random _random = Random();
  bool _powerUpVisible = false;
  Offset _powerUpRedPosition = Offset(100, 500);
  Offset _powerUpBluePosition = Offset(100, 200);
  String _currentPowerUpRed = 'shield';
  String _currentPowerUpBlue = 'shield';
  String _activePowerUpRed = '';
  String _activePowerUpBlue = '';
  int _redDoubleTapCount = 0;
  int _blueDoubleTapCount = 0;
  int _gamesPlayed = 0;
  bool _isAdReady = false;
  bool _isAdPlaying = false;

  final List<String> _powerUpTypes = ['shield', 'boost', 'double'];

  @override
  void initState() {
    super.initState();

    if (widget.mode == 'timer') {
      _startCountdown();
    }

    UnityAds.init(gameId: '5823812', testMode: false);
    UnityAds.load(placementId: 'Interstitial_Android');

    Future.delayed(Duration(seconds: 3), () {
      setState(() => _isAdReady = true);
    });
  }

void _maybeShowAd() {
  if (_isAdReady && !_isAdPlaying) {
    setState(() => _isAdPlaying = true);

    UnityAds.showVideoAd(
      placementId: 'Interstitial_Android',
      onComplete: (placementId) {
        setState(() => _isAdPlaying = false);
        _proceedAfterAd();
      },
      onSkipped: (placementId) {
        setState(() => _isAdPlaying = false);
        _proceedAfterAd();
      },
      onFailed: (placementId, error, message) {
        print("Ad failed: $message");
        setState(() => _isAdPlaying = false);
        _proceedAfterAd();
      },
    );
  } else {
    _proceedAfterAd();
  }
}


void _proceedAfterAd() {
  setState(() {
    _winner = _flexRed == 20 ? 'Red Wins!' : 'Blue Wins!';
    _powerUpVisible = false;
    _activePowerUpRed = '';
    _activePowerUpBlue = '';
  });
}


  void _onGameEnd() {
    _gamesPlayed++;
    if (_gamesPlayed % 1 == 0) {
      _maybeShowAd();
    }
  }

  void _startCountdown() {
    _timerRunning = true;
    Future.doWhile(() async {
      if (_timeLeft > 0 && _winner.isEmpty && _gameStarted) {
        await Future.delayed(Duration(seconds: 1));
        setState(() => _timeLeft--);
        return true;
      } else {
        if (_winner.isEmpty && _gameStarted) {
          if (_flexRed > _flexBlue) {
            setState(() => _winner = 'Red Wins!');
          } else if (_flexBlue > _flexRed) {
            setState(() => _winner = 'Blue Wins!');
          } else {
            setState(() => _winner = 'Draw!');
          }
        }
        return false;
      }
    });
  }

  void _spawnPowerUp() {
    setState(() {
      _powerUpVisible = true;
      _currentPowerUpRed = _powerUpTypes[_random.nextInt(_powerUpTypes.length)];
      _currentPowerUpBlue =
          _powerUpTypes[_random.nextInt(_powerUpTypes.length)];
      _powerUpRedPosition = Offset(_random.nextDouble() * 250 + 50, 0);
      _powerUpBluePosition = Offset(_random.nextDouble() * 250 + 50, 200);
    });
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _flexRed = 10;
      _flexBlue = 10;
      _winner = '';
      _timeLeft = 20;
      _redDoubleTapCount = 0;
      _blueDoubleTapCount = 0;
    });

    if (widget.mode == 'normal') {
      _spawnPowerUp();
      _schedulePowerUpSpawn();
    }

    if (widget.mode == 'timer') {
      _startCountdown();
    }
  }

  void _schedulePowerUpSpawn() {
    Future.delayed(Duration(seconds: 5), () {
      if (!_gameStarted || _winner.isNotEmpty || widget.mode != 'normal')
        return;
      _spawnPowerUp();
      _schedulePowerUpSpawn();
    });
  }

  void _collectPowerUp(String player, String type) {
    setState(() => _powerUpVisible = false);
    if (type == 'shield')
      _applyShield(player);
    else if (type == 'boost')
      _applyBoost(player);
    else if (type == 'double') _applyDoubleTap(player);
  }

  void _applyShield(String player) {
    if (player == 'red') {
      _activePowerUpRed = 'shield';
      Future.delayed(
          Duration(seconds: 1), () => setState(() => _activePowerUpRed = ''));
    } else {
      _activePowerUpBlue = 'shield';
      Future.delayed(
          Duration(seconds: 1), () => setState(() => _activePowerUpBlue = ''));
    }
  }

  void _applyBoost(String player) {
    setState(() {
      if (player == 'red') {
        _activePowerUpRed = 'boost';
        _flexRed = (_flexRed + 4).clamp(0, 20);
        _flexBlue = (_flexBlue - 4).clamp(0, 20);
        _checkWinner();
        Future.delayed(
            Duration(seconds: 3), () => setState(() => _activePowerUpRed = ''));
      } else {
        _activePowerUpBlue = 'boost';
        _flexBlue = (_flexBlue + 4).clamp(0, 20);
        _flexRed = (_flexRed - 4).clamp(0, 20);
        _checkWinner();
        Future.delayed(Duration(seconds: 3),
            () => setState(() => _activePowerUpBlue = ''));
      }
    });
  }

  void _applyDoubleTap(String player) {
    if (player == 'red') {
      _activePowerUpRed = 'double';
      _redDoubleTapCount = 3;
    } else {
      _activePowerUpBlue = 'double';
      _blueDoubleTapCount = 3;
    }
  }

  void _increaseRed() {
    if (_activePowerUpBlue == 'shield') return;

    int power = _redDoubleTapCount > 0 ? 2 : 1;
    setState(() {
      _flexRed = (_flexRed + power).clamp(0, 20);
      _flexBlue = (_flexBlue - power).clamp(0, 20);

      if (_redDoubleTapCount > 0) {
        _redDoubleTapCount--;
        if (_redDoubleTapCount == 0) _activePowerUpRed = '';
      }

      _checkWinner();
    });
  }

  void _increaseBlue() {
    if (_activePowerUpRed == 'shield') return;

    int power = _blueDoubleTapCount > 0 ? 2 : 1;
    setState(() {
      _flexBlue = (_flexBlue + power).clamp(0, 20);
      _flexRed = (_flexRed - power).clamp(0, 20);

      if (_blueDoubleTapCount > 0) {
        _blueDoubleTapCount--;
        if (_blueDoubleTapCount == 0) _activePowerUpBlue = '';
      }

      _checkWinner();
    });
  }

  void _checkWinner() {
    if (_flexRed == 20) {
      setState(() => _winner = 'Red Wins!');
      _maybeShowAd();
      _powerUpVisible = false;
      _activePowerUpRed = '';
      _activePowerUpBlue = '';
    }
    if (_flexBlue == 20) {
      setState(() => _winner = 'Blue Wins!');
      _maybeShowAd();
      _powerUpVisible = false;
      _activePowerUpRed = '';
      _activePowerUpBlue = '';
    }
  }

  Widget _buildPowerUpIcon(String type, {bool rotate = false}) {
  IconData icon;
  switch (type) {
    case 'shield':
      icon = Icons.shield;
      break;
    case 'boost':
      icon = Icons.flash_on;
      break;
    case 'double':
      icon = Icons.exposure_plus_2;
      break;
    default:
      icon = Icons.help_outline;
  }

  Widget iconWidget = Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.yellow.withOpacity(0.8),
    ),
    child: Icon(icon, color: Colors.white, size: 30),
  );

  return rotate ? Transform.rotate(angle: pi, child: iconWidget) : iconWidget;
}


  Widget _buildPowerUpEffect(String type, {bool rotate = false}) {
  IconData icon;
  Color color;
  switch (type) {
    case 'shield':
      icon = Icons.shield;
      color = Colors.white;
      break;
    case 'boost':
      icon = Icons.flash_on;
      color = Colors.orange;
      break;
    case 'double':
      icon = Icons.exposure_plus_2;
      color = Colors.purpleAccent;
      break;
    default:
      return Container();
  }

  Widget effect = Center(
    child: Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: Icon(icon, color: Colors.white, size: 60),
    ),
  );

  return rotate ? Transform.rotate(angle: pi, child: effect) : effect;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_winner.isNotEmpty && _canRestartGame) {
            setState(() {
              _gameStarted = false;
              _winner = '';
            });
          } else if (!_gameStarted) {
            _startGame();
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: _gameStarted ? _flexBlue : 10,
                  child: GestureDetector(
                    onTap: _gameStarted && _winner == '' ? _increaseBlue : null,
                    child: Container(
                      color: Colors.blue,
                      child: Stack(
                        children: [
                          if (_activePowerUpBlue.isNotEmpty)
                            _buildPowerUpEffect(_activePowerUpBlue, rotate: true),
                          if (_powerUpVisible && widget.mode == 'normal')
                            Positioned(
                              left: _powerUpBluePosition.dx,
                              top: 20,
                              child: GestureDetector(
                                onTap: () => _collectPowerUp(
                                    'blue', _currentPowerUpBlue),
                                child: _buildPowerUpIcon(_currentPowerUpBlue, rotate: true),
                              ),
                            ),
                          Center(
                            child: Visibility(
                              visible: !_gameStarted,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Transform.rotate(
                                    angle: 3.14159,
                                    child: Text('Start',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 20)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: _gameStarted ? _flexRed : 10,
                  child: GestureDetector(
                    onTap: _gameStarted && _winner == '' ? _increaseRed : null,
                    child: Container(
                      color: Colors.red,
                      child: Stack(
                        children: [
                          if (_activePowerUpRed.isNotEmpty)
                            _buildPowerUpEffect(_activePowerUpRed),
                          if (_powerUpVisible && widget.mode == 'normal')
                            Positioned(
                              left: _powerUpRedPosition.dx,
                              bottom: 20,
                              child: GestureDetector(
                                onTap: () =>
                                    _collectPowerUp('red', _currentPowerUpRed),
                                child: _buildPowerUpIcon(_currentPowerUpRed),
                              ),
                            ),
                          Center(
                            child: Visibility(
                              visible: !_gameStarted,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text('Start',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_winner.isNotEmpty)
              Positioned.fill(
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      color: _winner.contains('Red') ? Colors.red : Colors.blue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Transform.rotate(
                                angle: _winner.contains('Blue') ? pi : 0,
                                child: Text(
                                  _winner,
                                  style: TextStyle(
                                    color: _winner.contains('Red')
                                        ? Colors.red
                                        : Colors.blue,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.replay,
                                        color: Colors.white, size: 32),
                                    onPressed: () {
                                      setState(() {
                                        _gameStarted = false;
                                        _winner = '';
                                      });
                                    },
                                  ),
                                  Text("Rematch",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              const SizedBox(width: 40),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.home,
                                        color: Colors.white, size: 32),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Text("Home",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.mode == 'timer' && _gameStarted && _winner.isEmpty) ...[
              Positioned(
                left: 12,
                top: MediaQuery.of(context).size.height / 2 - 24,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$_timeLeft s',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 12,
                top: MediaQuery.of(context).size.height / 2 - 24,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$_timeLeft s',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}