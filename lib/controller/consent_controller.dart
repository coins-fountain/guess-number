import 'dart:async';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentController extends GetxController {
  var isConsentGiven = false.obs;
  var isConsentRequired = false.obs;
  var isRequestLocationInEeaOrUk = false.obs;
  Future<void> initializeConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        final status =
        await ConsentInformation.instance.getConsentStatus();

        isConsentGiven.value =
            status == ConsentStatus.obtained;

        isConsentRequired.value =
            status == ConsentStatus.required;
        final inEeaOrUk =
        await ConsentInformation.instance
            .isConsentFormAvailable();

        isRequestLocationInEeaOrUk.value = inEeaOrUk;

        completer.complete();
      },
          (FormError error) {
        completer.complete();
      },
    );

    return completer.future;
  }

  Future<void> showConsentFlow() async {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired(
          (FormError? error) async {
        final status =
        await ConsentInformation.instance.getConsentStatus();

        isConsentGiven.value =
            status == ConsentStatus.obtained;

        isConsentRequired.value =
            status == ConsentStatus.required;

        completer.complete();
      },
    );

    return completer.future;
  }

  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();

    ConsentForm.showPrivacyOptionsForm(
          (FormError? error) async {
        final status =
        await ConsentInformation.instance.getConsentStatus();

        isConsentGiven.value =
            status == ConsentStatus.obtained;

        completer.complete();
      },
    );

    return completer.future;
  }
}

