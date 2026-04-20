import 'dart:io';

class AppLinks {
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String shareWebsiteUrl = 'https://example.com/home-fitness';
  static const String androidPackageName = 'com.example.homeFitness';
  static const String iOSAppStoreId = '0000000000';

  static String get rateAppUrl {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/app/id$iOSAppStoreId?action=write-review';
    }
    return 'https://play.google.com/store/apps/details?id=$androidPackageName';
  }

  static String get shareMessage {
    return 'Check out Home Fitness: $shareWebsiteUrl';
  }
}
