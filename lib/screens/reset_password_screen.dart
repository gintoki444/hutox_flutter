import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api/api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (token != null) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          int? userIdInt = decodedToken['userId'];

          if (userIdInt != null) {
            final response = await _apiService.resetPassword(
                userIdInt, _newPasswordController.text);
            _showSuccessDialog(response['message']);
          }
        } else {
          setState(() {
            _isLoading = false; // ตั้งค่าให้หยุดแสดงการโหลดในกรณีที่ไม่มี token
          });
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
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
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('New Password', style: TextStyle(fontSize: 18)),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration:
                          InputDecoration(hintText: 'Enter new password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Confirm New Password',
                        style: TextStyle(fontSize: 18)),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration:
                          InputDecoration(hintText: 'Confirm new password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        child: Text('Reset Password'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
