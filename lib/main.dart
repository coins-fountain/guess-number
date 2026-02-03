import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

import 'go_grey.dart';
import 'controller/ads_controller.dart';
import 'overlays/confettie_pieve_overlay.dart';
import 'overlays/guess_input_overlay/guess_input_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['88E54808B5CC70FD7D62D33C4B7F605B'],
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guess Number',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Baloo2',
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AdController(),permanent: true);
      }),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GoGrey();
    return GameWidget<GoGrey>(
      game: game,
      backgroundBuilder: (context) {
        return Container(color: Colors.white);
      },
      overlayBuilderMap: {
        'GuessInput': (context, game) =>
            GuessInputOverlay(game: game),
        'Confetti': (context, game) => ConfettiOverlay(
          onFinished: () {
            game.overlays.remove('Confetti');
          },
        ),
      },
    );
  }
}
