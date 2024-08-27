import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api/api_service.dart';
import 'login_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    print('Token: $token');
    if (token != null) {
      // Log ค่า token
      print('Token: $token');

      // ถอดรหัส token เพื่อดึง userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userIdInt = decodedToken['userId'];

      // Log ค่า decoded token
      print('Decoded Token: $decodedToken');

      // ตรวจสอบว่าค่า userId ไม่เป็น null
      if (userIdInt != null) {
        String userId = userIdInt.toString();

        // ใช้ userId ที่ดึงได้เพื่อเรียกข้อมูลผู้ใช้จาก API
        final profile = await _apiService.getUserProfiles(userId);
        setState(() {
          userProfile = profile;
        });
      } else {
        // หากไม่มี userId ใน token ให้แสดงข้อผิดพลาด
        print('User ID not found in token');
      }
    } else {
      // หากไม่มี token ให้แสดงข้อผิดพลาด
      print('Token not found in storage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile'),
      ),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // ใช้ SingleChildScrollView เพื่อให้สามารถเลื่อนหน้าได้
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Color(0xFFEF4D23),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                              height: 40.0), // เพิ่มระยะห่างด้านบนสำหรับ logo
                          Image.asset(
                            'assets/images/logo-hutox-new.png',
                            height: 70.0, // ปรับขนาดโลโก้ตามความเหมาะสม
                          ),
                          SizedBox(height: 20.0),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                NetworkImage('https://picsum.photos/200'),
                          ),
                          SizedBox(height: 8.0),
                          TextButton(
                            onPressed: () {
                              // Implement edit photo functionality
                            },
                            child: Text('Edit Photo',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    _buildProfileItem(Icons.person, 'Username',
                        userProfile!['username'] ?? 'Not available'),
                    _buildProfileItem(Icons.email, 'Email',
                        userProfile!['email'] ?? 'Not available'),
                    _buildProfileItem(Icons.card_membership, 'Full Name',
                        userProfile!['fullName'] ?? 'Not available'),
                    _buildProfileItem(Icons.phone, 'Phone',
                        userProfile!['phoneNumber'] ?? 'Not available'),
                    _buildProfileItem(Icons.location_on, 'Address',
                        userProfile!['address'] ?? 'Not available'),
                    _buildProfileItem(Icons.language, 'Country',
                        userProfile!['country'] ?? 'Not available'),
                    SizedBox(height: 20.0),
                    _buildActionButton(
                      context,
                      'Edit Profile',
                      Colors.yellow,
                      () {
                        Navigator.pushNamed(context, '/edit_profile');
                      },
                    ),
                    SizedBox(height: 10.0),
                    _buildActionButton(
                      context,
                      'Log Out',
                      Colors.red,
                      () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs
                            .clear(); // เคลียร์ข้อมูลทั้งหมดใน SharedPreferences
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (Route<dynamic> route) =>
                              false, // ปิดทุกหน้าและนำไปที่หน้า Login
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 10.0),
              // ตรวจสอบว่าค่า value ไม่เป็น null ถ้าเป็น null ให้แสดงค่า default
              Text(value ?? 'Not available',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          Divider(color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFEF4D23),
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          side: BorderSide(color: Colors.white, width: 2), // เส้นขอบสีขาว
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(30),
          // ),
        ),
        onPressed: onPressed,
        child: Text(label,
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
