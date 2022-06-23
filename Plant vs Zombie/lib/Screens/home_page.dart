import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:plants_vs_zombie/Constant/assets.dart';
import 'package:plants_vs_zombie/Models/bullet.dart';
import 'package:plants_vs_zombie/Models/main_handler.dart';
import 'package:plants_vs_zombie/Models/plant.dart';
import 'package:plants_vs_zombie/Models/zombie.dart';
import 'package:plants_vs_zombie/Utils/audio_player.dart';
import 'package:plants_vs_zombie/Utils/math_util.dart';
import 'package:plants_vs_zombie/Widgets/bullet.dart';
import 'package:plants_vs_zombie/Widgets/cotrollers_button.dart';
import 'package:plants_vs_zombie/Widgets/plant.dart';
import 'package:plants_vs_zombie/Widgets/score_board.dart';
import 'package:plants_vs_zombie/Widgets/zombie.dart';
import 'package:plants_vs_zombie/routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlantHandler _plant = PlantHandler(-0.90, 0.2);
  Bullethandler _bullet = Bullethandler(5, 5);
  ZombieHandler _zombie = ZombieHandler(1.1, 1);
  Timer? _zombieTimer, _bulletTimer;
  int score = 0;

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-7540836345366849/2099362149',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-7540836345366849/5463892081',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 5) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  /// move the plant up Y↑
  _moveUp(MainHandler mock) {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (ControllerButton(icon: Icons.arrow_circle_up, onTap: () =>setState(() {mock.moveDown(0.05);})).isTapping()) {
        setState(() {
          mock.moveUp(-0.05);
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// move the plant Down Y↓
  _moveDown(MainHandler mock) {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (ControllerButton(onTap: () => setState(() {mock.moveDown(0.05);}), icon: Icons.arrow_circle_down).isTapping()) {
        setState(() {
          mock.moveDown(0.05);
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// shooting the bullets
  _shootBullet() async {
    if (_bullet.x == 5) {
      await AudioPlayer.playSound(Assets.shootSoundEffet);
      setState(() {
        _bullet.initCords(_plant.x, _plant.y);
      });
      _bulletTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        setState(() {
          _bullet.moveRight();
        });
        if ((_bullet.x - _zombie.x).abs() < 0.05 &&
            (_bullet.y - _zombie.y).abs() < 0.2) {
          timer.cancel();
          if (_zombieTimer != null) {
            _zombieTimer?.cancel();
          }
          _bullet.initCords(5, 5);
          _calculateScore();
          _moveZombie();
        }
        if (_bullet.x > 1.3) {
          timer.cancel();
          _bullet.initCords(5, 5);
        }
      });
    }
  }

  /// moving the zombie
  _moveZombie() {
    setState(() {
      _zombie.initCords(1.1, nexRandom(-0.9, 0.9));
    });
    if (_zombie.x == 1.1) {
      _zombieTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
        setState(() {
          _zombie.moveLeft();
        });
        if ((_plant.x - _zombie.x).abs() < 0.05) {
          timer.cancel();
          if (_bulletTimer != null) {
            _bulletTimer?.cancel();
          }
          print("Game Over");
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.game_over, (route) => false,
              arguments: score);
        }
      });
    }
  }

  _calculateScore() {
    setState(() {
      score++;
    });
  }

  @override
  void initState() {
    super.initState();
    myBanner.load();
    _createInterstitialAd();
    _moveZombie();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);
    return WillPopScope(
        onWillPop: () async {
          _showInterstitialAd();
          return true;
        },
        child: Scaffold(
          body: SafeArea(
            child: Container(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: adWidget,
                    width: myBanner.size.width.toDouble(),
                    height: myBanner.size.height.toDouble(),
                  ),
                  _garden(),
                  _gameControllers(),
                ],
              ),
            ),
          ),
        )
    );
  }

  /// Game controllers arrows & shoot button
  Widget _gameControllers() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.brown[600],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                ControllerButton(
                    icon: Icons.arrow_upward,
                    onTap: () {
                      _moveUp(_plant);
                    }),
                SizedBox(width: 15.0),
                ControllerButton(
                  icon: Icons.arrow_downward,
                  onTap: () {
                    _moveDown(_plant);
                  },
                ),
              ],
            ),
            ScoreBoard(
              score: score,
            ),
            ControllerButton(
              icon: FontAwesomeIcons.meteor,
              onTap: _shootBullet,
            ),
          ],
        ),
      ),
    );
  }

  /// the main garden
  _garden() {
    return Expanded(
      flex: 5,
      child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.garden),
              fit: BoxFit.cover,
            ),
          ),
          child: _players()),
    );
  }

  /// Plants , Zombies & bullet will be displayed
  Widget _players() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(_plant.x, _plant.y),
          child: Plant(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(_bullet.x, _bullet.y),
          child: Bullet(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(_zombie.x, _zombie.y),
          child: Zombie(),
        ),
      ],
    );
  }
}
