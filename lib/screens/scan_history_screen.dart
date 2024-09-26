import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'edit_prizedraw_details.dart';
import '../services/api/api_service.dart';
import '../components/richtext.dart';

class ScanHistoryScreen extends StatefulWidget {
  @override
  _ScanHistoryScreenState createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> scanHistory = [];
  bool _isLoading = true; // เพิ่มตัวแปรสำหรับเก็บสถานะการโหลด

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
          _isLoading = false; // ตั้งค่าให้หยุดแสดงการโหลดเมื่อได้ข้อมูลแล้ว
        });
      }
    } else {
      setState(() {
        _isLoading = false; // ตั้งค่าให้หยุดแสดงการโหลดในกรณีที่ไม่มี token
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
      ),
      backgroundColor: Color(0xFFEF4D23), // ตั้งค่าสีพื้นหลังของ Scaffold
      body: SingleChildScrollView(
        child: Align(
          alignment:
              Alignment.topCenter, // จัดตำแหน่งที่กึ่งกลางในแนวนอนและชิดด้านบน
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500, // กำหนด max-width
            ),
            padding: EdgeInsets.all(10),
            color: Color(0xFFEF4D23), // ตั้งค่าสีพื้นหลังของ Container
            child: Column(
              children: [
                SizedBox(height: 40.0), // เพิ่มระยะห่างด้านบน
                Image.asset(
                  'assets/images/logo-hutox-new.png',
                  height: 70.0, // ปรับขนาดโลโก้ตามความเหมาะสม
                ),
                SizedBox(height: 30.0), // เพิ่มระยะห่างระหว่างโลโก้และเนื้อหา
                _isLoading
                    ? CircularProgressIndicator()
                    : scanHistory.isEmpty
                        ? Column(
                            children: [
                              SizedBox(
                                  height:
                                      20.0), // เพิ่มระยะห่างระหว่างโลโก้และข้อความ
                              Text(
                                'ไม่มีข้อมูล',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
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
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      color: Colors.white,
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
                  RichTexts(
                    label: 'แท็ก',
                    value: tag,
                    // labelColor: Colors.blue, // กำหนดสีสำหรับ label
                    // valueColor: Colors.red, // กำหนดสีสำหรับ value
                  ),
                  RichTexts(
                    label: 'สินค้า',
                    value: product,
                  ),
                  RichTexts(
                    label: 'แบรนด์',
                    value: brand,
                  ),
                  RichTexts(
                    label: 'สถานะ',
                    value: status,
                    valueColor: statusColor,
                  ),
                  RichTexts(
                    label: 'วันที่',
                    value: formattedDate,
                  ),
                  SizedBox(height: 10),
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
                    child: Text('ข้อมูลลงทะเบียน'),
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
