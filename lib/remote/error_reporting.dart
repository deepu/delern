import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';

// Error reporting inspired by https://github.com/yjbanov/crashy/.

SentryClient _sentry;

Future<Null> reportError(String src, dynamic error, dynamic stackTrace) async {
  debugPrint('/!\\ /!\\ /!\\ Caught error in $src: $error');

  if (_sentry == null) {
    String environment = 'production';
    assert(() {
          environment = 'dev';
          return true;
        }() !=
        null);

    var packageInfo = await PackageInfo.fromPlatform();
    var environmentAttributes = Event(
      release: '${packageInfo.version} (${packageInfo.buildNumber})',
      environment: environment,
    );
    _sentry = SentryClient(
        dsn: "https://36d72a65344d439d86ee65d623d050ce:" +
            "038b2b2aa94f474db45ce1c4676b845e@sentry.io/305345",
        environmentAttributes: environmentAttributes);
  }

  if (_sentry.environmentAttributes.environment == 'dev') {
    debugPrint(
        'Stack trace follows on the next line:\n$stackTrace\n${'-' * 80}');
  }

  print('Reporting to Sentry.io...');
  final SentryResponse response = await _sentry.capture(
      event: Event(
    exception: error,
    stackTrace: stackTrace,
    loggerName: src,
  ));
  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}
