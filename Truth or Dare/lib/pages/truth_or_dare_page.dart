import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:truth_or_dare/domain/truth_or_dare.dart';
import 'package:truth_or_dare/pages/truth_or_dare_ui_extension.dart';
import 'package:truth_or_dare/domain/truth_or_dare_data_source.dart';
import 'package:truth_or_dare/shared/theme/dims.dart';
import 'package:truth_or_dare/shared/theme/images.dart';
import 'package:truth_or_dare/shared/theme/typography.dart';
import 'package:truth_or_dare/widgets/truth_or_dare_tile.dart';

import '../shared/theme/colors.dart';

const Duration _hideAnimationTimerDuration = Duration(milliseconds: 500);
const Duration _animationDuration = Duration(seconds: 1);
const double _alignmentCenter = 0;
const double _horizontalTextAlignmentHidden = -6;
const double _popButtonHorizontalAlignmentHidden = -2;
const double _popButtonHorizontalAlignmentVisible = -0.8;
const double _nextButtonHorizontalAlignmentHidden = 3;
const double _nextButtonHorizontalAlignmentVisible = 0.8;
const double _imageHorizontalAlignmentHidden = 5;
const double _questionTextHorizontalAlignmentHidden = -6;
const double _popButtonVerticalAlignment = -0.95;
const double _nextButtonVerticalAlignment = 0.95;
const double _questionTextWidthFactor = 2 / 3;

class TruthOrDarePage extends StatefulWidget {
  final TruthOrDare truthOrDare;
  final TruthOrDareGenerator truthOrDareDataSource;

  const TruthOrDarePage(this.truthOrDare, this.truthOrDareDataSource);

  @override
  _TruthOrDarePageState createState() => _TruthOrDarePageState();
}

class _TruthOrDarePageState extends State<TruthOrDarePage> {
  Timer? _timer;
  double _horizontalImageAlignment = _alignmentCenter;
  double _horizontalTextAlignment = _questionTextHorizontalAlignmentHidden;
  double _popButtonHorizontalAlignment = _popButtonHorizontalAlignmentHidden;
  double _nextButtonHorizontalAlignment = _nextButtonHorizontalAlignmentHidden;
  Curve? _curve;
  Curve _textCurve = Curves.elasticOut;
  bool _popping = false;
  bool _changeQuestion = false;
  String _text = "";

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-7540836345366849/3320589252',
    size: AdSize.fullBanner,
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

  @override
  void initState() {
    super.initState();
    _initializeHideTimer();
    myBanner.load();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);

    return WillPopScope(
        onWillPop: () async {
          _prepareForPop(); // Action to perform on back pressed
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                color: _getColor(),
              ),
              AnimatedAlign(
                duration: _animationDuration,
                alignment: Alignment(_horizontalImageAlignment, _alignmentCenter),
                curve: _curve ?? Curves.elasticIn,
                onEnd: _onImageAnimationEnd,
                child: ImageAndText(
                  widget.truthOrDare,
                  Curves.linear,
                  MediaQuery.of(context).size.height,
                ),
              ),
              AnimatedAlign(
                duration: _animationDuration,
                alignment: Alignment(_horizontalTextAlignment, _alignmentCenter),
                curve: _textCurve,
                onEnd: _onTextAnimationEnd,
                child: FractionallySizedBox(
                  widthFactor: _questionTextWidthFactor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.truthOrDare.nameImage,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: Dim.d40),
                      Text(
                        _text,
                        style: AppTypography.semiBold30,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: AnimatedAlign(
                  duration: _animationDuration,
                  curve: _textCurve,
                  alignment: Alignment(_popButtonHorizontalAlignment, _popButtonVerticalAlignment),
                  child: GestureDetector(
                    onTap: _prepareForPop,
                    child: Container(
                      alignment: Alignment.center,
                      child: adWidget,
                      width: myBanner.size.width.toDouble(),
                      height: myBanner.size.height.toDouble(),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: AnimatedAlign(
                  duration: _animationDuration,
                  curve: _textCurve,
                  alignment: Alignment(_nextButtonHorizontalAlignment, _nextButtonVerticalAlignment),
                  child: GestureDetector(
                    onTap: _showNext,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("NEXT", style: AppTypography.extraBold24),
                        const SizedBox(width: Dim.d16),
                        Image.asset(Images.nextArrow),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  void _initializeHideTimer() {
    _timer = Timer(_hideAnimationTimerDuration, () {
      setState(() {
        _horizontalImageAlignment = _imageHorizontalAlignmentHidden;
      });
    });
  }

  void _onImageAnimationEnd() {
    if (!_popping) {
      _text = _getQuestion();
      _showText();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showText() {
    setState(() {
      _horizontalTextAlignment = _alignmentCenter;
    });
  }

  void _onTextAnimationEnd() {
    if (_popping) return;
    _showButtons();
    if (_changeQuestion) {
      _text = _getQuestion();
      _showText();
      _changeQuestion = false;
    }
  }

  void _showButtons() {
    setState(() {
      _popButtonHorizontalAlignment = _popButtonHorizontalAlignmentVisible;
      _nextButtonHorizontalAlignment = _nextButtonHorizontalAlignmentVisible;
    });
  }

  void _prepareForPop() {
    _popping = true;
    setState(() {
      _textCurve = Curves.elasticOut;
      _curve = Curves.elasticOut;
      _horizontalImageAlignment = _alignmentCenter;
      _horizontalTextAlignment = _questionTextHorizontalAlignmentHidden;
      _popButtonHorizontalAlignment = _popButtonHorizontalAlignmentHidden;
      _nextButtonHorizontalAlignment = _nextButtonHorizontalAlignmentHidden;
    });
    _showInterstitialAd();
  }

  void _showNext() {
    _changeQuestion = true;
    setState(() {
      _horizontalTextAlignment = _horizontalTextAlignmentHidden;
    });
  }

  Color _getColor() => widget.truthOrDare == TruthOrDare.truth ? AppColors.blueBackground : AppColors.redBackground;

  String _getQuestion() => widget.truthOrDare == TruthOrDare.truth
      ? widget.truthOrDareDataSource.getQuestion()
      : widget.truthOrDareDataSource.getDare();

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-7540836345366849/8189772553',
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
}
