import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

Future<bool> ffmpegAvailable() async {
  try {
    final bridge = js_util.getProperty<Object>(html.window, 'lessonFfmpeg');
    final promise = js_util.callMethod<Object>(bridge, 'available', const []);
    return await js_util.promiseToFuture<bool>(promise);
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
    final bridge = js_util.getProperty<Object>(html.window, 'lessonFfmpeg');
    final promise = js_util.callMethod<Object>(bridge, 'run', [
      input,
      inputName,
      outputName,
      js_util.jsify(args),
    ]);
    final output = await js_util.promiseToFuture<Object>(promise);
    final length = js_util.getProperty<int>(output, 'length');
    return Uint8List.fromList(
      List<int>.generate(
        length,
        (index) => js_util.getProperty<int>(output, index),
        growable: false,
      ),
    );
  } catch (error) {
    throw Exception('עיבוד השמע נכשל: $error');
  }
}
