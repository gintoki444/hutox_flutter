import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api/api_service.dart';
import 'edit_prizedraw_details.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (result == null && scanData.code != null) {
        setState(() {
          result = scanData;
        });
        // หยุดการสแกนเมื่อสแกนสำเร็จ
        await controller.pauseCamera();
        await _handleScanResult(scanData.code!);
      }
    });
  }

  Future<void> _checkPermissions() async {
    // ตรวจสอบทั้งการอนุญาตใช้งานกล้องและตำแหน่ง
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus locationStatus = await Permission.location.status;

    if (cameraStatus.isGranted && locationStatus.isGranted) {
      // เมื่อได้รับการอนุญาตแล้วให้ทำการแสดงหน้าสแกน
      setState(() {
        // การแสดง QRView จะเกิดขึ้นใน build method และ _onQRViewCreated จะถูกเรียกเองโดย QRView
      });
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _requestPermissions() async {
    // ขอการอนุญาตทั้งกล้องและตำแหน่งจากผู้ใช้
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus locationStatus = await Permission.location.request();

    if (cameraStatus.isGranted && locationStatus.isGranted) {
      // เมื่อได้รับการอนุญาตแล้วให้ทำการแสดงหน้าสแกน
      setState(() {
        // QRView จะถูกแสดงและเรียก _onQRViewCreated เอง
      });
    } else {
      _showPermissionDialog(); // แสดงแจ้งเตือนหากไม่ได้รับอนุญาต
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ไม่ได้รับอนุญาตให้ใช้กล้องหรือตำแหน่ง'),
          content: Text(
              'กรุณาเปิดการใช้งานกล้องและตำแหน่งในแอปพลิเคชันเพื่อใช้งานฟีเจอร์นี้'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // กลับไปที่หน้าแรก
              },
              child: Text('กลับสู่หน้าแรก'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _requestPermissions(); // ขอการอนุญาตใหม่
              },
              child: Text('ขออนุญาตใช้งานอีกครั้ง'),
            ),
          ],
        );
      },
    );
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
        return null;
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
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

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) async {
  //     if (result == null && scanData.code != null) {
  //       setState(() {
  //         result = scanData;
  //       });
  //       await _handleScanResult(scanData.code!);
  //     }
  //   });
  // }

  Future<void> _handleScanResult(String tagCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int userId = 0;

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['userId'];
    }

    String deviceUuid = Uuid().v4();
    String ipAddress = await getIpAddress();
    Position? position = await getCurrentLocation();
    // print('Position: $position');

    String locationString = position != null
        ? '${position.latitude},${position.longitude}'
        : '0.0,0.0';

    Map<String, dynamic> scanData = {
      'tagCode': tagCode,
      'userId': userId,
      'deviceUuid': deviceUuid,
      'ip_address': ipAddress,
      'location': locationString,
    };
    // print(scanData);

    try {
      final response = await _apiService.authenScan(scanData);
      final tagScanData = await _apiService.getTagScanData(tagCode);
      // print(
      //     'Scan count for tag ${tagScanData.tagCode}: ${tagScanData.scanCount}');
      // print('message: ${tagScanData.message}');
      // print('tagScanData.user_id: ${tagScanData.user_id}');

      if (tagScanData.scanStatus == 'verify-true' &&
          tagScanData.user_id == userId) {
        if (response != null) {
          bool isValid = response['isValid'] ?? false;
          if (isValid) {
            await _apiService.enterPrizeDetail(tagScanData.tagId);
            await _apiService.enterPrizeDrawEntries(
                tagScanData.tagId, tagScanData.prizeId, userId);
          }
        }

        _showSuccessDialog(
            tagScanData.tagCode,
            tagScanData.name,
            tagScanData.tagId,
            tagScanData.message,
            tagScanData.imageUrl,
            tagScanData.scanStatus);
      } else {
        _showSuccessDialog(
            tagScanData.tagCode,
            tagScanData.name,
            tagScanData.tagId,
            tagScanData.message,
            tagScanData.imageUrl,
            'verify-warning');
      }
    } catch (e) {
      print('Error during scan data processing: $e');
      _showErrorDialog(
          tagCode, 'รหัสของคุณไม่ถูกต้อง กรุณาสแกนรหัสใหม่!', 'verify-false');
    }
  }

  void _showSuccessDialog(String tagCode, String name, int tagId,
      String message, String imageUrl, String status) {
    IconData icon;
    Color iconColor;

    if (status == "verify-warning") {
      icon = FontAwesomeIcons.circleExclamation;
      iconColor = const Color.fromARGB(255, 253, 181, 0);
    } else if (status == "verify-true") {
      icon = FontAwesomeIcons.circleCheck;
      iconColor = Colors.green;
    } else {
      iconColor = Colors.red;
      icon = FontAwesomeIcons.circleCheck;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด Popup โดยการกดด้านนอก
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Icon(icon, size: 70, color: iconColor),
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
                      text: "\n" + message.replaceAll('รหัส: ' + tagCode, ''),
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
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(150, 30),
                  backgroundColor: Color(0xFFEF4D23),
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    result = null;
                  });
                  // ปิด Popup
                  Navigator.pop(context);

                  if (status == 'verify-warning') {
                    // เริ่มกล้องใหม่เมื่อผู้ใช้กดปุ่ม OK
                    controller?.resumeCamera();
                  } else if (status == 'verify-true') {
                    // หยุดกล้องก่อนนำทางไปหน้าถัดไป
                    await controller?.stopCamera();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPrizedrawDetails(tagId: tagId),
                      ),
                    ).then((value) {
                      // เมื่อย้อนกลับมาที่หน้านี้ ให้เริ่มการทำงานของกล้องใหม่
                      controller?.resumeCamera();
                    });
                  }
                },
                child: Text(
                  status == 'verify-warning' ? 'OK' : 'ลงทะเบียน',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
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
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    result = null;
                  });
                },
                child: Text(
                  'ปิด',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
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

  Future<String> getIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP address: $e');
    }
    return '0.0.0.0';
  }
}
