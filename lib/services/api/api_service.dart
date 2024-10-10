import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // เพิ่มการนำเข้านี้

class TagScanData {
  final String tagCode;
  final int scanCount;
  final int tagId;
  final String message;
  final String scanStatus;

  final int productId;
  final int user_id;
  final String name;
  final String brand;
  final String manufacturer;
  final String createdAt;
  final int prizeId;
  final String imageUrl;

  TagScanData({
    required this.tagCode,
    required this.scanCount,
    required this.message,
    required this.tagId,
    required this.scanStatus,
    required this.productId,
    required this.user_id,
    required this.name,
    required this.brand,
    required this.manufacturer,
    required this.createdAt,
    required this.prizeId,
    required this.imageUrl,
  });

  factory TagScanData.fromJson(Map<String, dynamic> json) {
    return TagScanData(
      tagCode: json['tagCode'] ?? 'Unknown', // ให้ค่าเริ่มต้นหากเป็น null
      scanCount: json['count'] ?? 0, // ให้ค่าเริ่มต้นหากเป็น null
      message: json['message'] ?? 'Unknown', // ให้ค่าเริ่มต้นหากเป็น null
      tagId: json['tagId'] ?? 0, // ให้ค่าเริ่มต้นหากเป็น null
      scanStatus: json['scanStatus'] ?? 'Unknown', // ให้ค่าเริ่มต้นหากเป็น null
      user_id: json['productDetails']['user_id'] ?? 0,
      productId: json['productDetails']['product_id'] ??
          0, // ดึงข้อมูลจาก productDetails
      name: json['productDetails']['name'] ?? 'Unknown',
      brand: json['productDetails']['brand'] ?? 'Unknown',
      manufacturer: json['productDetails']['manufacturer'] ?? 'Unknown',
      createdAt: json['productDetails']['created_at'] ?? 'Unknown',
      prizeId: json['productDetails']['prize_id'] ?? 0,
      imageUrl: json['productDetails']['image_url'] ?? 'Unknown',
    );
  }
}

class ApiService {
  // final String baseUrl = dotenv.env['HUTOX_APP_API_URL'] ?? '';
  final String baseUrl = kIsWeb
      ? 'https://asia-southeast1-tagsystem-2a343.cloudfunctions.net/apitag/api'
      : dotenv.env['HUTOX_APP_API_URL'] ?? '';

  Future<Map<String, dynamic>?> checkLogin(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print('Error decoding response: $e');
        return {
          'message': 'An error occurred while processing the response',
        };
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        // ตรวจสอบว่า message ไม่เป็น null และเป็น String
        final message =
            errorData['message']?.toString() ?? 'An unknown error occurred';
        print(message); // แสดงใน console
        return {
          'message': message, // ส่งกลับค่า message เพื่อแสดงผล
        };
      } catch (e) {
        print('Error decoding error response: $e');
        return {
          'message': 'An error occurred while processing the error response',
        };
      }
    }
  }

  // Future<Map<String, dynamic>?> checkLogin(Map<String, dynamic> data) async {
  //   final url = Uri.parse('$baseUrl/users/login');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(data),
  //   );

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = '$baseUrl/users/register';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'username': name,
      'email': email,
      'password': password,
    });

    print(body);

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201) {
      // หรือ 200 ถ้า API เปลี่ยนกลับมาใช้ status code 200
      return json.decode(response.body); // ส่งข้อมูล response กลับไป
    } else {
      throw Exception(
          json.decode(response.body)['message'] ?? 'Registration failed');
    }
  }

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

  Future<Map<String, dynamic>> resetPassword(
      int userId, String newPassword) async {
    final url = '$baseUrl/users/admin/reset-password';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'userId': userId,
      'newPassword': newPassword,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reset password');
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

  Future<bool> enterPrizeDrawEntries(int tagId, int prizeId, int userId) async {
    final url = Uri.parse('$baseUrl/prizeDrawEntries');
    print('tagId :$tagId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'tagId': tagId, 'prizeId': prizeId, 'userId': userId}),
    );

    return response.statusCode == 200;
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

  Future<TagScanData> getTagUserScanData(String tagCode) async {
    final response =
        await http.get(Uri.parse('$baseUrl/scanLogs/count2/$tagCode'));
    if (response.statusCode == 200) {
      return TagScanData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load scan count');
    }
  }

  Future<Map<String, dynamic>> reActivate(String email) async {
    final url = Uri.parse('$baseUrl/users/resend-activation');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // ค่าที่คืนกลับเมื่อทำงานสำเร็จ
    } else {
      // แสดงรายละเอียดของข้อผิดพลาดใน console
      print('Request failed with status: ${response.statusCode}');
      print('url: ${url}');
      print('Response body: ${response.body}');
      return {'error': 'Failed to re-activate account: ${response.statusCode}'};
    }
  }

  Future<bool> deleteUserByid(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        print("User and profile deleted successfully");
        return true; // ส่งกลับ true เมื่อการลบสำเร็จ
      } else {
        print("Failed to delete user: ${response.statusCode}");
        print("Response body: ${response.body}");

        // ตรวจสอบข้อมูลใน response.body และแสดงผลลัพธ์เพิ่มเติมได้ที่นี่
        return false; // ส่งกลับ false เมื่อการลบไม่สำเร็จ
      }
    } catch (e) {
      print("Error occurred while deleting user: $e");
      return false; // ส่งกลับ false เมื่อเกิดข้อผิดพลาด
    }
  }
}
