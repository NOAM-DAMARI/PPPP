import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> createMediaObjectUrl(Uint8List bytes, String mime) async {
  final blob = html.Blob([bytes], mime);
  return html.Url.createObjectUrlFromBlob(blob);
}

void revokeMediaObjectUrl(String url) => html.Url.revokeObjectUrl(url);

Future<void> downloadBytes(Uint8List bytes, String name, String mime) async {
  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = name
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

/// הורדת קובץ מכתובת (בלי לטעון לזיכרון) – פותח קישור הורדה בדפדפן
Future<void> openDownloadUrl(String url, String name) async {
  final anchor = html.AnchorElement(href: url)
    ..download = name
    ..target = '_blank'
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
