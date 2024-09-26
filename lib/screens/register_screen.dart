import 'package:dml_verify_tags/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../services/api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ApiService _apiService =
      ApiService(); // Create an instance of ApiService
  bool _obscureText = true;
  bool _isLoading = false;

  // ฟังก์ชันสำหรับตรวจสอบรูปแบบ email
  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // final loginData = {'email': email, 'password': password};

    if (name.isEmpty) {
      _showErrorDialog('Name cannot be empty');
      return;
    }
    if (!_isEmailValid(email)) {
      _showErrorDialog('Invalid email format');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('Password cannot be empty');
      return;
    }
    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await _apiService.register(name, email, password);

      // ตรวจสอบว่า responseData มี userId หรือไม่
      if (responseData['userId'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        _showSuccessDialog(
            'กรุณาตรวจสอบอีเมล์: ' + email + ' เพื่อยืนยันตัวตน');
      } else {
        _showErrorDialog('Registration failed: ${responseData['message']}');
      }
    } catch (e) {
      _showErrorDialog('Error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือน
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register Failed'),
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

  // ฟังก์ชันแสดงข้อความสำเร็จ
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => HutoxHomePage()),
              // );
            },
            child: Text('OK'),
          ),
        ],
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
              color: Color(0xFFEF4D23), // สีพื้นหลัง
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 40.0),
                    Image.asset(
                      'assets/images/logo-hutox.png',
                      height: 150.0, // ตั้งค่าขนาดโลโก้ตามต้องการ
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'ลงทะเบียนคลินิก/ร้านค้า',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ชื่อคลินิก/ร้านค้า',
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
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
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'อีเมล์',
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
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
                        hintText: 'รหัสผ่าน',
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureText,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ยืนยันรหัสผ่าน',
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                    SizedBox(height: 20.0),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // สีพื้นหลังของปุ่ม
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                'สมัครสมาชิก',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white, // ตัวหนังสือสีขาว
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // กลับไปที่หน้า Login
                      },
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      child: Text.rich(
                        TextSpan(
                          text: 'มีบัญชีผู้ใช้งาน ?',
                          style: TextStyle(color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' ล็อกอิน',
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     Text(
                    //       'มีบัญชีผู้ใช้งาน?',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.pop(context); // กลับไปที่หน้า Login
                    //       },
                    //       child: Text(
                    //         'ล็อกอิน',
                    //         style: TextStyle(color: Colors.blue),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
