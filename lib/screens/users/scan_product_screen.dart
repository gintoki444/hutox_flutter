import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/api/api_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';

class ScanProductScreen extends StatefulWidget {
  @override
  _ScanProductScreenState createState() => _ScanProductScreenState();
}

class _ScanProductScreenState extends State<ScanProductScreen> {
  final ApiService _apiService = ApiService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    // รีเซ็ตค่าทั้งหมดเมื่อออกจากหน้า Scan
    controller?.stopCamera();
    controller?.dispose();
    result = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // กำหนดความกว้างและความสูงของกล้องให้เหมาะสม
    double cameraWidth = screenWidth * 0.8;
    double cameraHeight = cameraWidth * (screenHeight / screenWidth);

    double adjustedCameraWidth = cameraWidth * 0.95;
    double adjustedCameraHeight = cameraHeight * 0.95;

    double leftPosition = (cameraWidth - adjustedCameraWidth) / 2;
    double topPosition = (cameraHeight - adjustedCameraHeight) / 2;

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
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: cameraWidth,
                      height: cameraHeight,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Positioned(
                            left: leftPosition,
                            top: topPosition,
                            child: Container(
                              width: adjustedCameraWidth,
                              height: adjustedCameraHeight,
                              child: QRView(
                                key: qrKey,
                                onQRViewCreated: _onQRViewCreated,
                                overlay: QrScannerOverlayShape(
                                  borderColor: Colors.white,
                                  borderRadius: 10,
                                  borderLength: 30,
                                  borderWidth: 10,
                                  cutOutSize: screenWidth * 0.7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 60.0,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
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
                  'ย้อนกลับ',
                  style: TextStyle(color: Color(0xFFEF4D23)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   double containerWidth = screenWidth > 500 ? 500 : screenWidth;

  //   // double screenWidth = MediaQuery.of(context).size.width;
  //   double screenHeight = MediaQuery.of(context).size.height;

  //   // กำหนดความกว้างของกล้องเป็น 80% ของหน้าจอ
  //   double cameraWidth = screenWidth * 0.8;
  //   double cameraHeight = cameraWidth * (screenHeight / screenWidth);

  //   // คำนวณขนาดของกล้องที่ 95% ของ cameraWidth และ cameraHeight
  //   double adjustedCameraWidth = cameraWidth * 0.95;
  //   double adjustedCameraHeight = cameraHeight * 0.95;

  //   // คำนวณตำแหน่งที่เหมาะสมเพื่อให้กล้องอยู่ตรงกลาง
  //   double leftPosition = (cameraWidth - adjustedCameraWidth) / 2;
  //   double topPosition = (cameraHeight - adjustedCameraHeight) / 2;

  //   return Scaffold(
  //     body: Center(
  //       child: Container(
  //         width: containerWidth,
  //         color: Color(0xFFEF4D23),
  //         child: Stack(
  //           children: [
  //             Positioned.fill(
  //               child: Image.asset(
  //                 'assets/images/scan-bg.png',
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //             Column(
  //               children: <Widget>[
  //                 SizedBox(height: 60.0),
  //                 Center(
  //                   child: Image.asset(
  //                     'assets/images/logo-hutox-new.png',
  //                     height: 60.0,
  //                   ),
  //                 ),
  //                 SizedBox(height: 40.0),
  //                 Center(
  //                   child: Stack(
  //                     children: [
  //                       Container(
  //                         width: 800,
  //                         height: 800,
  //                         alignment: Alignment.center,
  //                         child: Stack(
  //                           children: [
  //                             Positioned(
  //                               left: leftPosition,
  //                               top: topPosition,
  //                               child: Container(
  //                                 width: 300,
  //                                 height: 300,
  //                                 child: QRView(
  //                                   key: qrKey,
  //                                   onQRViewCreated: _onQRViewCreated,
  //                                   overlay: QrScannerOverlayShape(
  //                                     borderColor: Colors.white,
  //                                     borderRadius: 10,
  //                                     borderLength: 30,
  //                                     borderWidth: 10,
  //                                     cutOutSize: screenWidth * 0.7,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // Expanded(
  //                 //   child: Center(
  //                 //     child: Container(
  //                 //       width: 100,
  //                 //       height: containerWidth,
  //                 //       child: QRView(
  //                 //         key: qrKey,
  //                 //         onQRViewCreated: _onQRViewCreated,
  //                 //         overlay: QrScannerOverlayShape(
  //                 //           borderColor: Colors.white,
  //                 //           borderRadius: 10,
  //                 //           borderLength: 50,
  //                 //           borderWidth: 10,
  //                 //           // cutOutSize: containerWidth,
  //                 //         ),
  //                 //       ),
  //                 //     ),
  //                 //   ),
  //                 // ),
  //                 SizedBox(height: 20.0),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.white,
  //                     padding: EdgeInsets.symmetric(
  //                         horizontal: 40.0, vertical: 20.0),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10.0),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'ย้อนกลับ',
  //                     style: TextStyle(color: Color(0xFFEF4D23)),
  //                   ),
  //                 ),
  //                 SizedBox(height: 40.0),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                  size: 100, color: Colors.green),
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
                  padding: const EdgeInsets.all(2),
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
                onPressed: () async {
                  // await controller?.stopCamera();
                  Navigator.pop(context);
                  setState(() {
                    result = null;
                  });
                },
                // onPressed: () => {Navigator.pop(context)},
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
        result = null;
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
                  if (kIsWeb) {
                    print("Skipping camera control on web.");
                    setState(() {
                      result = null;
                    });
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    if (status == "verify-warning") {
                      await controller?.stopCamera();
                      controller?.dispose();
                      setState(() {
                        result = null;
                      });
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      // await controller?.stopCamera();
                      Navigator.pop(context);
                      setState(() {
                        result = null;
                      });
                    }
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
        result = null;
      });
    });
  }
}
