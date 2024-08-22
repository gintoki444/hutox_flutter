import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class TagScanData {
  final String tagCode;
  final int scanCount;
  final int tagId;
  final String message;
  final String scanStatus;

  TagScanData(
      {required this.tagCode,
      required this.scanCount,
      required this.message,
      required this.tagId,
      required this.scanStatus});

  factory TagScanData.fromJson(Map<String, dynamic> json) {
    return TagScanData(
      tagCode: json['tagCode'] ?? 'Unknown', // ให้ค่าเริ่มต้นหากเป็น null
      scanCount: json['count'] ?? 0, // ให้ค่าเริ่มต้นหากเป็น null
      message: json['message'] ?? 'Unknown', // ให้ค่าเริ่มต้นหากเป็น null
      tagId: json['tagId'] ?? 0, // ให้ค่าเริ่มต้นหากเป็น null
      scanStatus: json['scanStatus'] ?? 'Unknown', // ให้ค่าเริ่มต้นหากเป็น null
    );
  }
}

class ApiService {
  // final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://asia-southeast1-tagsystem-2a343.cloudfunctions.net/apitag/api';
  final String baseUrl =
      'https://asia-southeast1-tagsystem-2a343.cloudfunctions.net/apitag/api';

  Future<Map<String, dynamic>?> getUserProfiles(String userId) async {
    final url = Uri.parse('$baseUrl/users/profile/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Handle errors here
      return null;
    }
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, String> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> getScanHistory(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/scanhistory/user/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load scan history');
    }
  }

  Future<List<dynamic>> getPrizeHistory(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/prizeDrawEntries/user/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load scan history');
    }
  }

  Future<Map<String, dynamic>?> getPrizeDrawDetails(int tagId) async {
    final url = Uri.parse('$baseUrl/prizeDrawDetails/tag/$tagId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> updatePrizeDrawDetails(
      String detailId, Map<String, String> data) async {
    final url = Uri.parse('$baseUrl/prizeDrawDetails/$detailId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>?> authenScan(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/authentications/scan');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> enterPrizeDetail(int tagId) async {
    final url = Uri.parse('$baseUrl/prizeDrawDetails');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'tag_id': tagId}),
    );

    return response.statusCode == 200;
  }

  Future<TagScanData> getTagScanData(String tagCode) async {
    final response =
        await http.get(Uri.parse('$baseUrl/scanLogs/count/$tagCode'));
    if (response.statusCode == 200) {
      return TagScanData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load scan count');
    }
  }
}
