import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:space_empires/models/ruler_model.dart';

import '../services/game.dart';
import '../services/player/player.dart';
import '../utility/constants.dart';
import '../widgets/control_deck.dart';
import '../widgets/control_deck/attack.dart';
import '../widgets/control_deck/military.dart';
import '../widgets/control_deck/rivals_chat.dart';
import '../widgets/control_deck/stats.dart';
import '../widgets/game_screen/solar_system.dart';
import '../widgets/game_screen/stats_bar.dart';
import '../widgets/gradient_dialog.dart';
import '../widgets/gradient_fab.dart';
import '/screens/game_end/game_lost.dart';
import '/widgets/control_deck/global_news.dart';
import 'attack/attack_screen.dart';

class GameScreen extends StatelessWidget {
  static const route = '/game-screen';
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-7540836345366849/5828468565',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
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

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statsBarHeight = _size.longestSide * 0.075;
    final double _controlDeckHeight = _size.height * 0.10;
    myBanner.load();
    final AdWidget adWidget = AdWidget(ad: myBanner);

    void _createInterstitialAd() {
      InterstitialAd.load(
          adUnitId: 'ca-app-pub-7540836345366849/4299215739',
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

    Future<bool> _quitGame() async {
      _showInterstitialAd();
      final res = await showGradientDialog(
          context: context,
          child: Column(
            children: [
              Text(
                'Silence sets in the universe.. as one of the big 4 ruler has decided to quit',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/img/ruler/${describeEnum(Provider.of<Player?>(context, listen: false)!.ruler)}.png',
                ),
              ),
              const Spacer(),
              Text(
                'You Serious ??',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes I am')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Na, I was joking')),
            ],
          ));
      if (res is bool) {
        return res;
      } else {
        return false;
      }
    }

    _createInterstitialAd();

    return WillPopScope(
      onWillPop: _quitGame,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const _NextTurnFAB(),
        bottomNavigationBar: ControlDeck(
          onPressed: (index) {
            switch (index) {
              case 0:
                showAttackMenu(context);
                return;
              case 1:
                showMilitaryMenu(context);
                return;
              case 2:
                showStatsMenu(context);
                return;
              case 3:
                showRivalsChatMenu(context);
                return;
            }
          },
          backgroundColor: Palette.deepBlue,
          notchedShape: const CircularNotchedRectangle(),
          showLabel: _controlDeckHeight < 48,
          height: _controlDeckHeight,
          iconSize: 48,
          items: [
            ControlDeckItem(text: 'Attack'),
            ControlDeckItem(text: 'Military'),
            ControlDeckItem(text: 'Stats'),
            ControlDeckItem(text: 'Rivals'),
          ],
        ),
        body: Column(
          children: [
            Container(
                alignment: Alignment.center,
                width: myBanner.size.width.toDouble(),
                height: myBanner.size.height.toDouble(),
                child: adWidget,
            ),
            ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: _statsBarHeight,
                    maxWidth: MediaQuery.of(context).size.width -
                        MediaQuery.of(context).viewPadding.right),
                child: StatsBar()),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height -
                      _controlDeckHeight -
                      _statsBarHeight -
                      MediaQuery.of(context).viewPadding.bottom,
                  maxWidth: MediaQuery.of(context).size.width -
                      MediaQuery.of(context).viewPadding.right),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SolarSystem(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _NextTurnFAB extends StatefulWidget {
  const _NextTurnFAB({
    Key? key,
  }) : super(key: key);

  @override
  __NextTurnFABState createState() => __NextTurnFABState();
}

class __NextTurnFABState extends State<_NextTurnFAB>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final _fabKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> showOverlay(String value) async {
    final _overlayState = Overlay.of(context)!;
    final _renderBox = _fabKey.currentContext!.findRenderObject()! as RenderBox;
    final offset = _renderBox.localToGlobal(Offset.zero);
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
          top: offset.dy - _renderBox.size.height / 2 - _animation.value * 60,
          left: offset.dx,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: 1 - _animation.value,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                )),
          )),
    );
    _animationController.addListener(() {
      _overlayState.setState(() {});
    });
    _overlayState.insert(_overlayEntry!);
    _animationController.forward();
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Game _game = Provider.of<Game>(context, listen: false);
    return SizedBox(
      height: 80,
      width: 80,
      key: _fabKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GradientFAB(
            onTap: () async {
              final oncomingAttack = _game.nextTurn();
              if (_game.lostGame) {
                // i.e If you reach day 0
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                }

                Navigator.of(context).pushNamed(GameLostScreen.route);
              } else {
                if (oncomingAttack != null) {
                  if (_overlayEntry != null) {
                    _overlayEntry!.remove();
                    _overlayEntry = null;
                  }
                  await showGradientDialog(
                      context: context,
                      child: Column(
                        children: [
                          Text(
                            'This is it.. they are finally making a move',
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                          Expanded(child: Container()),
                          Expanded(
                            flex: 2,
                            child: Image.asset(
                              'assets/img/ruler/${describeEnum(oncomingAttack['ruler']!)}.png',
                            ),
                          ),
                          Expanded(child: Container()),
                          Text(
                            'Get Ready to Fight !!',
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Yes I am')),
                        ],
                      ));
                  await Navigator.of(context)
                      .pushNamed(AttackScreen.route, arguments: {
                    'planet': oncomingAttack['planet'],
                    'attacker': _game
                        .playerFromRuler(oncomingAttack['ruler']! as Ruler),
                  });
                } else {
                  if (_game.galacticNews.isNotEmpty) {
                    await showGlobalNews(context);
                    _game.resetGalacticNews();
                  }
                  showOverlay('+${_game.currentPlayer.income}\$');
                }
              }
            },
            toolTip: 'Next Turn',
            image: 'assets/img/control_deck/next.svg'),
      ),
    );
  }
}
