import 'package:dml_verify_tags/screens/hutox_homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api/api_service.dart';
import '../widgets/custom_checkbox.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService =
      ApiService(); // Create an instance of ApiService
  bool _isLoading = false;
  bool _obscureText = true;
  bool _isAgreed = false; // ตัวแปรสำหรับเก็บสถานะของ Checkbox

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // เพิ่มฟังก์ชันการตรวจสอบการเข้าสู่ระบบ
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool token = prefs.getBool('token') ?? false;

    if (isLoggedIn && token) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HutoxHomePage()),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // ฟังก์ชันสำหรับตรวจสอบรูปแบบ email
  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  Future<void> login(String email, String password) async {
    if (!_isEmailValid(email)) {
      _showErrorDialog('ข้อมูลอีเมล์ไม่ถูกต้อง');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('กรุณากรอกรหัสผ่าน');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final loginData = {'email': email, 'password': password};
    final responseData = await _apiService.checkLogin(loginData);

    setState(() {
      _isLoading = false;
    });

    if (responseData != null && responseData['message'] != null) {
      // ตรวจสอบว่าค่าของ message ไม่เป็น null ก่อนแสดงผล

      if (responseData['message'] ==
          "Account not activated. Please activate your account.") {
        _showErrorDialog("กรุณาตรวจสอบอีเมล์เพื่อ Activate ผู้ใช้งาน",
            email: email);
      } else {
        _showErrorDialog(responseData['message'] ?? 'Unknown error occurred');
      }
    }
    // else if (responseData != null && responseData['message'] == null) {
    //   // ตรวจสอบกรณีที่ message เป็น null
    //   _showErrorDialog('No message received from the server');
    // }
    else {
      // แสดงข้อความเมื่อเข้าสู่ระบบสำเร็จ
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', responseData?['token']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HutoxHomePage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // if (responseData != null) {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.setBool('isLoggedIn', true);
    //   await prefs.setString('token', responseData['token']);
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => HutoxHomePage()),
    //   );
    // } else {
    //   _showErrorDialog('อีเมล์/รหัสผ่าน ไม่ถูกต้อง !');
    // }
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือน
  void _showErrorDialog(String message, {String? email}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'ล็อกอินไม่สำเร็จ',
            textAlign: TextAlign.center,
          ),
        ),
        content: SingleChildScrollView(
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ตกลง'),
                ),
                if (email !=
                    null) // แสดงปุ่ม Re-activate เฉพาะเมื่อ email ไม่เป็น null
                  TextButton(
                    onPressed: () {
                      // เรียกใช้ฟังก์ชันส่งอีเมลหรือทำงานบางอย่างที่นี่
                      _sendEmail(email);
                      Navigator.pop(context);
                    },
                    child: Text('Re-activate'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ฟังก์ชันสำหรับส่งอีเมล
  void _sendEmail(String email) async {
    try {
      // เรียกใช้ฟังก์ชัน reActivate และรอผลลัพธ์ที่ได้
      final result = await ApiService().reActivate(email);

      if (result.containsKey('error')) {
        // ถ้ามีคีย์ error แสดงว่าเกิดข้อผิดพลาด
        _showErrorSnackBarTop(result['error'], Colors.red);
      } else if (result.containsKey('message')) {
        // ถ้ามีคีย์ message แสดงผล message ที่ได้รับจาก API
        _showErrorSnackBarTop(
            'Re-Activate สำเร็จ กรุณาตรวจสอบอีเมล์ของท่าน', Colors.green);
      } else {
        // กรณีที่ไม่มีทั้ง error และ message
        _showErrorSnackBarTop('Unexpected response format',
            const Color.fromARGB(255, 255, 196, 0));
      }
    } catch (e) {
      // จัดการข้อผิดพลาดอื่น ๆ
      print('Error sending re-activation email: $e');
      _showErrorSnackBarTop(
          'An error occurred while sending the re-activation email.',
          Colors.red);
    }
  }

  void _showErrorSnackBarTop(String message, Color color) {
    // ซ่อน SnackBar ก่อนหน้าถ้ามี
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // แสดง SnackBar ที่ด้านบนของหน้าจอ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color, // สีพื้นหลังของ SnackBar
        duration: Duration(seconds: 3), // ระยะเวลาแสดงผล SnackBar
        behavior: SnackBarBehavior.floating, // ทำให้ SnackBar ลอยอยู่
        margin: EdgeInsets.only(
          top: 10, // กำหนดให้แสดงใกล้ขอบด้านบน
          left: 10,
          right: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // มุมโค้งของ SnackBar
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            // ทำอะไรบางอย่างเมื่อกดปุ่ม OK บน SnackBar
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFEF4D23),
        body: Center(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: Color(0xFFEF4D23),
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/login-bg.png"), // ใส่ path ของรูปภาพที่ต้องการใช้เป็นพื้นหลัง
                fit: BoxFit.cover, // ทำให้รูปภาพเต็มพื้นที่
              ), // เปลี่ยนเป็นสี FF5128
            ),
            child: Align(
              alignment: Alignment.topCenter, // เนื้อหาจะอยู่ด้านบน
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    Image.asset(
                      'assets/images/logo-hutox.png',
                      height: 210.0, // ตั้งค่าขนาดโลโก้ตามต้องการ
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'อีเมล์',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'รหัสผ่าน',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 100.0),
                    Container(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width *
                            0.05, // Padding 5% จากซ้าย
                        right: MediaQuery.of(context).size.width *
                            0.05, // Padding 5% จากขวา
                        top: 0,
                        bottom: 0,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isAgreed = !_isAgreed;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // จัดให้ข้อความอยู่ตรงกลางในแนวนอน
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // จัดให้ข้อความอยู่ตรงกลางในแนวตั้ง
                          children: <Widget>[
                            CustomCheckbox(
                              value: _isAgreed,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isAgreed = value ?? false;
                                });
                              },
                            ),
                            SizedBox(
                                width:
                                    10), // เพิ่มระยะห่างระหว่าง Checkbox และ Text
                            Text(
                              'ยอมรับข้อกำหนดและเงื่อนไข',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _isLoading
                        ? CircularProgressIndicator()
                        : OutlinedButton(
                            onPressed: _isAgreed
                                ? () {
                                    final email = _emailController.text;
                                    final password = _passwordController.text;
                                    login(email, password);
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white,
                                  width: 2), // เส้นขอบสีขาว
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 17.0),
                              // width: double.infinity,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                'เข้าสู่ระบบ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white, // ตัวหนังสือสีขาว
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.68,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  iconSize: 34,
                                  icon: FaIcon(FontAwesomeIcons.facebookF,
                                      color: Color(0xFFEF4D23)),
                                  onPressed: () {
                                    _launchURL(
                                        'https://www.facebook.com/thehutalk');
                                  },
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: IconButton(
                              iconSize: 38,
                              icon: FaIcon(FontAwesomeIcons.instagram,
                                  color: Color(0xFFEF4D23)),
                              onPressed: () {
                                _launchURL(
                                    'https://www.instagram.com/hutalk_th');
                              },
                            ),
                          ),
                          Spacer(),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  iconSize: 38,
                                  icon: FaIcon(FontAwesomeIcons.xTwitter,
                                      color: Color(0xFFEF4D23)),
                                  onPressed: () {
                                    _launchURL(
                                        'https://www.instagram.com/hutalk_th');
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      child: Text.rich(
                        TextSpan(
                          text: 'ไม่มีบัญชีผู้ใช้งาน ?',
                          style: TextStyle(color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' สมัครสมาชิก',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                              ),
                            ),
                            // can add more TextSpans here...
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/welcome');
                      },
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      child: FaIcon(
                        FontAwesomeIcons.circleLeft,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
