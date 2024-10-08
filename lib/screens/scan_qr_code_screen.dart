import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/api/api_service.dart';

class ScanQRCodeScreen extends StatefulWidget {
  @override
  _ScanQRCodeScreenState createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final ApiService _apiService = ApiService();

  String qrCode = '';
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.dispose(); // Dispose the previous controller
      controller = null; // Set controller to null to ensure a fresh start
    }
    setState(() {
      qrCode = ''; // Reset QR code data
    });
  }

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
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  controller
                      ?.dispose(); // Dispose the controller when leaving the screen
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
                  'ย้อนกลับ',
                  style: TextStyle(color: Color(0xFFEF4D23)),
                ),
              ),
              SizedBox(height: 40.0),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController qrController) {
    this.controller = qrController;
    controller?.scannedDataStream.listen((scanData) async {
      if (qrCode.isEmpty) {
        setState(() {
          qrCode = scanData.code!;
        });
        await _handleScanResult(scanData.code!);
      }
    });
  }

  Future<void> _handleScanResult(String tagCode) async {
    try {
      final tagScanData = await _apiService.getTagUserScanData(tagCode);

      if (tagScanData.scanStatus == 'verify-true') {
        await _apiService.enterPrizeDetail(tagScanData.tagId);

        _showSuccessDialog(
          tagScanData.tagCode,
          tagScanData.name,
          tagScanData.tagId,
          tagScanData.message,
          tagScanData.imageUrl,
        );
      } else if (tagScanData.scanStatus == 'verify-warning') {
        _showErrorDialog(tagCode, tagScanData.message, tagScanData.scanStatus);
      }
    } catch (e) {
      print('Error during scan data processing: $e');
      _showErrorDialog(
          tagCode, 'รหัสของคุณไม่ถูกต้อง กรุณาสแกนรหัสใหม่!', 'verify-false');
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
                  size: 100, color: Color(0xFFEF4D23)),
              SizedBox(height: 20),
              Text(
                "สินค้านี้เป็นของแท้",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircleAvatar(
                radius: 100,
                backgroundColor: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(2), // Border radius
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('ไม่สามารถแสดงรูปภาพได้');
                      },
                    ),
                  ),
                ),
              ),
              Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "รหัส: $tagCode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4D23),
                        fontSize: 18,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    TextSpan(
                      text: "\n" + message.replaceAll(tagCode, ''),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(90, 30),
                  backgroundColor: Color(0xFFEF4D23),
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'ปิด',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        qrCode = '';
      });
    });
  }

  void _showErrorDialog(String tagCode, String message, String status) {
    IconData icon;

    if (status == "verify-warning") {
      icon = FontAwesomeIcons.circleExclamation;
    } else if (status == "verify-false") {
      icon = FontAwesomeIcons.circleXmark;
    } else {
      icon = FontAwesomeIcons.circleXmark;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Icon(icon, size: 70, color: Color(0xFFEF4D23)),
              SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "รหัส: $tagCode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4D23),
                        fontSize: 18,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    TextSpan(
                      text: "\n" +
                          message.replaceAll(
                              'รหัส: ' + tagCode + ' รหัสนี้', ''),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(90, 30),
                  backgroundColor: Color(0xFFEF4D23),
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  if (status == "verify-warning") {
                    setState(() {
                      qrCode = '';
                    });
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    Navigator.pop(context);
                    setState(() {
                      qrCode = '';
                    });
                  }
                },
                child: Text(
                  'ปิด',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        qrCode = '';
      });
    });
  }
}
