import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<bool> ffmpegAvailable() async {
  if (Platform.isAndroid || Platform.isIOS) return false;
  try {
    final r = await Process.run('ffmpeg', ['-version']);
    return r.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<Uint8List> runFfmpeg({
  required Uint8List input,
  required String inputName,
  required String outputName,
  required List<String> args,
}) async {
  final base = await getTemporaryDirectory();
  final dir = await base.createTemp('lesson_ffmpeg_');
  try {
    await File('${dir.path}/$inputName').writeAsBytes(input, flush: true);
    final r = await Process.run('ffmpeg', args, workingDirectory: dir.path);
    if (r.exitCode != 0) {
      throw Exception('עיבוד השמע נכשל: ${r.stderr}');
    }
    return Uint8List.fromList(
      await File('${dir.path}/$outputName').readAsBytes(),
    );
  } finally {
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
