import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hutox_homepage.dart';

class HomeScreen extends StatelessWidget {
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
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ตรวจสอบผลิตภัณฑ์',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                '(VERIFY YOUR PRODUCT)',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  _launchURL('https://meso-click.com:9000/frmDmlVerifyMeso');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(312, 90),
                  backgroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Image.asset(
                  'assets/images/mesoestetic-logo-new.png',
                  height: 35.0, // ตั้งค่าขนาดโลโก้ตามต้องการ
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HutoxHomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(312, 90),
                  backgroundColor: Color(0xFFFF5128),
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Image.asset(
                  'assets/images/logo-hutox-new.jpg',
                  height: 45.0, // ตั้งค่าขนาดโลโก้ตามต้องการ
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
