Future<bool> startCameraFeed(
    Object videoElement, Object canvasElement, int interval) {
  throw UnsupportedError("Camera feed is only supported on the web.");
}

void stopCameraFeed() {
  throw UnsupportedError("Camera feed is only supported on the web.");
}

String getQRCode() {
  throw UnsupportedError("QR code reading is only supported on the web.");
}
