import 'package:SnakeGameFlutter/game_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatelessWidget {
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-7540836345366849/1650562166',
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

  @override
  Widget build(BuildContext context) {
    myBanner.load();

    final AdWidget adWidget = AdWidget(ad: myBanner);

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: adWidget,
              width: myBanner.size.width.toDouble(),
              height: myBanner.size.height.toDouble(),
            ),
            SizedBox(height: 50),
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/snake_game.jpg'),
            ),

            SizedBox(height: 50.0),

            Text('Welcome to Snake Xenzia', style: TextStyle(color: Colors.white, fontSize: 40.0, fontWeight: FontWeight.w900), textAlign: TextAlign.center),

        ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          elevation: 20,
          label: Text(
              'Start the Game...',
            style: TextStyle(),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => GamePage()));
          },
          icon: Icon(Icons.play_circle_filled, color: Colors.white, size: 30.0),
      ),
    );
  }
}