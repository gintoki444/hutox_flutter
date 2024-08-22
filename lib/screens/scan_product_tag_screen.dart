import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api/api_service.dart';
import 'edit_prizedraw_details.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScanProductTagScreen extends StatefulWidget {
  @override
  _ScanProductTagScreenState createState() => _ScanProductTagScreenState();
}

class _ScanProductTagScreenState extends State<ScanProductTagScreen> {
  final ApiService _apiService = ApiService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/scan-bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: <Widget>[
              SizedBox(height: 60.0),
              Center(
                child: Image.asset(
                  'assets/images/logo-hutox-new.png',
                  height: 60.0,
                ),
              ),
              SizedBox(height: 40.0),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 2,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Colors.white,
                        borderRadius: 10,
                        borderLength: 50,
                        borderWidth: 10,
                        cutOutSize: MediaQuery.of(context).size.width * 0.7,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: TextStyle(color: Color(0xFFFF5128)),
                ),
              ),
              SizedBox(height: 40.0),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (result == null && scanData.code != null) {
        setState(() {
          result = scanData;
        });
        await _handleScanResult(scanData.code!);
      }
    });
  }

  Future<void> _handleScanResult(String tagCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String userId = '';

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId'].toString();
    }

    String deviceUuid = Uuid().v4();
    String ipAddress = '192.168.1.1';
    String locationString = '13.736717,100.523186';

    Map<String, dynamic> scanData = {
      'tagCode': tagCode,
      'userId': userId,
      'deviceUuid': deviceUuid,
      'ip_address': ipAddress,
      'location': locationString,
    };

    try {
      final tagScanData = await _apiService.getTagScanData(tagCode);
      print(
          'Scan count for tag ${tagScanData.tagCode}: ${tagScanData.scanCount}');
      print('message: ${tagScanData.message}');
      final response = await _apiService.authenScan(scanData);

      if (tagScanData.scanStatus == 'verify-true') {
        final tag = response!['tag'];
        final tagId = tag['tag_id'];

        await _apiService.enterPrizeDetail(tagId);

        _showSuccessDialog(
          tag['tag_code'],
          tag['name'],
          tagId,
          tagScanData.message,
          tag['image_url'],
        );
      } else if (tagScanData.scanStatus == 'verify-warning') {
        _showErrorDialog(tagCode, tagScanData.message);
      }
      // if (response != null) {
      //   // bool isValid = response['isValid'] ?? false;
      //   if (tagScanData.scanStatus == 'verify-true') {
      //     final tag = response['tag'];
      //     final tagId = tag['tag_id'];

      //     await _apiService.enterPrizeDetail(tagId);

      //     _showSuccessDialog(
      //         tag['tag_code'], tag['name'], tagId, tagScanData.message);
      //   } else if (tagScanData.scanStatus == 'verify-warning') {
      //     _showErrorDialog(tagCode, tagScanData.message);
      //   }
      // } else {
      //   _showErrorDialog(tagCode, 'code not found');
      // }
    } catch (e) {
      print('Error during scan data processing: $e');
      _showErrorDialog(tagCode, 'Error processing your scan data');
    }
  }

  void _showSuccessDialog(
      String tagCode, String name, int tagId, String message, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Icon(FontAwesomeIcons.circleCheck,
                  size: 70, color: Color(0xFFFF5128)),
              SizedBox(height: 20),
              Image.asset(
                imageUrl,
                height: 60.0, // ปรับขนาดโลโก้ตามความเหมาะสม
              ),
              Text(
                name,
                style: TextStyle(fontSize: 16, color: Color(0xFFFF5128)),
              ),
              SizedBox(height: 20),
              Text(message,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(
                tagCode,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5128)),
              ),
              SizedBox(height: 20),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    result = null;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPrizedrawDetails(tagId: tagId),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        result = null;
      });
    });
  }

  void _showErrorDialog(String tagCode, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Icon(FontAwesomeIcons.circleXmark,
                  size: 70, color: Color(0xFFFF5128)),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                tagCode,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5128)),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    result = null;
                  });
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        result = null;
      });
    });
  }
}
