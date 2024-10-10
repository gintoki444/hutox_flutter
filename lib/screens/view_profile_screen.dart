import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api/api_service.dart';
import 'login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      backgroundColor: Color(0xFFEF4D23), // ตั้งค่าสีพื้นหลังของ Scaffold
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // ใช้ SingleChildScrollView เพื่อให้สามารถเลื่อนหน้าได้
              child: Container(
                padding: const EdgeInsets.all(20.0),
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
                            backgroundColor: Colors.white,
                            child: SvgPicture.asset(
                              'assets/icon/icon-profile-cicle.svg',
                              height: 80, // ตั้งค่าขนาดไอคอนตามต้องการ
                              width: 80, // ตั้งค่าขนาดไอคอนตามต้องการ
                              fit: BoxFit.cover,
                              color: Color(0xFFEF4D23),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          // TextButton(
                          //   onPressed: () {
                          //     // Implement edit photo functionality
                          //   },
                          //   child: Text('Edit Photo',
                          //       style: TextStyle(color: Colors.blue)),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    _buildProfileItem(Icons.person, 'คลินิก/ร้านค้า',
                        userProfile!['username'] ?? 'ไม่มีข้อมูล'),
                    _buildProfileItem(Icons.email, 'อีเมล์',
                        userProfile!['email'] ?? 'ไม่มีข้อมูล'),
                    _buildProfileItem(Icons.card_membership, 'ชื่อ-นามสกุล',
                        userProfile!['fullName'] ?? 'ไม่มีข้อมูล'),
                    _buildProfileItem(Icons.phone, 'เบอร์โทรศัพท์',
                        userProfile!['phoneNumber'] ?? 'ไม่มีข้อมูล'),
                    _buildProfileItem(Icons.location_on, 'ที่อยู่',
                        userProfile!['address'] ?? 'ไม่มีข้อมูล'),
                    _buildProfileItem(Icons.language, 'ประเทศ',
                        userProfile!['country'] ?? 'ไม่มีข้อมูล'),
                    SizedBox(height: 20.0),
                    _buildActionButton(
                      context,
                      'แก้ไขโปรไฟล์',
                      Colors.yellow,
                      () {
                        Navigator.pushNamed(context, '/edit_profile');
                      },
                    ),
                    SizedBox(height: 10.0),
                    _buildActionButton(
                      context,
                      'ออกจากระบบ',
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
                    SizedBox(height: 10.0),
                    // เพิ่มปุ่ม "ลบบัญชีผู้ใช้งาน" ใน _ViewProfileScreenState
                    _buildActionButton(
                      context,
                      'ลบบัญชีผู้ใช้งาน',
                      Colors.redAccent,
                      () => _confirmDeleteAccount(),
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
              Text(value ?? 'ไม่มีข้อมูล',
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

  // ฟังก์ชันยืนยันการลบบัญชี
  void _confirmDeleteAccount() async {
    TextEditingController confirmationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ยืนยันการลบบัญชีผู้ใช้งาน"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("พิมพ์ 'ยืนยัน' เพื่อยืนยันการลบบัญชี"),
              TextField(
                controller: confirmationController,
                decoration: InputDecoration(
                  hintText: 'พิมพ์คำว่า ยืนยัน',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () async {
                if (confirmationController.text == "ยืนยัน") {
                  // ลบผู้ใช้
                  await _deleteAccount();
                  Navigator.of(context).pop();
                } else {
                  // แจ้งเตือนเมื่อข้อความไม่ตรงกัน
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('การยืนยันไม่ถูกต้อง')),
                  );
                }
              },
              child: Text("ลบ"),
            ),
          ],
        );
      },
    );
  }

// ฟังก์ชันลบผู้ใช้
  Future<void> _deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userIdInt = decodedToken['userId'];

      if (userIdInt != null) {
        String userId = userIdInt.toString();

        try {
          // เรียกใช้งาน API ลบผู้ใช้
          bool isDeleted = await _apiService.deleteUserByid(userId);

          if (isDeleted) {
            await prefs.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            _showDeletionFailedDialog();
          }
        } catch (e) {
          // แสดง Popup แจ้งว่าการลบไม่สำเร็จ
          _showDeletionFailedDialog();
        }
      }
    }
  }

// ฟังก์ชันแสดง Popup การลบไม่สำเร็จ
  void _showDeletionFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ไม่สามารถลบผู้ใช้งานได้"),
          content: Text(
              "ไม่สามารถลบผู้ใช้งานได้ เนื่องจากมีข้อมูลที่เกี่ยวข้องอยู่ในระบบ"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }
}
