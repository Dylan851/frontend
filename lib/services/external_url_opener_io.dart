import 'dart:io';

Future<bool> openExternalUrl(String url) async {
  try {
    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', '', url], runInShell: true);
      return true;
    }
    if (Platform.isMacOS) {
      await Process.start('open', [url], runInShell: true);
      return true;
    }
    if (Platform.isLinux) {
      await Process.start('xdg-open', [url], runInShell: true);
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}
