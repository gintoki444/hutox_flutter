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

    if (isLoggedIn) {
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
      _showErrorDialog('Invalid email format');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('Password cannot be empty');
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

    if (responseData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', responseData['token']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HutoxHomePage()),
      );
    } else {
      _showErrorDialog('Invalid email or password');
    }
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือน
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'E-mail',
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
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Password',
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
                          'I agree to the terms and conditions',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                              color: Colors.white, width: 2), // เส้นขอบสีขาว
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 17.0),
                          // width: double.infinity,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            'Member Login',
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
                            _launchURL('https://www.instagram.com/hutalk_th');
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
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
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
    );
  }
}
