import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:guess_number_game/controller/consent_controller.dart';
import 'package:guess_number_game/game/guess_number_game.dart';
import 'package:guess_number_game/overlays/confettie_piece_overlay.dart';
import 'package:guess_number_game/overlays/guess_game_input_overlay/guess_game_input_overlay.dart';
import 'controller/ads_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final consentController =
  Get.put(ConsentController(), permanent: true);

  await consentController.initializeConsent();

  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      testDeviceIds: [],
    ),
  );

  await MobileAds.instance.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guess Number',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Baloo2', useMaterial3: true, brightness: Brightness.light),
      initialBinding: BindingsBuilder(() {
        Get.put(AdController(), permanent: true);
      }),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GuessNumberGame();
    return GameWidget<GuessNumberGame>(
      game: game,
      backgroundBuilder: (context) {
        return Container(color: Colors.white);
      },
      overlayBuilderMap: {
        'GuessInput': (context, game) => GuessInputOverlay(game: game),
        'Confetti': (context, game) => ConfettiOverlay(
          onFinished: () {
            game.overlays.remove('Confetti');
          },
        ),
      },
    );
  }
}
