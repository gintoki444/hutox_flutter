import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hutox_homepage.dart';
import 'login_screen.dart'; // Import the login screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // ตรวจสอบการเข้าสู่ระบบ
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 70.0),
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
                  backgroundColor: Color(0xFFEF4D23),
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 36.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Image.asset(
                  'assets/images/logo-hutox-new.png',
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
