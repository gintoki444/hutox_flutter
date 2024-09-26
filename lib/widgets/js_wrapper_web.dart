// js_wrapper_web.dart
@JS()
library camera;

import 'package:js/js.dart';
import 'dart:js_util';

@JS('startCameraFeed')
external dynamic _startCameraFeed(
    Object videoElement, Object canvasElement, int interval);

Future<bool> startCameraFeed(
        Object videoElement, Object canvasElement, int interval) =>
    promiseToFuture(_startCameraFeed(videoElement, canvasElement, interval));

@JS('stopCameraFeed')
external void stopCameraFeed();

@JS('getQRCode')
external String getQRCode();
