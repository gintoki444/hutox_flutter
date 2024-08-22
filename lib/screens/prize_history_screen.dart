import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api/api_service.dart';

class PrizeHistoryScreen extends StatefulWidget {
  @override
  _PrizeHistoryScreenState createState() => _PrizeHistoryScreenState();
}

class _PrizeHistoryScreenState extends State<PrizeHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> scanHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchScanHistory();
  }

  Future<void> _fetchScanHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userIdInt = decodedToken['userId'];

      if (userIdInt != null) {
        String userId = userIdInt.toString();
        try {
          List<dynamic> history = await _apiService.getPrizeHistory(userId);

          setState(() {
            scanHistory = history;
          });
        } catch (e) {
          print('Error fetching prize history: $e');
          // จัดการข้อผิดพลาด เช่น แสดงข้อความเตือน
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prize History'),
      ),
      backgroundColor: Color(0xFFFF5128), // ตั้งค่าสีพื้นหลังของ Scaffold
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFF5128), // ตั้งค่าสีพื้นหลังของ Container
          child: Column(
            children: [
              SizedBox(height: 20.0), // เพิ่มระยะห่างด้านบน
              Image.asset(
                'assets/images/logo-hutox-new.png',
                height: 60.0, // ปรับขนาดโลโก้ตามความเหมาะสม
              ),
              SizedBox(height: 40.0),
              Align(
                alignment: Alignment.centerLeft, // จัดตำแหน่งข้อความให้ชิดซ้าย
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Prize History',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0), // เพิ่มระยะห่างระหว่างโลโก้และเนื้อหา
              scanHistory.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap:
                          true, // ใช้ shrinkWrap เพื่อให้ ListView ใช้ขนาดที่เหมาะสม
                      physics:
                          NeverScrollableScrollPhysics(), // ปิดการ scroll ของ ListView เพราะใช้ SingleChildScrollView แทน
                      itemCount: scanHistory.length,
                      itemBuilder: (context, index) {
                        final item = scanHistory[index];
                        return _buildScanHistoryItem(item);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanHistoryItem(dynamic item) {
    print('item: ' + item.toString()); // ใช้ toString() แทน

    // ตรวจสอบและดึงข้อมูลจาก item
    String imageUrl =
        item['image_link'] ?? ''; // ใช้ ?? เพื่อป้องกันกรณีค่าที่เป็น null
    String tag = item['tag_code'] ?? '';
    String product = item['name'] ?? '';

    // แปลงวันที่
    DateTime date;
    try {
      date = DateTime.parse(item['entry_date']);
    } catch (e) {
      print('Date parsing error: $e');
      date = DateTime.now(); // หรือใช้ค่าเริ่มต้นอื่นๆ
    }
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tag: $tag',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Scan Date: $formattedDate'),
                  Text('Product: $product'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
