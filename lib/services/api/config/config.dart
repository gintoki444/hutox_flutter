import 'package:flutter/foundation.dart'; // เพิ่มการนำเข้านี้
import 'package:flutter_dotenv/flutter_dotenv.dart';

// config.dart
final String baseUrl = kIsWeb
    ? 'https://asia-southeast1-tagsystem-2a343.cloudfunctions.net/apitag/api'
    : dotenv.env['HUTOX_APP_API_URL'] ?? '';
