import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

@JS('window')
external JSObject get _jsWindow;

Future<bool> ffmpegAvailable() async {
  try {
    final bridge = _jsWindow.getProperty<JSObject?>('lessonFfmpeg'.toJS);
    if (bridge == null) return false;
    final promise = bridge.callMethod<JSPromise<JSBoolean>?>('available'.toJS);
    if (promise == null) return false;
    final result = await promise.toDart;
    return result.toDart;
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
  try {
    final bridge = _jsWindow.getProperty<JSObject?>('lessonFfmpeg'.toJS);
    if (bridge == null) {
      throw StateError('lessonFfmpeg bridge is not available');
    }

    final jsArgs = args.map((a) => a.toJS).toList().toJS;
    final promise = bridge.callMethod<JSPromise<JSAny>?>(
      'run'.toJS,
      input.toJS,
      inputName.toJS,
      outputName.toJS,
      jsArgs,
    );
    if (promise == null) {
      throw StateError('lessonFfmpeg.run returned null');
    }

    final output = await promise.toDart;
    if (output is JSUint8Array) {
      return output.toDart;
    }

    final outputObj = output as JSObject;
    final lengthJs = outputObj.getProperty<JSNumber?>('length'.toJS);
    final length = lengthJs?.toDartInt ?? 0;
    return Uint8List.fromList(
      List<int>.generate(length, (index) {
        final val = outputObj.getProperty<JSNumber?>(index.toString().toJS);
        return val?.toDartInt ?? 0;
      }, growable: false),
    );
  } catch (error) {
    throw Exception('עיבוד השמע נכשל: $error');
  }
}
