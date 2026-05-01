import 'dart:html' as html;

Future<bool> openExternalUrl(String url) async {
  html.window.location.assign(url);
  return true;
}
