import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';
import 'users/scan_product_screen.dart';

class WelcomeScreen extends StatelessWidget {
  // ฟังก์ชันสำหรับเปิด URL ในเบราว์เซอร์
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFEF4D23),
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 70.0),
              Image.asset(
                'assets/images/logo-hutox-new.png',
                height: 70.0, // ปรับขนาดโลโก้ตามความเหมาะสม
              ),
              SizedBox(height: 30.0), // เพิ่มระยะห่างด้านบนสำหรับ logo
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScanProductScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(312, 150),
                  backgroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Image.asset(
                  'assets/icon/icon-scan-tag.png',
                  height: 150, // ตั้งค่าขนาดโลโก้ตามต้องการ
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(312, 150),
                    backgroundColor: Color(0xFFFFFFFF),
                    padding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 36.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(children: [
                    SvgPicture.asset(
                      'assets/icon/icon-doctor.svg',
                      height: 110, // ตั้งค่าขนาดไอคอนตามต้องการ
                    ),
                    Text("คลินิก/ร้านค้า",
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFFef4d23)))
                  ])
                  // child: Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SvgPicture.asset(
                  //       'assets/icon/icon-doctor.svg',
                  //       height: 45.0, // ตั้งค่าขนาดไอคอนตามต้องการ
                  //     ),
                  //     SizedBox(width: 10), // เพิ่มระยะห่างระหว่างไอคอนและข้อความ
                  //     Text(
                  //       'สำหรับคลินิก/ร้านค้า',
                  //       style: TextStyle(fontSize: 16, color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
