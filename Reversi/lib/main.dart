import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, SystemUiMode;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'game_board.dart';
import 'game_model.dart';
import 'move_finder.dart';
import 'styling.dart';
import 'thinking_indicator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(FlutterFlipApp());
}

class FlutterFlipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      color: Color(0xffffffff), // Mandatory background color.
      onGenerateRoute: (settings) {
        return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => GameScreen(),
        );
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  State createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final StreamController<GameModel> _userMovesController =
      StreamController<GameModel>();
  final StreamController<GameModel> _restartController =
      StreamController<GameModel>();
  Stream<GameModel>? _modelStream;
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-7540836345366849/6445176545',
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


  _GameScreenState() {
    _modelStream = StreamGroup.merge([
      _userMovesController.stream,
      _restartController.stream,
    ]).asyncExpand((model) async* {
      yield model;

      var newModel = model;

      while (newModel.player == PieceType.white) {
        final finder = MoveFinder(newModel.board);
        final move = await finder.findNextMove(newModel.player, 5);
        if (move != null) {
          newModel = newModel.updateForMove(move.x, move.y);
          yield newModel;
        }
      }
    });
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-7540836345366849/8734344256',
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

  @override
  void dispose() {
    _userMovesController.close();
    _restartController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myBanner.load();
    _createInterstitialAd();
    return StreamBuilder<GameModel>(
      stream: _modelStream,
      builder: (context, snapshot) {
        return _buildWidgets(
          context,
          snapshot.hasData ? snapshot.data! : GameModel(board: GameBoard()),
        );
      },
    );
  }

  void _attemptUserMove(GameModel model, int x, int y) {
    if (model.player == PieceType.black &&
        model.board.isLegalMove(x, y, model.player)) {
      _userMovesController.add(model.updateForMove(x, y));
    }
  }

  Widget _buildScoreBox(PieceType player, GameModel model) {
    var label = player == PieceType.black ? 'black' : 'white';
    var scoreText = player == PieceType.black
        ? '${model.blackScore}'
        : '${model.whiteScore}';

    return DecoratedBox(
      decoration: (model.player == player)
          ? Styling.activePlayerIndicator
          : Styling.inactivePlayerIndicator,
      child: Column(
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: Styling.scoreLabelText,
          ),
          Text(
            scoreText,
            textAlign: TextAlign.center,
            style: Styling.scoreText,
          )
        ],
      ),
    );
  }

  List<Widget> _buildGameBoardDisplay(BuildContext context, GameModel model) {
    final rows = <Widget>[];

    for (var y = 0; y < GameBoard.height; y++) {
      final spots = <Widget>[];

      for (var x = 0; x < GameBoard.width; x++) {
        spots.add(AnimatedContainer(
          duration: Duration(
            milliseconds: 500,
          ),
          margin: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            gradient:
                Styling.pieceGradients[model.board.getPieceAtLocation(x, y)],
          ),
          child: SizedBox(
            width: 40.0,
            height: 40.0,
            child: GestureDetector(
              onTap: () {
                _attemptUserMove(model, x, y);
              },
            ),
          ),
        ));
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: spots,
      ));
    }

    return rows;
  }

  // Builds out the Widget tree using the most recent GameModel from the stream.
  Widget _buildWidgets(BuildContext context, GameModel model) {
    final AdWidget adWidget = AdWidget(ad: myBanner);

    return Container(
      padding: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Styling.backgroundStartColor,
            Styling.backgroundFinishColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: adWidget,
              width: myBanner.size.width.toDouble(),
              height: myBanner.size.height.toDouble(),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                _buildScoreBox(PieceType.black, model),
                Spacer(flex: 4),
                _buildScoreBox(PieceType.white, model),
                Spacer(flex: 1),
              ],
            ),
            SizedBox(height: 20),
            ThinkingIndicator(
              color: Styling.thinkingColor,
              height: Styling.thinkingSize,
              visible: model.player == PieceType.white,
            ),
            SizedBox(height: 20),
            ..._buildGameBoardDisplay(context, model),
            SizedBox(height: 30),
            if (model.gameIsOver)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    child: Text(
                      model.gameResultString,
                      style: Styling.resultText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showInterstitialAd();
                      _restartController.add(GameModel(board: GameBoard()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xe0ffffff)),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(15.0))),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 15.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'new game',
                          style: Styling.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    _restartController.add(
                      GameModel(board: GameBoard()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xe0ffffff)),
                        borderRadius:
                        BorderRadius.all(const Radius.circular(15.0))),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 15.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        'give up',
                        style: Styling.buttonText,
                      ),
                    ),
                  ),
                )
              )
          ],
        ),
      ),
    );
  }
}
