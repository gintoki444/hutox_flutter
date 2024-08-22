import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _isAgreed = false; // ตัวแปรสำหรับเก็บสถานะของ Checkbox

  // ฟังก์ชันสำหรับตรวจสอบรูปแบบ email
  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  Future<void> login(String email, String password) async {
    // ตรวจสอบว่ากรอก email และ password ถูกต้องหรือไม่
    if (!_isEmailValid(email)) {
      _showErrorDialog('Invalid email format');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('Password cannot be empty');
      return;
    }

    final url =
        'https://asia-southeast1-tagsystem-2a343.cloudfunctions.net/apitag/api/users/login';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'email': email, 'password': password});

    setState(() {
      _isLoading = true;
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', responseData['token']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
          color: Color(0xFFFF5128),
          image: DecorationImage(
            image: AssetImage(
                "assets/images/login-bg.png"), // ใส่ path ของรูปภาพที่ต้องการใช้เป็นพื้นหลัง
            fit: BoxFit.cover, // ทำให้รูปภาพเต็มพื้นที่
          ), // เปลี่ยนเป็นสี FF5128
        ),
        child: Align(
          alignment: Alignment.topCenter, // เนื้อหาจะอยู่ด้านบน
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40.0),
                Image.asset(
                  'assets/images/logo-hutox.png',
                  height: 180.0, // ตั้งค่าขนาดโลโก้ตามต้องการ
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
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
                  style: TextStyle(color: Colors.white),
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
                SizedBox(height: 80.0),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _isAgreed,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'I agree to the terms and conditions',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
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
                              color: Colors.white, width: 1), // เส้นขอบสีขาว
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          width: double.infinity,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.facebook, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.instagram,
                          color: Colors.white), // เปลี่ยนเป็นไอคอน Instagram
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.xTwitter,
                          color: Colors.white), // เปลี่ยนเป็นไอคอน fa-x-twitter
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.white),
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
