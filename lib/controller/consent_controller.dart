import 'dart:async';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentController extends GetxController {
  var isConsentGiven = false.obs;
  var isConsentFormAvailable = false.obs;

  Future<void> initializeConsent() async {
    print("initial Consent ");
    final completer = Completer<void>();

    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        isConsentFormAvailable.value =
        await ConsentInformation.instance
            .isConsentFormAvailable();

        if (isConsentFormAvailable.value) {
          await _loadAndShowConsentFormIfRequired();
        }
        final status =
        await ConsentInformation.instance
            .getConsentStatus();

        isConsentGiven.value =
            status == ConsentStatus.obtained;

        completer.complete();
      },
          (FormError error) {
        isConsentGiven.value = false;
        completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() async {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired(
          (FormError? error) {
        completer.complete();
      },
    );

    return completer.future;
  }
}
