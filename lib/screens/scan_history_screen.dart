import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'edit_prizedraw_details.dart';
import '../services/api/api_service.dart';

class ScanHistoryScreen extends StatefulWidget {
  @override
  _ScanHistoryScreenState createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
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
        List<dynamic> history = await _apiService.getScanHistory(userId);

        setState(() {
          scanHistory = history;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
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
    String imageUrl = item['image_url'];
    String tag = item['tag_code'];
    String product = item['name'];
    String brand = item['brand'];
    bool isValid = item['is_valid'] == 1;
    String status = isValid ? 'ของแท้' : 'ไม่ใช่ของแท้';
    Color statusColor = isValid ? Colors.green : Colors.red;

    DateTime date = DateTime.parse(item['scan_date']);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  Text('Product: $product'),
                  Text('Brand: $brand'),
                  Text('Status: $status',
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold)),
                  Text('Date: $formattedDate'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditPrizedrawDetails(tagId: item['tag_id']),
                        ),
                      );
                    },
                    child: Text('Scan Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
