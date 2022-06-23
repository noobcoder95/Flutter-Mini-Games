import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:plants_vs_zombie/Constant/assets.dart';
import 'package:plants_vs_zombie/Utils/audio_player.dart';
import 'package:plants_vs_zombie/routes.dart';

class GameOver extends StatelessWidget {
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

  _playSound() async {
    await AudioPlayer.playSound(Assets.game_over);
  }

  @override
  Widget build(BuildContext context) {
    final int score = ModalRoute.of(context)?.settings.arguments as int;
    _playSound();
    _createInterstitialAd();

    return Material(
      child: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Game Over",
                style: GoogleFonts.pressStart2p(
                    fontSize: 35.0, color: Colors.white),
              ),
              SizedBox(height: 25.0),
              Text(
                "Score: ${score}",
                style: GoogleFonts.pressStart2p(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: MaterialButton(
                  color: Colors.red,
                  child: Text(
                    "Play Again",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    _showInterstitialAd();
                    Navigator.pushNamedAndRemoveUntil(
                        context, Routes.home, (route) => false);
                  },
                ),
              ),
            ],
          ),
          color: Colors.black.withOpacity(0.6),
        ),
      ),
    );
  }
}
