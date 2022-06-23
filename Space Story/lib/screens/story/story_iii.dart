import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rive/rive.dart';
import 'package:sizer/sizer.dart';

import '../welcome_screen.dart';
import '/utility/constants.dart';
import '/utility/utility.dart';

class StoryScreenIII extends StatefulWidget {
  static const route = '/story-iii-screen.dart';
  @override
  _StoryScreenIIIState createState() => _StoryScreenIIIState();
}

class _StoryScreenIIIState extends State<StoryScreenIII> {
  double _proceedButtonOpactity = 0.0;
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

  @override
  void dispose() {
    Utility.lockOrientation(); // unlocks rotation
    super.dispose();
  }

  final List<String> _dialogueList = [
    'To make sure only you get the Crystal',
    'You must take over all Planets',
    'According to rumours...',
    'The 3 other rulers saw the dream as well',
    'So they will try the same',
    'So get ready..',
    'Because your adventure has begun',
  ];

  @override
  void initState(){
    super.initState();
    myBanner.load();
  }

  Widget _skipButton() {
    return Positioned(
      right: 16.sp,
      bottom: 16.sp,
      child: AnimatedOpacity(
        duration: const Duration(seconds: 2),
        opacity: 1 - _proceedButtonOpactity,
        child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(WelcomeScreen.route);
            },
            child: const Text(
              'Skip',
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  Widget _proceedButton() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed(WelcomeScreen.route);
        },
        child: Container(
            height: 40.sp,
            width: 160.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Palette.maroon,
                borderRadius: BorderRadius.circular(50.sp)),
            child: const Text(
              'I am ready',
              style: TextStyle(fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  Widget _dialogue(Orientation orientation) {
    return Container(
      alignment: orientation == Orientation.landscape
          ? Alignment.center
          : Alignment.topCenter,
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 72.sp),
      child: AnimatedTextKit(
        animatedTexts: List.generate(
            _dialogueList.length,
            (index) => FadeAnimatedText(_dialogueList[index],
                textStyle: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center)),
        totalRepeatCount: 0,
        isRepeatingAnimation: false,
        onFinished: () {
          setState(() {
            _proceedButtonOpactity = 1.0;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);
    Widget _portrait() {
      return Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: 1 - _proceedButtonOpactity,
              child: _Planets(),
            ),
          ),
          _dialogue(Orientation.portrait),
          Align(
            child: AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: _proceedButtonOpactity,
              child: _proceedButton(),
            ),
          ),
          _skipButton(),
          Container(
            alignment: Alignment.center,
            width: myBanner.size.width.toDouble(),
            height: myBanner.size.height.toDouble(),
            child: adWidget,
          ),
        ],
      );
    }

    Widget _landscape() {
      return Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: 1 - _proceedButtonOpactity,
                  child: _Planets(),
                ),
              ),
              Expanded(child: _dialogue(Orientation.landscape)),
            ],
          ),
          Align(
            child: AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: _proceedButtonOpactity,
              child: _proceedButton(),
            ),
          ),
          _skipButton(),
          Container(
            alignment: Alignment.center,
            width: myBanner.size.width.toDouble(),
            height: myBanner.size.height.toDouble(),
            child: adWidget,
          ),
        ],
      );
    }

    final Orientation orientation = MediaQuery.of(context).orientation;
    return WillPopScope(
      onWillPop: () {
        Utility.lockOrientation(); // resets orientation to normal
        return Future.value(true);
      },
      child: Scaffold(
          backgroundColor: const Color(0xFF170C1E),
          body: orientation == Orientation.landscape
              ? _landscape()
              : _portrait()),
    );
  }
}

class _Planets extends StatefulWidget {
  @override
  __PlanetsState createState() => __PlanetsState();
}

class __PlanetsState extends State<_Planets> {
  Artboard? _riveArtboard;
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/animations/planet.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        artboard.addController(_controller = SimpleAnimation('Idle'));
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
        ? const SizedBox()
        : Rive(
            artboard: _riveArtboard!,
          );
  }
}
