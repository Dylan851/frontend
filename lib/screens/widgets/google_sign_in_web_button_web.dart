import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

Widget buildGoogleWebSignInButton() {
  return google_web.renderButton(
    configuration: google_web.GSIButtonConfiguration(
      text: google_web.GSIButtonText.continueWith,
      theme: google_web.GSIButtonTheme.outline,
      size: google_web.GSIButtonSize.large,
      shape: google_web.GSIButtonShape.rectangular,
      minimumWidth: 340,
      locale: 'es',
    ),
  );
}
