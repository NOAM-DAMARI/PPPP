import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'audio_processing_engine_stub.dart'
    if (dart.library.js_interop) 'audio_processing_engine_web.dart'
    if (dart.library.io) 'audio_processing_engine_io.dart' as engine;

/// עיבוד שמע (חיתוך + הפחתת רעש) עם FFmpeg.
/// בדפדפן: ffmpeg.wasm (נטען לפי דרישה). במחשב: קובץ ffmpeg מותקן במערכת.
class AudioProcessingService {
  static Future<bool> isAvailable() => engine.ffmpegAvailable();

  static Future<Uint8List> exportM4a({
    required Uint8List sourceBytes,
    required String sourceName,
    required double startSeconds,
    required double endSeconds,
    required bool reduceNoise,
    double noiseReductionDb = 18,
  }) async {
    if (sourceBytes.isEmpty) throw Exception('קובץ המקור ריק');
    if (startSeconds < 0 || endSeconds <= startSeconds) {
      throw Exception('טווח החיתוך אינו תקין');
    }
    if (kIsWeb && sourceBytes.lengthInBytes > 80 * 1024 * 1024) {
      throw Exception('בדפדפן אפשר לעבד קבצים עד 80 MB.');
    }
    if (!await engine.ffmpegAvailable()) {
      throw Exception(
          'FFmpeg לא זמין במכשיר הזה. במחשב יש להתקין ffmpeg; בדפדפן נדרש חיבור לאינטרנט.');
    }
    final ext = _extension(sourceName);
    final args = <String>[
      '-hide_banner', '-y',
      '-i', 'input.$ext',
      '-ss', startSeconds.toStringAsFixed(3),
      '-t', (endSeconds - startSeconds).toStringAsFixed(3),
      if (reduceNoise) ...[
        '-af',
        'afftdn=nr=${noiseReductionDb.clamp(0.0, 30.0).toDouble().toStringAsFixed(1)}:nf=-25:tn=1',
      ],
      '-vn', '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart',
      'output.m4a',
    ];
    return engine.runFfmpeg(
        input: sourceBytes, inputName: 'input.$ext', outputName: 'output.m4a', args: args);
  }

  static String _extension(String name) {
    final ext = name.split('.').last.toLowerCase();
    return const {'mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg'}.contains(ext) ? ext : 'mp3';
  }
}
